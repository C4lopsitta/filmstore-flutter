import 'package:flutter/material.dart';
import '../Entities/FilmRoll.dart';

import '../api.dart';
import '../components/filter_chip_row.dart';

class Rolls extends StatefulWidget {
  List<Widget> filmrolls_cards = [];
  String? error;

  void getFilmRolls(void Function() update) async {
    try {
      Api.globalRolls = null;
      error = null;
      filmrolls_cards = [];
      update();
      Api.globalRolls = (await Api.getFilmRolls()).toSet();

      if(Api.globalRolls!.isEmpty) throw ApiException(statusCode: 200, apiError: "No Rolls available");

      for(FilmRoll roll in Api.globalRolls!) {
        filmrolls_cards.add(roll.build());
        filmrolls_cards.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
      }
    } on ApiException catch (ex, st) {
      error = ex.apiError;
    } catch (ex, st) {
      error = ex.toString() + "\n" + st.toString();
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
            SizedBox(height: MediaQuery.of(context).viewPadding.top),
            Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 0, 4),
                child: FilterChipRow(
                  filters: const ["All", "In Camera", "To Develop", "Developed", "Scanned", "Archived"],
                  onSelected: (int selection, String selected) {
                    widget.filmrolls_cards = [];
                    if(selection == 0) {
                      for (FilmRoll roll in Api.globalRolls ?? []) {
                        widget.filmrolls_cards.add(roll.build());
                        widget.filmrolls_cards.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
                      }
                    } else {
                      for (FilmRoll roll in Api.globalRolls ?? [])
                        if (roll.status == FilmStatus.values[selection]) {
                          widget.filmrolls_cards.add(roll.build());
                          widget.filmrolls_cards.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
                        }
                      if(widget.filmrolls_cards.isEmpty)
                        widget.filmrolls_cards.add(SizedBox(
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