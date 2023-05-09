// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

class Utility {
  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }

  static Uint8List dataFromBase64String(String base64String) {
    Uint8List bytesImage = Base64Decoder().convert(base64String);
    // print(bytesImage);
    return bytesImage;
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }
}
