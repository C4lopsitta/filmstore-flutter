import 'package:filmstore/preferences_keys.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => _Settings();
}

class _Settings extends State<Settings> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  SharedPreferences? preferences;
  void initialize() async {
    preferences = await SharedPreferences.getInstance();
  }

  bool authEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).viewPadding.top),
          const Text("API Address"),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Address"),
              hintText: "Include http:// or https:// and port"
            ),
            onSubmitted: (String newValue) async {
              if(preferences != null) {
                newValue.replaceAll(RegExp(r"/$"), '');
                await preferences!.setString(PreferencesKeys.address, newValue);
              }
            },
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text("Requires authentication"),
            subtitle: const Text("Currently unsupported by API"),
            value: authEnabled,
            onChanged: (bool? newValue) {

            }
          ),
          const SizedBox(height: 12),
          TextField(
              enabled: authEnabled,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Username")
              )
          ),
          const SizedBox(height: 12),
          TextField(
            enabled: authEnabled,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Password")
              )
          )
        ],
      )
    );
  }
}