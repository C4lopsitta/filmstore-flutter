import 'dart:convert';

import 'package:filmstore/Entities/FilmStock.dart';
import 'package:filmstore/preferences_keys.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static Set<FilmStock>? globalStocks;

  /// Queries API and returns a list of Film Stocks
  ///
  /// Throws a [ApiException] if an issue is encountered.
  static Future<List<FilmStock>> getFilmstocks() async {
    List<FilmStock> stocks = [];


    Uri uri = await buildUri("/films");

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
    http.Response response = await http.get(await buildUri(""));

    if(response.statusCode == 200) return true;
    return false;
  }





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
