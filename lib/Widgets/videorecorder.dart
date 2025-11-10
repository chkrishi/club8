import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class VideoRecordScreen extends StatefulWidget {
  const VideoRecordScreen({super.key});

  @override
  State<VideoRecordScreen> createState() => _VideoRecordScreenState();
}

class _VideoRecordScreenState extends State<VideoRecordScreen> {
  List<CameraDescription>? cameras;
  CameraController? controller;
  bool isRecording = false;
  int selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    _setCamera(selectedCameraIndex);
  }

  Future<void> _setCamera(int index) async {
    final cam = cameras![index];
    controller =
        CameraController(cam, ResolutionPreset.high, enableAudio: true);
    await controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _toggleCamera() async {
    if (cameras == null || cameras!.length < 2) return;
    selectedCameraIndex = (selectedCameraIndex + 1) % cameras!.length;
    await _setCamera(selectedCameraIndex);
  }

  Future<void> _startRecording() async {
    if (controller == null || controller!.value.isRecordingVideo) return;

    final directory = await getTemporaryDirectory();
    final filePath = join(directory.path, '${DateTime.now()}.mp4');

    await controller!.startVideoRecording();
    setState(() => isRecording = true);
  }

  Future<void> _stopRecording() async {
    if (controller == null || !controller!.value.isRecordingVideo) return;

    final file = await controller!.stopVideoRecording();
    setState(() => isRecording = false);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Video saved to: ${file.path}')),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CameraPreview(controller!),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  heroTag: 'switch',
                  backgroundColor: Colors.grey.shade800,
                  onPressed: _toggleCamera,
                  child: const Icon(Icons.cameraswitch),
                ),
                FloatingActionButton(
                  heroTag: 'record',
                  backgroundColor: isRecording ? Colors.red : Colors.white,
                  onPressed: isRecording ? _stopRecording : _startRecording,
                  child: Icon(
                    isRecording ? Icons.stop : Icons.videocam,
                    color: isRecording ? Colors.white : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
