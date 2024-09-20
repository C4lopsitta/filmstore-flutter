import 'package:filmstore/components/picture_square.dart';
import 'package:filmstore/preferences_keys.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api.dart';

class Pictures extends StatefulWidget {
  Pictures(this.pictureCards, {super.key});

  List<PictureSquare> pictureCards = [];


  @override
  State<StatefulWidget> createState() => _Pictures();
}

class _Pictures extends State<Pictures> {
  SharedPreferences? preferences;
  int userPreferredColumns = 3;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    preferences = await SharedPreferences.getInstance();

    userPreferredColumns = preferences?.getInt(PreferencesKeys.pictureColumnsView) ?? 3;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: GridView.count(
        crossAxisCount: userPreferredColumns,
        // childAspectRatio: 1,
        crossAxisSpacing: 12,
        addAutomaticKeepAlives: true,
        mainAxisSpacing: 12,
        padding: const EdgeInsets.all(12),
        children: widget.pictureCards
      ),
    );
  }
}