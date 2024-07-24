import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Entities/FilmStock.dart';
import '../api.dart';

class Stocks extends StatefulWidget {
  List<FilmStock> filmstocks = [];
  List<Widget> filmstocks_cards = [];
  String? error;
  BuildContext? context;


  void getStocks(void Function() update) async {
    error = null;
    update();

    try {
      Api.globalStocks = null;
      Api.getFilmstocks().then((stocks) {
        if(stocks.isEmpty) error = "No stock available";
        Api.globalStocks = stocks.toSet();

        for (var stock in stocks) {
          filmstocks_cards.add(stock.build(context!));
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
  State<StatefulWidget> createState() => _Stocks();
}

class _Stocks extends State<Stocks> {
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
    widget.context = context;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: RefreshIndicator(
        onRefresh: () async => widget.getStocks(() => setState(() {})),
        child: (widget.error == null) ? SingleChildScrollView(
          child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).viewPadding.top)
          ] + widget.filmstocks_cards,
        )) : Column(
          children: [
            SizedBox(height: MediaQuery.of(context).viewPadding.top),
            Text(widget.error ?? "Porcoddio")
          ],
        )
      )
    );
  }
}