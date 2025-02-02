import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../providers/object_provider.dart';
import '../services/camera_service.dart';
import '../services/object_detection_service.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  final ObjectDetectionService _detectionService = ObjectDetectionService();
  bool _isDetecting = false;
  String _detectionMessage = "🔍 Detecting...";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Initializes the camera and starts object detection
  Future<void> _initializeCamera() async {
    await _cameraService.initializeCamera();
    setState(() {});
    _startDetection();
  }

  /// Starts real-time object detection
  void _startDetection() {
    final cameraController = _cameraService.cameraController;
    if (cameraController == null) return;

    cameraController.startImageStream((image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      final selectedObject = Provider.of<ObjectProvider>(context, listen: false).selectedObject;
      if (selectedObject == null) return;

      final detectedObjects = await _detectionService.detectObject(image, selectedObject);

      setState(() => _updateDetectionMessage(detectedObjects));
      _isDetecting = false;
    });
  }

  /// Updates the detection message based on detection results
  void _updateDetectionMessage(String detectedObjects) {
    switch (detectedObjects) {
      case "Object Detected":
        _detectionMessage = "✅ Object Detected";
        _captureImage(); // Auto-capture on detection
        break;
      case "Zoom In":
        _detectionMessage = "🔍 Zoom In";
        break;
      case "Zoom Out":
        _detectionMessage = "🔍 Zoom Out";
        break;
      default:
        _detectionMessage = "🔍 Detecting...";
    }
  }

  /// Captures the image and navigates to the result screen
  Future<void> _captureImage() async {
    final File? imageFile = await _cameraService.captureImage();
    if (imageFile != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen(imagePath: imageFile.path)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraService.cameraController == null || !_cameraService.cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_cameraService.cameraController!), // Camera Preview
          _buildDetectionMessageOverlay(),
        ],
      ),
    );
  }

  /// Builds overlay displaying detection message
  Widget _buildDetectionMessageOverlay() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.black.withOpacity(0.6),
        child: Text(
          _detectionMessage,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraService.cameraController?.stopImageStream(); // Stop streaming before disposal
    _cameraService.dispose();
    _detectionService.dispose();
    super.dispose();
  }
}
