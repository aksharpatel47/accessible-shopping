import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_app/components/image_preview.dart';
import 'package:path_provider/path_provider.dart';

class CameraPreviewWidget extends StatefulWidget {
  @override
  _CameraPreviewWidgetState createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  List<CameraDescription> cameras;
  CameraController cameraController;

  Future<void> getAvailableCameras() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await cameraController.initialize();

    setState(() {});
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future<String> takePicture() async {
    final extDir = await getApplicationDocumentsDirectory();
    final dirPath = "${extDir.path}/AccessibleShopping";
    await Directory(dirPath).create(recursive: true);
    final filePath = "$dirPath/test.jpg";

    final file = File(filePath);
    final fileExists = await file.exists();
    if (fileExists) {
      await file.delete();
    }

    if (cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      await cameraController.takePicture(filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }

    return filePath;
  }

  Widget buildCameraWidget() {
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: cameraController.value.aspectRatio,
          child: CameraPreview(cameraController),
        ),
        RaisedButton(
          child: Text(
            "Click",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          color: Colors.blue,
          onPressed: () async {
            final filePath = await takePicture();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraImagePreview(
                  filePath: filePath,
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget buildNoCameraWidget() {
    return Center(
      child: Text("No Cameras Available"),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cameras == null) {
      getAvailableCameras();
      return buildNoCameraWidget();
    }

    return buildCameraWidget();
  }
}
