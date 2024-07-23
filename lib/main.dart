import 'package:filmstore/Settings.dart';
import 'package:filmstore/routes/create_filmroll.dart';
import 'package:filmstore/routes/create_filmstock.dart';
import 'package:flutter/material.dart';

import 'Brands.dart';
import 'Home.dart';

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: (currentPageIndex == 0) ?
        FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateFilmroll())
              );
            },
            tooltip: "Create film roll",
            icon: const Icon(Icons.add_rounded),
            label: const Text("New Film Roll")
        ) :
        FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateFilmstock())
              );
            },
            tooltip: "Add new stock",
            icon: const Icon(Icons.add_rounded),
            label: const Text("New Stock"),
        ),
        body: [
          Home(),
          Brands(),
          Settings()
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
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: "Film Stocks",
              ),
            ],
          ),
        )
    );
  }
}
