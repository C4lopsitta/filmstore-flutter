import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Entities/FilmStock.dart';

class Brands extends StatefulWidget {
  List<FilmStock> filmstocks = [];
  List<Widget> filmstocks_cards = [];
  String? error;


  void getStocks(void Function() update) async {
    await http.get(Uri.parse("http://192.168.1.7:4200/films")).then((response) {
      Map<String, dynamic> json = jsonDecode(response.body);

      if(json["status"] != 200) {
        error = json["message"];
        update();
        return;
      }
      error = null;
      update();

      List<dynamic> films = json["films"];

      filmstocks = [];
      filmstocks_cards = [];

      films.forEach((film) {
        FilmStock stock = FilmStock(
            name: film["name"],
            info: film["development_info"],
            iso: film["iso"],
            type: FilmType.values[film["type"]]
        );

        filmstocks_cards.add(stock.build());
        filmstocks.add(stock);
        filmstocks_cards.add(const Padding( padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
      });

      update();
    });
  }

  @override
  State<StatefulWidget> createState() => _Brands();
}

class _Brands extends State<Brands> {
  @override
  void initState() {
    super.initState();

    widget.getStocks(() => setState(() {}));
  }


  @override
  Widget build(BuildContext context) {
    return (widget.error == null) ? Column(
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).viewPadding.top)
      ] + widget.filmstocks_cards,
    ) : Column(
      children: [
        SizedBox(height: MediaQuery.of(context).viewPadding.top),
        Text(widget.error ?? "")
      ],
    );
  }
}