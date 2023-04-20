import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:path/path.dart' as path;

class BlogItem {
  final int? id;
  final String? title;
  final DateTime? date;
  final String? body;
  final File? image;
  bool selected;

  BlogItem(
      {this.id,
      this.title,
      this.date,
      this.body,
      this.image,
      this.selected = false});

  factory BlogItem.fromMap(Map<String, dynamic> map) {
    return BlogItem(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      body: map['body'],
      image: map['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(date!),
      'body': body,
      'image': image,
    };
  }
}
