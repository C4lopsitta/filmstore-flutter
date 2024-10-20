import 'package:filmstore/preferences_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../filmstore_api.dart';


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
  TextEditingController preferredColumnsController = TextEditingController();

  SharedPreferences? preferences;
  void initialize() async {
    preferences = await SharedPreferences.getInstance();

    addressController.text = preferences?.getString(PreferencesKeys.address) ?? "";
    useDiscovery = preferences?.getBool(PreferencesKeys.useDiscovery) ?? true;
    preferredColumnsController.text = "${preferences?.getInt(PreferencesKeys.pictureColumnsView) ?? 3}";
    setState(() {});
  }

  bool authEnabled = false;
  bool useDiscovery = false;
  bool discoveringService = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).viewPadding.top),

            //region API_address
            const Text("Api address"),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: const Text("Address"),
                hintText: "Include http:// or https:// and port",
                error: addressError,
              ),
              enabled: !useDiscovery,
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
                title: const Text("Use automatic discovery"),
                subtitle: const Text("Use an mDNS query for FilmStore API to automatically set the address."),
                value: useDiscovery,
                onChanged: (bool? newValue) {
                  preferences?.setBool(PreferencesKeys.useDiscovery, newValue ?? true);
                  useDiscovery = !useDiscovery;
                  setState(() {});
                }
            ),
            const SizedBox(height: 12),
            SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: OutlinedButton(
                    onPressed: (useDiscovery) ? () async {
                      discoveringService = true;
                      setState(() {});
                      await Api.discoverApi();
                      addressController.text = preferences?.getString(PreferencesKeys.address) ?? "";
                      addressError = null;
                      discoveringService = false;
                      setState(() {});
                    } : null,
                    child: (discoveringService) ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(),
                    ) :
                    const Text("Discover service")
                )
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
            ),
            //endregion
            const Divider(),

            //region User_Preferences
            const Text("User Preferences"),
            const SizedBox(height: 12),

            TextField(
              controller: preferredColumnsController,
              keyboardType: TextInputType.number,
              // TODO)) Add integer verification
              decoration: const InputDecoration(
                border: const OutlineInputBorder(),
                label: const Text("Columns"),
                hintText: "3",
              ),
              onSubmitted: (String newValue) async {
                if(preferences != null) {
                  if(preferredColumnsController.text.isEmpty) return;
                  try {
                    int newValue = int.parse(preferredColumnsController.text);
                    preferences!.setInt(PreferencesKeys.pictureColumnsView, newValue);
                  } catch (ex) {

                  } finally {
                    setState(() {});
                  }
                }
              },
            ),
            const SizedBox(height: 12),

            //endregion


          ],
        ),
      )
    );
  }
}