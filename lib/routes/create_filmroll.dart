import 'package:filmstore/Entities/FilmRoll.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateFilmroll extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _CreateFilmroll();
}

class _CreateFilmroll extends State<CreateFilmroll> {
  TextEditingController camera = TextEditingController();
  TextEditingController identifier = TextEditingController();

  List<DropdownMenuEntry> statuses = [];

  @override
  void initState() {
    for(FilmStatus status in FilmStatus.values) {
      if(status != FilmStatus.UNDEFINED)
        statuses.add(DropdownMenuEntry(value: status.index, label: status.toUserString()));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Film Roll"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        child: const Icon(Icons.add_rounded),
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
          const SizedBox(height: 12),
          DropdownMenu(
            initialSelection: 1,
            label: const Text("Status"),
            dropdownMenuEntries: statuses,
            width: MediaQuery.sizeOf(context).width - 25,
          )
        ],
      )),
    );
  }
}


