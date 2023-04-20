import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:offlineblog/models/blog_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class EditBlogItemScreen extends StatefulWidget {
  final BlogItem? item;

  EditBlogItemScreen({this.item});

  @override
  _EditBlogItemScreenState createState() => _EditBlogItemScreenState();
}

class _EditBlogItemScreenState extends State<EditBlogItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  File? _imagePath;

  @override
  void initState() {
    super.initState();

    if (widget.item != null) {
      _titleController.text = widget.item?.title ?? '';
      _bodyController.text = widget.item?.body ?? '';
      _imagePath = widget.item?.image;
    }
  }

  Future<void> _selectImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imagePath = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'New Blog Item' : 'Edit Blog Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _bodyController,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'Body',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              if (_imagePath != null)
                Image.file(File(_imagePath.toString()), height: 200.0),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: _selectImageFromGallery,
                    child: Text('Select Image'),
                  ),
                  TextButton(
                    onPressed: _takePhoto,
                    child: Text('Take Photo'),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final title = _titleController.text;
                    final body = _bodyController.text;
                    final image = _imagePath;

                    if (widget.item != null) {
                      final db = await openDatabase(
                          path.join(await getDatabasesPath(), 'blog.db'));
                      await db.update(
                        'items',
                        BlogItem(
                                id: widget.item?.id,
                                title: title,
                                date: widget.item?.date,
                                body: body,
                                image: image)
                            .toMap(),
                        where: 'id = ?',
                        whereArgs: [widget.item?.id],
                      );
                    } else {
                      final db = await openDatabase(
                          path.join(await getDatabasesPath(), 'blog.db'));
                      await db.insert(
                        'items',
                        BlogItem(
                                title: title,
                                date: DateTime.now(),
                                body: body,
                                image: image)
                            .toMap(),
                      );
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
