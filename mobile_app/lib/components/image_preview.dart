import 'dart:io';

import 'package:flutter/material.dart';

class CameraImagePreview extends StatefulWidget {
  String filePath;
  CameraImagePreview({this.filePath});

  @override
  _CameraImagePreviewState createState() => _CameraImagePreviewState();
}

class _CameraImagePreviewState extends State<CameraImagePreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details"),
      ),
      body: Container(
        child: Image.file(
          File(widget.filePath),
        ),
      ),
    );
  }
}
