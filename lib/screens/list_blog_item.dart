import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:animation_search_bar/animation_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:offlineblog/models/blog_item.dart';
import 'package:offlineblog/screens/blog_item_view_screen.dart';
import 'package:offlineblog/screens/edit_blog.dart';
import 'package:offlineblog/utilities/utility.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class BlogItemListScreen extends StatefulWidget {
  @override
  _BlogItemListScreenState createState() => _BlogItemListScreenState();
}

Future<Database> createDatabase() async {
  final dbPath = await getDatabasesPath();
  final db = await openDatabase(
    path.join(dbPath, 'blog.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE items(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, body TEXT, date TEXT, image BLOB)',
      );
    },
    version: 1,
  );
  return db;
}

class _BlogItemListScreenState extends State<BlogItemListScreen> {
  List<BlogItem> _items = [];
  List<BlogItem> _filteredItems = [];
  List<int> _selectedItemIds = [];

  // @override
  // void initState() {
  //   super.initState();

  //   _loadBlogItems();
  // }

  Future<void> _loadBlogItems() async {
    final db = await createDatabase();
    log('jjjjjjjjjjj   message');
    final maps = await db.query('items', orderBy: 'date DESC');
    final items = List.generate(maps.length, (i) {
      print(maps[i]['image']);
      return BlogItem(
        id: maps[i]['id'] as int,
        title: maps[i]['title'] as String,
        date: DateTime.parse(maps[i]['date'].toString()),
        body: maps[i]['body'] as String,
        image: maps[i]['image'] as String,
      );
    });

    setState(() {
      _items = items;
      _filteredItems = _items;
    });
  }

  bool _searching = false;
  final _searchController = TextEditingController();

  void _filterItems(String query) {
    final data = _filteredItems.where((element) {
      final listTitle = element.title!.toLowerCase();
      final input = query.toLowerCase();

      return listTitle.contains(input);
    }).toList();

    setState(() => _items = data);
  }

  Future<void> shareViaEmail(BuildContext context, BlogItem item) async {
    final Email email = Email(
      subject: 'Check out this blog post: ${item.title}',
      body: item.body ?? 'No body',
      recipients: [],
      attachmentPaths: [item.image??''],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send email: $error'),
        ),
      );
    }
  }

  Future<void> _deleteBlogItem(int id) async {
    final db =
        await openDatabase(path.join(await getDatabasesPath(), 'blog.db'));
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
    await _loadBlogItems();
  }

  void _deleteSelectedItems() async {
    final db =
        await openDatabase(path.join(await getDatabasesPath(), 'blog.db'));
    for (final itemId in _selectedItemIds) {
      await db.delete('items', where: 'id = ?', whereArgs: [itemId]);
    }

    setState(() {
      _selectedItemIds.clear();
      _loadBlogItems();
    });
  }

  void _selectItem(int itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Blog'),
        actions: [
          if (_selectedItemIds.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedItems,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.all(8.0),
              child: AnimationSearchBar(
                  centerTitle: 'Search Blog',
                  searchBarWidth: 300,
                  onChanged: (text) {
                    _items
                        .where((element) =>
                            element.title!.contains(text.toLowerCase()))
                        .toList();
                    setState(() {});
                  },
                  searchTextEditingController: _searchController)),
          Expanded(
            child: FutureBuilder<void>(
                future: _loadBlogItems(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  return ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      // final Uint8List imageData;
                      //  imageData = base64Decode(_items[index].image??'');
                      //  log(imageData.toString());
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          elevation: 10.0,
                          shadowColor: Colors.blueGrey,
                          child: ExpansionTile(
                            leading: CircleAvatar(
                                backgroundImage: MemoryImage(
                                    Utility.dataFromBase64String(
                                        _items[index].image ?? ''))),
                            // const CircleAvatar(
                            //   backgroundImage: NetworkImage(
                            //       'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTU5p92GAwP9v_iTfpZ-JqDSZyNI6TrKdiqWEy_fUnoxw&usqp=CAU&ec=48600113'),
                            // ),
                            subtitle: Text(
                              _items[index].body ?? '',
                              style: TextStyle(overflow: TextOverflow.fade),
                            ),
                            title: Text(_items[index].title ?? ''),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditBlogItemScreen(
                                                      item: item),
                                            ),
                                          ).then((value) {
                                            if (value == true) {
                                              _loadBlogItems();
                                            }
                                          });
                                        },
                                        child: const Text(
                                          'Edit',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          shareViaEmail(context, item);
                                        },
                                        child: const Text(
                                          'Share',
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ),
                                      GestureDetector(
                                        child: const Text(
                                          'View',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BlogItemViewScreen(
                                                      blogItem: _items[index]),
                                            ),
                                          );
                                        },
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Delete item?'),
                                                content: Text(
                                                    'Are you sure you want to delete this item?'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Delete'),
                                                    onPressed: () {
                                                      _deleteBlogItem(
                                                          _items[index].id ??
                                                              0);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      Checkbox(
                                        value: _selectedItemIds
                                            .contains(_items[index].id),
                                        onChanged: (_) =>
                                            _selectItem(_items[index].id ?? 0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Checkbox(
                          //   value: _selectedItemIds
                          //       .contains(_items[index].id),
                          //   onChanged: (_) =>
                          //       _selectItem(_items[index].id ?? 0),
                          // ),
                          // onTap: () {
                          //   // setState(() {
                          //   //   _items[index].isVisible =
                          //   //       !_items[index].isVisible;
                          //   // });
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => BlogItemViewScreen(
                          //           blogItem: _items[index]),
                          //     ),
                          //   );
                          // },
                        ),
                      );
                    },
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditBlogItemScreen()),
          ).then((value) {
            if (value == true) {
              _loadBlogItems();
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
