import 'package:camera/camera.dart';
import 'dart:io';

class CameraService {
  CameraController? _cameraController;

  /// Initializes the camera with the first available camera.
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(cameras.first, ResolutionPreset.medium);
    await _cameraController!.initialize();
  }

  /// Returns the initialized camera controller.
  CameraController? get cameraController => _cameraController;

  /// Captures an image and returns the file path.
  Future<File?> captureImage() async {
    if (_cameraController?.value.isInitialized != true) {
      return null;
    }
    final image = await _cameraController!.takePicture();
    return File(image.path);
  }

  /// Disposes the camera controller to free up resources.
  void dispose() {
    _cameraController?.dispose();
    _cameraController = null;
  }
}
