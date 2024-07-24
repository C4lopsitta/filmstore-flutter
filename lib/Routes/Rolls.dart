import 'dart:convert';

import 'package:filmstore/Entities/FilmStock.dart';
import 'package:flutter/material.dart';
import '../Entities/FilmRoll.dart';
import 'package:http/http.dart' as http;

import '../api.dart';

class Rolls extends StatefulWidget {
  List<Widget> filmrolls_cards = [];

  String? error;

  void getFilmRolls(void Function() update) async {
    try {
      Api.globalRolls = null;
      error = null;
      update();
      Api.globalRolls = (await Api.getFilmRolls()).toSet();

      if(Api.globalRolls!.isEmpty) throw ApiException(statusCode: 200, apiError: "No Rolls available");

      for(FilmRoll roll in Api.globalRolls!) {
        filmrolls_cards.add(roll.build());
      }
    } on ApiException catch (ex) {
      error = ex.apiError;
    } catch (ex) {
      error = ex.toString();
    } finally {
      update();
    }
  }

  @override
  State<StatefulWidget> createState() => _Rolls();
}

class _Rolls extends State<Rolls> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    widget.getFilmRolls(() => setState(() {}));
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: RefreshIndicator(
        onRefresh: () async => widget.getFilmRolls(() => setState(() {})),
        child: (widget.error == null) ? SingleChildScrollView(
          child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).viewPadding.top)
          ] + widget.filmrolls_cards,
        )) : Column(
          children: [
            SizedBox(height: MediaQuery.of(context).viewPadding.top),
            Text(widget.error ?? "Something really weird just happened")
          ],
        )
      )
    );
  }
}