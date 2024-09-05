import 'package:filmstore/components/filter_chip_row.dart';
import 'package:flutter/material.dart';

import '../Entities/FilmStock.dart';
import '../api.dart';

class Stocks extends StatefulWidget {
  List<Widget> filmStockCards;
  String? error;
  BuildContext? context;

  Stocks(this.filmStockCards, {super.key});

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
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    widget.context = context;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: RefreshIndicator(
        // onRefresh: () async => widget.getStocks(() => setState(() {})),
        onRefresh: () async {},
        child: (widget.error == null) ? SingleChildScrollView(
          child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).viewPadding.top),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 0, 4),
              child: FilterChipRow(
                filters: const ["All", "B/W Pan", "B/W Ortho", "Color", "Infrared"],
                onSelected: (int selection, String selected) {
                  widget.filmStockCards = [];
                  if(selection == 0) {
                    for (FilmStock stock in Api.globalStocks ?? []) {
                      widget.filmStockCards.add(stock.build(context));
                      widget.filmStockCards.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
                    }
                  } else {
                    for (FilmStock stock in Api.globalStocks ?? []) {
                      if (stock.type == FilmType.values[selection]) {
                        widget.filmStockCards.add(stock.build(context));
                        widget.filmStockCards.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
                      }
                    }
                    if(widget.filmStockCards.isEmpty) {
                      widget.filmStockCards.add(SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height - 140,
                        child: Center(
                          child: Text((selection == 0) ? "No Stock on Database" : "No Stock with this type")
                        )
                      ));
                    }
                  }
                  setState(() {});
                },
              )
            )
          ] + widget.filmStockCards,
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