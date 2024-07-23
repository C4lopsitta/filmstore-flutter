import 'dart:convert';

import 'package:filmstore/Entities/FilmStock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../api.dart';

class CreateFilmstock extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _CreateFilmstock();
}

class _CreateFilmstock extends State<CreateFilmstock> {
  bool saving = false;
  int selectedType = 1;

  TextEditingController name = TextEditingController();
  TextEditingController iso = TextEditingController();
  TextEditingController info = TextEditingController();

  List<DropdownMenuEntry<int>> types = [];

  @override
  void initState() {
    super.initState();
    FilmType.values.forEach((type) {
      if(type != FilmType.UNDEFINED)
        types.add(DropdownMenuEntry(value: type.index, label: type.toUserString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Film Stock")
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          saving = true;
          setState(() {});

          http.post(
            await Api.buildUri("/films"),
            body: """
            {
              "name": "${name.text}",
              "iso": ${iso.text},
              "development_info": "${info.text}",
              "type": $selectedType
            }
            """
          ).then((result) {
            if(result.statusCode != 200) {
            } else {
              Navigator.pop(context);
            }
          });
        },
        child: (saving) ? const CircularProgressIndicator() : const Icon(Icons.save_rounded),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Name")
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox( width: MediaQuery.sizeOf(context).width * 0.4,
              child: TextField(
                controller: iso,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("ISO")
                ),
              )),
              const SizedBox(width: 13),
              DropdownMenu(
                initialSelection: 1,
                onSelected: (value) { selectedType = value ?? 1; },
                dropdownMenuEntries: types,
                width: MediaQuery.sizeOf(context).width * 0.5,
              )
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: info,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Details")
            ),
            maxLines: 8,
          ),
        ],
      )
      )
    );
  }
}


