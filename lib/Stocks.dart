import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Entities/FilmStock.dart';
import 'api.dart';

class Brands extends StatefulWidget {
  List<FilmStock> filmstocks = [];
  List<Widget> filmstocks_cards = [];
  String? error;


  void getStocks(void Function() update) async {
    error = null;
    update();

    try {
      Api.globalStocks = null;
      Api.getFilmstocks().then((stocks) {
        if(stocks.isEmpty) error = "No stock available";
        Api.globalStocks = stocks.toSet();

        for (var stock in stocks) {
          filmstocks_cards.add(stock.build());
          filmstocks_cards.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
        }
        update();
      });
    } on ApiException catch (ex) {
      error = ex.message;
    } catch (ex) {
      error = ex.toString();
    } finally {
      update();
    }
  }

  @override
  State<StatefulWidget> createState() => _Brands();
}

class _Brands extends State<Brands> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    widget.getStocks(() => setState(() {}));
    super.didChangeDependencies();
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
        Text(widget.error ?? "Porcoddio")
      ],
    );
  }
}