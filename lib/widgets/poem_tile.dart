import 'package:flutter/material.dart';
import '../models/poem.dart';

class PoemTile extends StatelessWidget {
  final Poem poem;
  final VoidCallback onTap;

  PoemTile({required this.poem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(poem.title),
      onTap: onTap,
    );
  }
}