import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:offlineblog/models/blog_item.dart';
import 'package:offlineblog/utilities/utility.dart';

class BlogItemViewScreen extends StatelessWidget {
  final BlogItem? blogItem;

  BlogItemViewScreen({required this.blogItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blogItem?.title ?? ''),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image.file(blogItem?.image),
            Container(
              padding: EdgeInsets.all(10), 
              width: double.infinity,
              decoration: BoxDecoration( 
                borderRadius: BorderRadius.all(Radius.circular(10)),
               
              ),
              child: Image.memory(Utility.dataFromBase64String(blogItem?.image??'')),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                blogItem?.body ?? '',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Posted on: ${DateFormat.yMMMd().format(blogItem?.date ?? DateTime(2023))}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
