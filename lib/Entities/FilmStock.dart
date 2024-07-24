import 'package:filmstore/routes/details_filmstock.dart';
import 'package:flutter/material.dart';

enum FilmType {
  UNDEFINED,
  BLACK_WHITE_PAN,
  BLACK_WHITE_ORTHO,
  COLOR,
  INFRARED;

  String toUserString() {
    switch(this) {
      case FilmType.UNDEFINED:
        return "UNDEFINED";

      case FilmType.BLACK_WHITE_ORTHO:
        return "Orthocrhromatic B/W";

      case FilmType.BLACK_WHITE_PAN:
        return "Panchromatic B/W";

      case FilmType.COLOR:
        return "Color";

      case FilmType.INFRARED:
        return "Infrared";
    }
  }
}

enum FilmFormat {
  UNDEFINED,
  THIRTY_FIVE_MM,
  ONE_TWENTY,
  ONE_TWENTY_SEVEN,
  ONE_TEN,
  SHEET;

  String toUserString() {
    switch(this) {
      case FilmFormat.UNDEFINED:
        return "UNDEFINED";

      case FilmFormat.THIRTY_FIVE_MM:
        return "35mm";

      case FilmFormat.ONE_TEN:
        return "110";

      case FilmFormat.ONE_TWENTY:
        return "120";

      case FilmFormat.ONE_TWENTY_SEVEN:
        return "127";

      case FilmFormat.SHEET:
        return "Sheet Film";
    }
  }
}


class FilmStock{
  final String name;
  final String info;
  final int iso;
  final FilmType type;
  final FilmFormat format;
  final int dbId;

  const FilmStock({
    required this.name,
    required this.info,
    required this.iso,
    required this.type,
    required this.format,
    required this.dbId
  });

  factory FilmStock.fromJson (Map<String, dynamic> json) {
    return FilmStock(
      name: json["name"],
      info: json["development_info"],
      iso: json["iso"],
      type: FilmType.values[json["type"]],
      format: FilmFormat.values[json["format"]],
      dbId: json["id"]
    );
  }


  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => FilmStockDetails(stock: this)));
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
              style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ISO $iso", style: const TextStyle(fontSize: 12)),
                Text("Type ${type.toUserString()}", style: const TextStyle(fontSize: 12)),
                Text("Format ${format.toUserString()}", style: const TextStyle(fontSize: 12))
              ],
            )
          ],
        ),
      )
    );
  }

  @override
  String toString() {
    return """
FilmStock: {
  "name": "$name",
  "iso": $iso,
  "info": $info,
  "type": $type,
  "format": $format
}
    """;
  }
}
