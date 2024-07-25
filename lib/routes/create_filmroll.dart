import 'package:filmstore/Entities/FilmRoll.dart';
import 'package:filmstore/api.dart';
import 'package:filmstore/components/show_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../Entities/FilmStock.dart';

class CreateFilmroll extends StatefulWidget {
  const CreateFilmroll({super.key});

  @override
  State<StatefulWidget> createState() => _CreateFilmroll();
}

class _CreateFilmroll extends State<CreateFilmroll> {
  TextEditingController camera = TextEditingController();
  TextEditingController identifier = TextEditingController();
  int status = 1;
  int selectedFilmDBId = 0;

  List<DropdownMenuEntry> statuses = [];
  List<DropdownMenuEntry> filmStocks = [];

  @override
  void initState() {
    super.initState();

    for(FilmStatus status in FilmStatus.values) {
      if(status != FilmStatus.UNDEFINED)
        statuses.add(DropdownMenuEntry(value: status.index, label: status.toUserString()));
    }

    filmStocks.add(const DropdownMenuEntry(value: -1, label: "Select a film stock"));
  }

  @override
  void didChangeDependencies() async {
    initStocks();
    setState(() {});
    super.didChangeDependencies();
  }

  Future<void> initStocks() async {
    if(Api.globalStocks?.isEmpty ?? true) {
      try {
        Api.globalStocks = (await Api.getFilmStocks()).toSet();
      } on ApiException catch (ex) {
        contextualErrorDialogShower(
          context,
          const Icon(Icons.error_rounded),
          const Text("API Error"),
          Text(ex.apiError)
        );
      } on ClientException catch (ex) {
        contextualErrorDialogShower(
          context,
          const Icon(Icons.error_rounded),
          const Text("API Error"),
          Text(ex.message),
          callback: (_) => Navigator.pop(context)
        );
      } catch (ex) {
        contextualErrorDialogShower(
          context,
          const Icon(Icons.error_rounded),
          const Text("API Error"),
          Text(ex.toString())
        );
      }
    }

    if(filmStocks.isEmpty) {
      if(context.mounted) {
        showDialog(context: context, builder: (BuildContext context) {
          return AlertDialog(
            icon: const Icon(Icons.warning_rounded),
            title: Text("No Film Stock available"),
            content: Text("Try adding a stock before adding a roll."),
          );
        });
      }
      return;
    }

    filmStocks = [];

    for(FilmStock stock in Api.globalStocks!) {
      filmStocks.add(DropdownMenuEntry(value: stock.dbId, label: stock.name));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Film Roll"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          FilmStock? selectedStock;

          if(selectedFilmDBId < 0) return;

          // TODO)) Add binary search
          for(FilmStock stock in Api.globalStocks!) {
            if(stock.dbId == selectedFilmDBId) selectedStock = stock;
          }

          if(selectedStock == null) return;

          FilmRoll roll = FilmRoll(
            camera: camera.text,
            identifier: identifier.text,
            picturesId: [],
            status: FilmStatus.values[status],
            dbId: 0,
            film: selectedStock
          );

          try {
            await Api.createFilmRoll(roll);
            Navigator.pop(context);
          } on ApiException catch (ex) {
            if(context.mounted) {
              showDialog(context: context, builder: (BuildContext context) {
                return AlertDialog(
                  icon: const Icon(Icons.error_rounded),
                  title: const Text("API Error"),
                  content: Text(ex.apiError),
                );
              });
              }
          } catch (ex) {
            if(context.mounted) {
              showDialog(context: context, builder: (BuildContext context) {
                return AlertDialog(
                  icon: const Icon(Icons.error_rounded),
                  title: const Text("Error"),
                  content: Text(ex.toString()),
                );
              });
            }
          }
        },
        child: const Icon(Icons.save_rounded),
      ),
      body: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: camera,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Camera")
            )
          ),
          const SizedBox(height: 12),
          TextField(
            controller: identifier,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Archival Identifier")
            )
          ),
          if(filmStocks.isNotEmpty) const SizedBox(height: 12),
          if(filmStocks.isNotEmpty) DropdownMenu(
            label: const Text("Film"),
            onSelected: (selectedValue) => selectedFilmDBId = selectedValue ?? 1,
            dropdownMenuEntries: (filmStocks.isEmpty) ? [
              const DropdownMenuEntry(value: -1, label: "")
            ] : filmStocks,
            width: MediaQuery.sizeOf(context).width - 25,
          ),
          const SizedBox(height: 12),
          DropdownMenu(
            initialSelection: 1,
            label: const Text("Status"),
            onSelected: (selectedValue) => status = selectedValue ?? 1,
            dropdownMenuEntries: statuses,
            width: MediaQuery.sizeOf(context).width - 25,
          )
        ],
      )),
    );
  }
}


