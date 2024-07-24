import 'dart:math';

import 'package:filmstore/Entities/FilmStock.dart';
import 'package:flutter/material.dart';

import '../api.dart';

enum FilmStatus {
  UNDEFINED,
  IN_CAMERA,
  TO_DEVELOP,
  DEVELOPED,
  SCANNED,
  ARCHIVED;

  String toUserString() {
    switch(this) {
      case FilmStatus.UNDEFINED:
        return "UNDEFINED";

      case FilmStatus.IN_CAMERA:
        return "In camera";

      case FilmStatus.TO_DEVELOP:
        return "To be developed";

      case FilmStatus.DEVELOPED:
        return "Developed";

      case FilmStatus.SCANNED:
        return "Fully Scanned";

      case FilmStatus.ARCHIVED:
        return "Archived";
    }
  }
}


class FilmRoll {
  final FilmStock film;
  final String camera;
  final String identifier;
  final FilmStatus status;
  final List<dynamic> picturesId;
  final int dbId;

  const FilmRoll({
    required this.film,
    required this.camera,
    required this.status,
    required this.identifier,
    required this.picturesId,
    required this.dbId
  });

  factory FilmRoll.fromJson(Map<String, dynamic> json) {
    FilmStock? film;

    // Search across the already existing library of film stocks
    // TODO)) Add binary search if possible
    if((Api.globalStocks?.length ?? 0) > 0) {
      for(FilmStock stock in Api.globalStocks!) {
        if(stock.dbId == json["film"]["id"]) {
          film = stock;
          break;
        }
      }
    } else {
      film = FilmStock.fromJson(json["film"]);
    }

    return FilmRoll(
      camera: json["camera"],
      status: FilmStatus.values[json["status"]],
      identifier: json["identifier"],
      picturesId: json["pictures"],
      film: film!,
      dbId: json["db_id"]
    );
  }

  Widget build() {
    return GestureDetector(
      onTap: () {

      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(film.name,
              style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(camera, style: const TextStyle(fontSize: 12)),
                Text(status.toUserString(), style: const TextStyle(fontSize: 12)),
                Text("AID: $identifier", style: const TextStyle(fontSize: 12)),
                Text("${picturesId.length} scanned", style: const TextStyle(fontSize: 12))
              ],
            )
          ],
        ),
      )
    );
  }
}
