import 'package:filmstore/Entities/FilmRoll.dart';
import 'package:filmstore/enums/MenuSelection.dart';
import 'package:flutter/material.dart';

import '../Entities/FilmStock.dart';
import '../api.dart';

class FilmStockDetails extends StatefulWidget {
    final FilmStock stock;

    const FilmStockDetails({
      super.key,
      required this.stock
    });

    @override
    State<StatefulWidget> createState() => _FilmStockDetails();
}

class _FilmStockDetails extends State<FilmStockDetails> {
    List<Widget> rollsUsingStock = [];

    @override
    void initState() {
      fetchRollsUsingStock();

      super.initState();
    }

    void fetchRollsUsingStock() async {
      List<FilmRoll> rolls = await Api.getFilmRolls(stockFilter: widget.stock.dbId);
      if(rolls.isEmpty) {
        rollsUsingStock.add(const Text("No roll is using this stock"));
      }

      rolls.forEach((roll) {
        rollsUsingStock.add(roll.build());
        rollsUsingStock.add(const Divider());
      });

      setState(() {});
    }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.stock.name),
          actions: [
            PopupMenuButton<MenuSelection>(
              icon: const Icon(Icons.more_vert_rounded),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<MenuSelection>(
                  value: MenuSelection.DELETE,
                  child: Text("Delete")
                )
              ],
              onSelected: (MenuSelection selection) {

              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                const Text("Rolls using this Stock")
              ] + rollsUsingStock,
            ),
          )
        )
      );
    }
}