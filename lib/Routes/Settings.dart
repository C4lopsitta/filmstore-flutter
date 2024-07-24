import 'package:filmstore/preferences_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api.dart';


class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => _Settings();
}

class _Settings extends State<Settings> {
  Widget? addressError;


  @override
  void initState() {
    super.initState();
    initialize();
  }

  TextEditingController addressController = TextEditingController();

  SharedPreferences? preferences;
  void initialize() async {
    preferences = await SharedPreferences.getInstance();

    addressController.text = preferences?.getString(PreferencesKeys.address) ?? "";
    setState(() {});
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
            controller: addressController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              label: const Text("Address"),
              hintText: "Include http:// or https:// and port",
              error: addressError,
            ),
            onSubmitted: (String newValue) async {
              if(preferences != null) {
                newValue.replaceAll(RegExp(r"/$"), '');
                await preferences!.setString(PreferencesKeys.address, newValue);

                try {
                  bool works = await Api.testApiAddress();
                  if(!works) throw Exception();
                  addressError = null;
                } catch (e) {
                  addressError = const Text(
                    "No response, address saved anyway",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  );
                } finally {
                  setState(() {});
                }
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
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: OutlinedButton(
              onPressed: (authEnabled) ? () {

              } : null,
              child: const Text("Create Account")
            )
          )
        ],
      )
    );
  }
}