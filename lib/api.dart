import 'dart:convert';

import 'package:filmstore/Entities/FilmStock.dart';
import 'package:filmstore/Entities/FilmRoll.dart';
import 'package:filmstore/preferences_keys.dart';
import 'package:http/http.dart' as http;
import 'package:multicast_dns/multicast_dns.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static Set<FilmStock>? globalStocks;
  static List<FilmRoll>? globalRolls;
  static String _mdsn_discovery_name = "_filmstore-api._tcp.local";

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

  /// Queries API and returns a list of Film Stocks
  ///
  /// Raises a [ApiException] if an issue is encountered.
  static Future<List<FilmStock>> getFilmStocks() async {
    List<FilmStock> stocks = [];
    Uri uri = await buildUri("/api/v1/films");

    http.Response response = await http.get(uri);

    Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode > 300) {
      throw ApiException(
          statusCode: response.statusCode,
          apiError: json["message"]
      );
    }

    List<dynamic> filmstocks = json["films"];

    for (var filmstock in filmstocks) {
      FilmStock stock = FilmStock.fromJson(filmstock as Map<String, dynamic>);
      stocks.add(stock);
    }

    return stocks;
  }

  static Future<bool> testApiAddress() async {
    http.Response response = await http.get(await buildUri("/api/v1"));

    if(response.statusCode == 200) return true;
    return false;
  }

  static Future<List<FilmRoll>> getFilmRolls() async {
    List<FilmRoll> rolls = [];
    Uri uri = await buildUri("/api/v1/filmrolls");

    http.Response response = await http.get(uri);

    Map<String, dynamic> json = jsonDecode(response.body);

    if(response.statusCode < 200 || response.statusCode > 300) {
      throw ApiException(statusCode: response.statusCode, apiError: json["message"]);
    }

    List<dynamic> filmRolls = json["filmrolls"];
    for(var filmRoll in filmRolls) {
      rolls.add(FilmRoll.fromJson(filmRoll));
    }

    return rolls;
  }

  static Future<bool> createFilmRoll(FilmRoll roll) async {
    http.Response response = await http.post(
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
    throw ApiException(statusCode: response.statusCode, apiError: json["message"] ?? "Something really weird just happened");
  }

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
