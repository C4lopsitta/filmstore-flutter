import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateFilmroll extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _CreateFilmroll();
}

class _CreateFilmroll extends State<CreateFilmroll> {
  TextEditingController camera = TextEditingController();
  TextEditingController identifier = TextEditingController();

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
        ],
      )),
    );
  }
}


