import 'dart:io';

import 'package:filmstore/Routes/Settings.dart';
import 'package:filmstore/components/show_dialog.dart';
import 'package:filmstore/routes/create_filmroll.dart';
import 'package:filmstore/routes/create_filmstock.dart';
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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      Api.globalStocks = (await Api.getFilmStocks()).toSet();
      Api.globalRolls = await Api.getFilmRolls();

      for(FilmRoll roll in Api.globalRolls!) {
        filmRollCards.add(roll.build());
        filmRollCards.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
      }

      for(FilmStock stock in Api.globalStocks!) {
        filmStockCards.add(stock.build(context));
        filmStockCards.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()));
      }

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
        FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateFilmroll())).then((value) async {
                  Api.globalRolls = await Api.getFilmRolls();
                  setState(() {});
              });
            },
            tooltip: "Create film roll",
            icon: const Icon(Icons.add_rounded),
            label: const Text("New Film Roll")
        ) : (currentPageIndex == 1) ?
        FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateFilmstock())).then((value) async {
                    Api.globalStocks = (await Api.getFilmStocks()).toSet();
                    setState(() {});
              });
            },
            tooltip: "Add new stock",
            icon: const Icon(Icons.add_rounded),
            label: const Text("New Stock"),
        ) : null,
        body: [
          Rolls(filmRollCards),
          Stocks(filmStockCards),
          Pictures(),
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
