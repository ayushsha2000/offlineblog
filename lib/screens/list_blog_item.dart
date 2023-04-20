import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:offlineblog/models/blog_item.dart';
import 'package:offlineblog/screens/blog_item_view_screen.dart';
import 'package:offlineblog/screens/edit_blog.dart';
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
        'CREATE TABLE items(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, body TEXT, date TEXT, image TEXT)',
      );
    },
    version: 1,
  );
  return db;
}

class _BlogItemListScreenState extends State<BlogItemListScreen> {
  List<BlogItem> _items = [];
  List<int> _selectedItemIds = [];

  @override
  void initState() {
    super.initState();

    _loadBlogItems();
  }

  Future<void> _loadBlogItems() async {
    final db = await createDatabase();

    final maps = await db.query('items', orderBy: 'date DESC');
    final items = List.generate(maps.length, (i) {
      return BlogItem(
        id: maps[i]['id'] as int,
        title: maps[i]['title'] as String,
        date: DateTime.parse(maps[i]['date'].toString()),
        body: maps[i]['body'] as String,
        // image: maps[i]['image'] as File,
      );
    });

    setState(() {
      _items = items;
      _filteredItems = items;
    });
  }

  List<BlogItem> _filteredItems = [];

  bool _searching = false;
  TextEditingController _searchController = TextEditingController();

  void _filterItems(String query) {
    setState(() {
      _items = _items.where((item) {
        final title = item.title!.toLowerCase();
        // final text = item.text.toLowerCase();
        final searchQuery = query.toLowerCase();
        return title.contains(searchQuery);
      }).toList();
    });
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
    bool _selectAll = false;

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
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                _filterItems(query);
              },
              decoration: const InputDecoration(
                hintText: 'Search for blog items...',
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<void>(
                future: _loadBlogItems(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  return ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];

                      return ListTile(
                        leading: 
                        // Image.file(File(_items[index].image.toString())),
                        Checkbox(
                          value: _selectedItemIds.contains(_items[index].id),
                          onChanged: (_) => _selectItem(_items[index].id ?? 0),
                        ),
                        title: Text(_items[index].title ?? ''),
                        subtitle: Text(_items[index].body ?? ''),
                        trailing: Container(
                          width: 150,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditBlogItemScreen(item: item),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      _loadBlogItems();
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.share),
                                onPressed: () {
                                  Share.share(
                                    '${_items[index].title}\n\n${_items[index].body}',
                                    subject: _items[index].title,
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
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
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Delete'),
                                            onPressed: () {
                                              _deleteBlogItem(
                                                  _items[index].id ?? 0);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BlogItemViewScreen(blogItem: _items[index]),
                            ),
                          );
                        },
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
