import 'dart:io';

import 'package:filmstore/Entities/ApiPicture.dart';
import 'package:filmstore/Routes/Settings.dart';
import 'package:filmstore/components/picture_square.dart';
import 'package:filmstore/components/show_dialog.dart';
import 'package:filmstore/routes/create_filmroll.dart';
import 'package:filmstore/routes/create_filmstock.dart';
import 'package:filmstore/routes/upload_photo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'Entities/FilmRoll.dart';
import 'Entities/FilmStock.dart';
import 'Routes/Pictures.dart';
import 'Routes/Stocks.dart';
import 'Routes/Rolls.dart';
import 'api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filmroll',
      darkTheme: ThemeData.dark(useMaterial3: true),
      theme: ThemeData.light(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const ApplicationRoot()
    );
  }
}

class ApplicationRoot extends StatefulWidget {
  const ApplicationRoot({super.key});

  @override
  State<ApplicationRoot> createState() => _ApplicationRoot();
}

class _ApplicationRoot extends State<ApplicationRoot> {
  int currentPageIndex = 0;
  List<Widget> filmRollCards = [];
  List<Widget> filmStockCards = [];
  List<PictureSquare> pictureCards = [];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  int lastPanTimestamp = 0;

  Future<void> fetchRolls() async {
    Api.globalRolls = [];
    Api.globalRolls = await Api.getFilmRolls();

    for(FilmRoll roll in Api.globalRolls!) {
      filmRollCards.add(roll.build());
      filmRollCards.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
    }
  }

  Future<void> fetchStocks() async {
      Api.globalStocks = <FilmStock>{};
      Api.globalStocks = (await Api.getFilmStocks()).toSet();

      for(FilmStock stock in Api.globalStocks!) {
        filmStockCards.add(stock.build(context));
        filmStockCards.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
      }
  }

  Future<void> fetchPictures() async {
    Api.globalPictures = [];
    Api.globalPictures = await Api.getPictures();

    for(ApiPicture picture in Api.globalPictures!) {
      pictureCards.add(PictureSquare(picture));
    }
  }

  void fetchData() async {
    try {
      await Api.discoverApi();
      filmRollCards = [];
      filmStockCards = [];
      pictureCards = [];
      await fetchRolls();
      await fetchStocks();
      await fetchPictures();
      setState(() {});
    } on ApiException catch (ex) {
      contextualErrorDialogShower(
          context,
          const Icon(Icons.warning_rounded),
          const Text("API Error"),
          Text(ex.apiError)
      );
    } on ClientException catch (ex) {
      contextualErrorDialogShower(
          context,
          const Icon(Icons.warning_rounded),
          const Text("Network Error"),
          Text(ex.message)
      );
    } catch (ex) {
      contextualErrorDialogShower(
          context,
          const Icon(Icons.warning_rounded),
          const Text("Error"),
          Text(ex.toString())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: (currentPageIndex == 0) ?
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.15,
          width: MediaQuery.sizeOf(context).width * 0.15,
          child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: FloatingActionButton.small(
                    onPressed: () {},
                    heroTag: "Search",
                    child: const Icon(Icons.search_rounded),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateFilmroll())).then((value) async {
                          filmRollCards = [];
                          await fetchRolls();
                          setState(() {});
                        });
                    },
                    tooltip: "Create film roll",
                    child: const Icon(Icons.add_rounded),
                  )
                )
              ]
            )
        )
         : (currentPageIndex == 1) ?
        FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateFilmstock())).then((value) async {
                    filmStockCards = [];
                    await fetchStocks();
                    setState(() {});
              });
            },
            tooltip: "Add new stock",
            icon: const Icon(Icons.add_rounded),
            label: const Text("New Stock"),
        ) : (currentPageIndex == 2) ? FloatingActionButton.extended(
            onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadPhoto())).then((value) async {
                    pictureCards = [];
                    await fetchPictures();
                    setState(() {});
                  });
            },
          tooltip: "Upload a photo",
          icon: const Icon(Icons.upload_rounded),
          label: const Text("Upload Photo"),
        ) : null,
        body: [
          Rolls(filmRollCards),
          Stocks(filmStockCards),
          Pictures(pictureCards),
          const Settings()
        ][currentPageIndex],

        bottomNavigationBar: GestureDetector(
          child: NavigationBar(
            onDestinationSelected: (int index) { setState((){ currentPageIndex = index; }); },
            selectedIndex: currentPageIndex,
            height: 80,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.local_movies_outlined),
                selectedIcon: Icon(Icons.local_movies_rounded),
                label: "Film Rolls",
              ),
              NavigationDestination(
                icon: Icon(Icons.camera_roll_outlined),
                selectedIcon: Icon(Icons.camera_roll_rounded),
                label: "Film Stocks",
              ),
              NavigationDestination(
                icon: Icon(Icons.image_outlined),
                selectedIcon: Icon(Icons.image_rounded),
                label: "Pictures"
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: "Settings",
              )
            ],
          ),
        )
    );
  }
}
