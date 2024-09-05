import 'dart:io';

import 'package:filmstore/Entities/FilmRoll.dart';
import 'package:filmstore/api.dart';
import 'package:filmstore/components/show_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Entities/FilmStock.dart';

class UploadPhoto extends StatefulWidget {
  const UploadPhoto({super.key});

  @override
  State<StatefulWidget> createState() => _UploadPhoto();
}

class _UploadPhoto extends State<UploadPhoto> {
  File? image;
  final imagePicker = ImagePicker();
  TextEditingController desc = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController aperture = TextEditingController();
  TextEditingController shutterSpeed = TextEditingController();

  Future<void> pickImage() async {
    PermissionStatus status = await Permission.mediaLibrary.request();

    if (status.isGranted) {
      try {
        final XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

        setState(() {
          image = pickedFile != null ? File(pickedFile.path) : null;
        });
      } catch (e) {
        print("Error picking image: $e");
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // TODO)) Add error popup
    }

  }

  // late TextEditingController camera;
  // TextEditingController identifier = TextEditingController();
  // int status = 1;
  // int selectedFilmDBId = 0;
  //
  // List<DropdownMenuEntry> statuses = [];
  // List<DropdownMenuEntry> filmStocks = [];
  // Set<String> cameraSuggestions = {};

  @override
  void initState() {
    super.initState();

    // for(FilmStatus status in FilmStatus.values) {
    //   if(status != FilmStatus.UNDEFINED)
    //     statuses.add(DropdownMenuEntry(value: status.index, label: status.toUserString()));
    // }
    //
    // filmStocks.add(const DropdownMenuEntry(value: -1, label: "Select a film stock"));
    //
    // for(FilmRoll roll in Api.globalRolls ?? []) {
    //   cameraSuggestions.add(roll.camera);
    // }
  }

  @override
  void didChangeDependencies() async {
    // initStocks();
    setState(() {});
    super.didChangeDependencies();
  }
  //
  // Future<void> initStocks() async {
  //   if(Api.globalStocks?.isEmpty ?? true) {
  //     try {
  //       Api.globalStocks = (await Api.getFilmStocks()).toSet();
  //     } on ApiException catch (ex) {
  //       contextualErrorDialogShower(
  //           context,
  //           const Icon(Icons.error_rounded),
  //           const Text("API Error"),
  //           Text(ex.apiError)
  //       );
  //     } on ClientException catch (ex) {
  //       contextualErrorDialogShower(
  //           context,
  //           const Icon(Icons.error_rounded),
  //           const Text("API Error"),
  //           Text(ex.message),
  //           callback: (_) => Navigator.pop(context)
  //       );
  //     } catch (ex) {
  //       contextualErrorDialogShower(
  //           context,
  //           const Icon(Icons.error_rounded),
  //           const Text("API Error"),
  //           Text(ex.toString())
  //       );
  //     }
  //   }
  //
  //   if(filmStocks.isEmpty) {
  //     if(context.mounted) {
  //       showDialog(context: context, builder: (BuildContext context) {
  //         return AlertDialog(
  //           icon: const Icon(Icons.warning_rounded),
  //           title: Text("No Film Stock available"),
  //           content: Text("Try adding a stock before adding a roll."),
  //         );
  //       });
  //     }
  //     return;
  //   }
  //
  //   filmStocks = [];
  //
  //   for(FilmStock stock in Api.globalStocks!) {
  //     filmStocks.add(DropdownMenuEntry(
  //         value: stock.dbId,
  //         label: stock.name,
  //         labelWidget:stock.toMenuEntry()),
  //     );
  //   }
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Film Roll"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {

        },
        child: const Icon(Icons.save_rounded),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              (image == null) ?  Center(
                  // TODO)) Fix alignment
                  child: Column(
                    children: [
                      const Text("Choose an image to upload"),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.5,
                        child: OutlinedButton(
                          onPressed: () async {
                            await pickImage();
                            setState(() {});
                          },
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Icon(Icons.upload_rounded), SizedBox(width: 6), Text("Choose image")]
                            )
                          )
                        )
                      ),
                    ],
                  ),
              ) : Padding(padding: const EdgeInsets.all(0),
                child: Stack(
                  alignment: Alignment.topLeft,
                  fit: StackFit.passthrough,
                  children: [
                    Image.file(image!, width: MediaQuery.sizeOf(context).width, height: MediaQuery.sizeOf(context).height * 0.35),
                    IconButton(
                      onPressed: () {
                        image = null;
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded)
                    ),
                  ]
                )
              ),
              const SizedBox(height: 12),
              TextField(
                controller: desc,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Description")
                ),
                maxLines: 8,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: location,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Location")
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: shutterSpeed,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffix: Text("s"),
                    label: Text("Shutter Speed")
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: aperture,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefix: Text("f"),
                    label: Text("Aperture")
                ),
                keyboardType: TextInputType.number,
              ),

            ]
          )
        )
      ),
    );
  }
}