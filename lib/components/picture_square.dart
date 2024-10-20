import 'dart:io';

import 'package:filmstore/Entities/ApiPicture.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../filmstore_api.dart';

class PictureSquare extends StatefulWidget {
  const PictureSquare(this.picture ,{super.key});

  final ApiPicture picture;

  @override
  State<StatefulWidget> createState() => _PictureSquare();
}

class _PictureSquare extends State<PictureSquare> {
  NetworkImage? image;

  @override
  void initState() {
    super.initState();
    if(widget.picture.thumbnailFileName != null) fetchPicture();
  }

  void fetchPicture() async {
    String url = (await Api.buildUri("/api/v1/pictures/file/${widget.picture.thumbnailFileName!}")).toString();
    image = NetworkImage(url);
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.29,
      child: Center(
        child: (image == null) ?
        const CircularProgressIndicator() :
        Image(image: image!),
      ),
    );
  }
}
