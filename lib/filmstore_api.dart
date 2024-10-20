import 'dart:convert';
import 'dart:io';
import 'package:filmstore/keychain/helper.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

import 'package:filmstore/Entities/FilmStock.dart';
import 'package:filmstore/Entities/FilmRoll.dart';
import 'package:filmstore/preferences_keys.dart';
import 'package:http/http.dart' as base_http;
import 'package:multicast_dns/multicast_dns.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Entities/ApiPicture.dart';

class Api {
  static Set<FilmStock>? globalStocks;
  static List<FilmRoll>? globalRolls;
  static List<ApiPicture>? globalPictures;
  static String _mdsn_discovery_name = "_filmstore-api._tcp.local";

  static HttpClient http = HttpClient();

  static Future<void> setupCertificatedHttpClient() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if(preferences.getString(PreferencesKeys.userMTLSCertificate) != null) {
      SecurityContext context = SecurityContext();
      context.usePrivateKey(preferences.getString(PreferencesKeys.userMTLSCertificate)!);

      http = HttpClient(context: context);
    }
  }

  static Future<HttpClientResponse> getRequest(Uri uri) async {
    try {
      HttpClientRequest request = await http.getUrl(uri);
      return await request.close();
    } catch (e) {
      print('Error during GET request: $e');
      rethrow; // Optional: rethrow to handle it elsewhere
    }
  }

  static Future<HttpClientResponse> postRequest(Uri uri, dynamic body) async {
    try {
      HttpClientRequest request = await http.postUrl(uri);
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(json.encode(body));
      }
      return await request.close();
    } catch (e) {
      print('Error during POST request: $e');
      rethrow; // Optional: rethrow to handle it elsewhere
    }
  }

  static Future<String> handleSocketOrHandshakeException(SocketException? e, HandshakeException? ex) async {
    // The API seems up but it requires mTLS to be used.
    if(e != null) {
      if (e.message.contains('CERTIFICATE_VERIFY_FAILED') ||
          e.message.contains('HandshakeException')) {
        String? cert = await KeychainHelper.getCertificateFromKeychain();
        if (cert == null) {
          throw ApiException(statusCode: 600,
              apiError: "No certificate was selected. API requires mTLS certification to be used.");
        }
        return cert;
      }
    } else {
      String? cert = await KeychainHelper.getCertificateFromKeychain();
      if (cert == null) {
        throw ApiException(statusCode: 600,
            apiError: "No certificate was selected. API requires mTLS certification to be used.");
      }
      return cert;
    }
    throw Exception("No certificate needed");
  }

  static Future<bool> testApiAddress() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await setupCertificatedHttpClient();

    try {
      HttpClientResponse response = await getRequest(await buildUri("/api/v1"));

      if(response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (e) {
      String cert = await handleSocketOrHandshakeException(e, null);
      preferences.setString(PreferencesKeys.userMTLSCertificate, cert);
      return testApiAddress();
    } on HandshakeException catch (e) {
      String cert = await handleSocketOrHandshakeException(null, e);
      preferences.setString(PreferencesKeys.userMTLSCertificate, cert);
      return testApiAddress();
    } on ApiException catch (e) {
      rethrow;
    } catch (e) {
      print(e.runtimeType);
      print(e.toString());
    }
    return false;
  }

  /// mDNS API Discovery service
  static Future<void> discoverApi() async {
    final mdnsClient = MDnsClient();
    await mdnsClient.start();

    await for (final PtrResourceRecord ptr in mdnsClient
        .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(_mdsn_discovery_name))) {
      await for (final SrvResourceRecord srv in mdnsClient.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(ptr.domainName))) {
        print('Filmstore API instance found at '
            '${srv.target}:${srv.port}".');
        SharedPreferences preferences = await SharedPreferences.getInstance();
        bool useDiscovery = preferences.getBool(PreferencesKeys.useDiscovery) ?? true;

        if(useDiscovery) {
          preferences.setString(PreferencesKeys.address, "http://${srv.target}:${srv.port}");
        }

      }
    }

    mdnsClient.stop();
  }

  //works
  /// Queries API and returns a list of Film Stocks
  ///
  /// Raises a [ApiException] if an issue is encountered.
  static Future<List<FilmStock>> getFilmStocks() async {
    List<FilmStock> stocks = [];
    Uri uri = await buildUri("/api/v1/films");

    base_http.Response response = await base_http.get(uri);

    Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode > 300) {
      throw ApiException(
          statusCode: response.statusCode,
          apiError: json["error"]
      );
    }

    List<dynamic> filmstocks = json["films"];

    for (var filmstock in filmstocks) {
      FilmStock stock = FilmStock.fromJson(filmstock as Map<String, dynamic>);
      stocks.add(stock);
    }

    return stocks;
  }


  //works
  static Future<List<FilmRoll>> getFilmRolls({int stockFilter = 0}) async {
    List<FilmRoll> rolls = [];
    Uri uri = await buildUri("/api/v1/filmrolls?stock=$stockFilter");

    base_http.Response response = await base_http.get(uri);

    Map<String, dynamic> json = jsonDecode(response.body);

    if(response.statusCode < 200 || response.statusCode > 300) {
      throw ApiException(statusCode: response.statusCode, apiError: json["error"]);
    }

    List<dynamic> filmRolls = json["filmrolls"];
    for(var filmRoll in filmRolls) {
      rolls.add(FilmRoll.fromJson(filmRoll));
    }

    return rolls;
  }

  // todo)) fix
  static Future<bool> createFilmRoll(FilmRoll roll) async {
    base_http.Response response = await base_http.post(
      await buildUri("/api/v1/filmrolls"),
      body: """
      {
        "camera": "${roll.camera}",
        "film": ${roll.film.dbId},
        "identifier": "${roll.identifier}",
        "pictures": ${roll.picturesId.toString()},
        "status": ${roll.status.index}
      }
      """,
      encoding: utf8
    );

    if(response.statusCode >= 200 && response.statusCode < 300) return true;
    Map<String, dynamic> json = jsonDecode(response.body);
    throw ApiException(statusCode: response.statusCode, apiError: json["error"] ?? "Something really weird just happened");
  }

  static Future<Map<String, dynamic>> uploadImage(File image, Map<String, dynamic> json) async {
    base_http.MultipartRequest request = base_http.MultipartRequest(
      'POST',
      await buildUri("/api/v1/pictures")
    );

    request.fields["req"] = jsonEncode(json);
    base_http.MultipartFile multiFile = base_http.MultipartFile(
      'file',
      base_http.ByteStream(image.openRead()),
      await image.length(),
      filename: path.basename(image.path),
      contentType: MediaType.parse((path.extension(image.path) == "png") ? 'image/png' : 'image/jpeg')
    );
    request.files.add(multiFile);

    base_http.StreamedResponse response = await request.send();

    Map<String, dynamic> responseJson = jsonDecode((await response.stream.toBytes()).toString());

    if(response.statusCode >= 200 && response.statusCode < 300) {
      return responseJson;
    }

    throw ApiException(statusCode: response.statusCode, apiError: responseJson["error"]);
  }


  // fully updated
  static Future<List<ApiPicture>> getPictures() async {
    List<ApiPicture> pictures = [];

    Uri uri = await buildUri("/api/v1/pictures");

    base_http.Response response = await base_http.get(uri);

    Map<String, dynamic> responseJson = jsonDecode(response.body);

    if(response.statusCode > 300 || response.statusCode < 200) {
      throw ApiException(statusCode: response.statusCode, apiError: responseJson["error"]);
    }

    List<dynamic> jsonPictures = responseJson["pictures"];
    jsonPictures.forEach((picture) {
      pictures.add(ApiPicture.fromJson(picture));
    });

    return pictures;
  }

  // static Future<File> getPictureFile(String filename) async {
  //   Uri uri = await buildUri("/api/v1/pictures/file/$filename");
  //
  //
  // }

  // works
  /// Checks if API returns a 200.
  /// 
  /// Raises an [ApiException] when the API does not return 200.
  static Future<Uri> buildUri(String path) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? address = preferences.getString(PreferencesKeys.address);
    if(address == null) {
      throw ApiException(
        statusCode: 600,
        apiError: "No address has been set"
      );
    }

    return Uri.parse(address + path);
  }
}



class ApiException implements Exception {
  final String? message;
  final int statusCode;
  final String apiError;
  final int? apiErrorCode;

  ApiException({
    this.message,
    required this.statusCode,
    required this.apiError,
    this.apiErrorCode
  });
}
