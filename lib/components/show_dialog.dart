import 'package:flutter/material.dart';

void contextualErrorDialogShower(
    BuildContext context,
    Icon icon,
    Widget title,
    Widget description, {
    Function(dynamic)? callback }) {
  if(context.mounted) {
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        icon: icon,
        title: title,
        content: description,
      );
    }).then((result) {
      if(callback != null) callback(result);
    });
  }
}