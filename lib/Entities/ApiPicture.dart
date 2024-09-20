import 'dart:core';
import 'dart:core';
import 'dart:io';

class ApiPicture {
  ApiPicture({
    this.dbId,
    this.isPosted = false,
    this.isPrinted = false,
    this.location,
    this.shutterSpeed,
    this.aperture,
    this.description,
    this.thumbnailFileName,
    this.imageFile
  });

  int? dbId;
  bool isPosted;
  bool isPrinted;
  String? description;
  String? location;
  String? aperture;
  String? shutterSpeed;
  String? thumbnailFileName;
  File? imageFile;

  factory ApiPicture.fromJson(Map<String, dynamic> json) {
    ApiPicture picture = ApiPicture(
      dbId: json["id"],
      description: json["desc"],
      thumbnailFileName: json["thumbnail"],
      isPosted: json["posted"],
      isPrinted: json["printed"],
      location: json["location"],
      aperture: json["aperture"],
      shutterSpeed: json["shutter_speed"]
    );
    return picture;
  }

}