import 'dart:convert';

import 'package:filmstore/Entities/FilmStock.dart';
import 'package:flutter/material.dart';
import '../Entities/Filmroll.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  List<FilmRoll> filmrolls = [];
  List<Widget> filmrolls_cards = [];

  String? error;

  void getFilmRolls(void Function() update) async {
    await http.get(Uri.parse("http://192.168.1.7:4200/filmrolls")).then((response) {
      Map<String, dynamic> json = jsonDecode(response.body);

      if(json["status"] != 200) {
        error = json["message"];
        update();
        return;
      }
      error = null;
      update();

      List<dynamic> films = json["filmrolls"];

      filmrolls = [];
      filmrolls_cards = [];

      films.forEach((filmroll) {
        Map<String ,dynamic> filmjson = filmroll["film"];

        FilmStock film = FilmStock.fromJson(filmjson);

        FilmRoll stock = FilmRoll(
          film: film,
          camera: filmroll["camera"],
          status: FilmStatus.values[filmroll["status"]],
          identifier: filmroll["archival_identifier"],
          picturesId: filmroll["pictures"]
        );

        filmrolls_cards.add(stock.build());
        filmrolls.add(stock);
        filmrolls_cards.add(const Padding( padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
      });

      update();
    });
  }

  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<Home> {
  @override
  void initState() {
    super.initState();
    widget.getFilmRolls(() => setState(() {}));
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).viewPadding.top)
      ] + widget.filmrolls_cards,
    );
  }
}