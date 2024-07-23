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


class FilmStock{
  final String name;
  final String info;
  final int iso;
  final FilmType type;

  const FilmStock({
    required this.name,
    required this.info,
    required this.iso,
    required this.type
  });

  factory FilmStock.fromJson (Map<String, dynamic> json) {
    return FilmStock(
      name: json["name"],
      info: json["development_info"],
      iso: json["iso"],
      type: FilmType.values[json["type"]]
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
            Text(name,
              style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ISO $iso", style: const TextStyle(fontSize: 12)),
                Text("Type ${type.toUserString()}", style: const TextStyle(fontSize: 12))
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
  "type": $type
}
    """;
  }
}
