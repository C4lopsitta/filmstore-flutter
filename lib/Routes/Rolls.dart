import 'package:flutter/material.dart';
import '../Entities/FilmRoll.dart';

import '../api.dart';
import '../components/filter_chip_row.dart';

class Rolls extends StatefulWidget {
  List<Widget> filmRollCards;
  String? error;

  Rolls(this.filmRollCards, {super.key});
  //
  // void getFilmRolls(void Function() update) async {
  //   try {
  //     Api.globalRolls = null;
  //     error = null;
  //     filmrolls_cards = [];
  //     update();
  //     Api.globalRolls = (await Api.getFilmRolls());
  //
  //     if(Api.globalRolls!.isEmpty) throw ApiException(statusCode: 200, apiError: "No Rolls available");
  //
  //     for(FilmRoll roll in Api.globalRolls!) {
  //       filmrolls_cards.add(roll.build());
  //       filmrolls_cards.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
  //     }
  //   } on ApiException catch (ex, st) {
  //     error = ex.apiError;
  //   } catch (ex, st) {
  //     error = "$ex\n$st";
  //   } finally {
  //     update();
  //   }
  // }

  @override
  State<StatefulWidget> createState() => _Rolls();
}

class _Rolls extends State<Rolls> {
  @override
  void initState() {
    super.initState();
    // widget.getFilmRolls(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    // widget.getFilmRolls(() => setState(() {}));
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: RefreshIndicator(
        // onRefresh: () async => widget.getFilmRolls(() => setState(() {})),
        onRefresh: () async {},
        child: (widget.error == null) ? SingleChildScrollView(
          child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).viewPadding.top),
            Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 0, 4),
                child: FilterChipRow(
                  filters: const ["All", "In Camera", "To Develop", "Developed", "Scanned", "Archived"],
                  onSelected: (int selection, String selected) {
                    widget.filmRollCards = [];
                    if(selection == 0) {
                      for (FilmRoll roll in Api.globalRolls ?? []) {
                        widget.filmRollCards.add(roll.build());
                        widget.filmRollCards.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
                      }
                    } else {
                      for (FilmRoll roll in Api.globalRolls ?? [])
                        if (roll.status == FilmStatus.values[selection]) {
                          widget.filmRollCards.add(roll.build());
                          widget.filmRollCards.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
                        }
                      if(widget.filmRollCards.isEmpty)
                        widget.filmRollCards.add(SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height,
                          child: Center(
                            child: Text("No Roll in this Status")
                          )
                        ));
                    }
                    setState(() {});
                  },
                )
            )
          ] + widget.filmRollCards,
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