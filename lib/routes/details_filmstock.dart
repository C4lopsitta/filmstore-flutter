import 'package:flutter/material.dart';

import '../Entities/FilmStock.dart';

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
    @override
    void initState() {
        super.initState();

    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.stock.name),
          actions: [
            IconButton(
              onPressed: () {
                // TODO))
              },
              icon: const Icon(Icons.edit_rounded),
              tooltip: "Edit",
            )
          ],
        ),
        body: Column(
          children: [

          ],
        ),
      );
    }
}