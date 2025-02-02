import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'dart:ui';


class ObjectDetectionService {
  final ObjectDetector _objectDetector = GoogleMlKit.vision.objectDetector(
    options: ObjectDetectorOptions( // Use built-in model
      mode: DetectionMode.stream,
      classifyObjects: true,
      multipleObjects: true,

    ),
  );
  final ImageLabeler _imageLabeler = GoogleMlKit.vision.imageLabeler();

  /// ✅ Detects object from Camera Image
  Future<String> detectObject(CameraImage image, String targetObject) async {
    final inputImage = _convertCameraImageToInputImage(image);
    if (inputImage == null) return ""; // Return if conversion fails

    final detectedObjects = await _objectDetector.processImage(inputImage);

    print("🟢 Detected Objects: ${detectedObjects.length}"); // ✅ Debugging

    if (detectedObjects.isEmpty) {
      print("⚠️ No object detected");
      return "Continue"; // No objects detected
    }

    for (final obj in detectedObjects) {
      if (obj.labels.isNotEmpty) {
        for (var label in obj.labels) {
          if(label == targetObject){
          final croppedImage = _cropImage(image, obj.boundingBox);
          if (croppedImage != null) {
            final objectName = await _labelCroppedObject(croppedImage);
            print("🎯 Real Object Name: $objectName");
          }
          final double objectWidth = obj.boundingBox.width;
          final double objectHeight = obj.boundingBox.height;
          final double imageWidth = image.width.toDouble();
          final double imageHeight = image.height.toDouble();

          final double widthRatio = objectWidth / imageWidth;
          final double heightRatio = objectHeight / imageHeight;

          if (widthRatio < 0.6 || heightRatio < 0.6) {
            return "Zoom In";
          } else if (widthRatio > 0.9 || heightRatio > 0.9) {
            return "Zoom Out";
          } else {
            return "Object Detected";
          }
           }
        }
      }
    }

    print("❌ Object not matched");
    return "Continue"; // Object detected but does not match target
  }



  /// ✅ Label cropped image
  Future<String> _labelCroppedObject(InputImage croppedImage) async {
    try {
      final labels = await _imageLabeler.processImage(croppedImage);
      return labels.isNotEmpty ? labels.first.label : "Unknown Object";
    } catch (e) {
      print("Error labeling cropped object: $e");
      return "Error";
    }
  }

  /// ✅ Crop image using bounding box
  InputImage? _cropImage(CameraImage image, Rect boundingBox) {
    try {
      final width = image.width;
      final height = image.height;
      final yPlane = image.planes[0].bytes;
      final uPlane = image.planes[1].bytes;
      final vPlane = image.planes[2].bytes;
      final yRowStride = image.planes[0].bytesPerRow;
      final uvRowStride = image.planes[1].bytesPerRow;

      // Calculate cropped region
      final cropX = boundingBox.left.toInt();
      final cropY = boundingBox.top.toInt();
      final cropWidth = boundingBox.width.toInt();
      final cropHeight = boundingBox.height.toInt();

      // Create a new ByteBuffer for the cropped image
      final croppedYBuffer = Uint8List(cropWidth * cropHeight);
      final croppedUBuffer = Uint8List((cropWidth ~/ 2) * (cropHeight ~/ 2));
      final croppedVBuffer = Uint8List((cropWidth ~/ 2) * (cropHeight ~/ 2));

      // Copy Y plane
      for (int y = 0; y < cropHeight; y++) {
        for (int x = 0; x < cropWidth; x++) {
          final srcIndex = (cropY + y) * yRowStride + (cropX + x);
          final dstIndex = y * cropWidth + x;
          croppedYBuffer[dstIndex] = yPlane[srcIndex];
        }
      }

      // Copy U and V planes
      for (int y = 0; y < cropHeight ~/ 2; y++) {
        for (int x = 0; x < cropWidth ~/ 2; x++) {
          final srcIndex = ((cropY ~/ 2) + y) * uvRowStride + ((cropX ~/ 2) + x);
          final dstIndex = y * (cropWidth ~/ 2) + x;
          croppedUBuffer[dstIndex] = uPlane[srcIndex];
          croppedVBuffer[dstIndex] = vPlane[srcIndex];
        }
      }

      // Combine planes into a single buffer
      final croppedBuffer = Uint8List(croppedYBuffer.length + croppedUBuffer.length + croppedVBuffer.length);
      croppedBuffer.setAll(0, croppedYBuffer);
      croppedBuffer.setAll(croppedYBuffer.length, croppedUBuffer);
      croppedBuffer.setAll(croppedYBuffer.length + croppedUBuffer.length, croppedVBuffer);

      // Create InputImage metadata
      final metadata = InputImageMetadata(
        size: Size(cropWidth.toDouble(), cropHeight.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.yuv420, // Use YUV420 format
        bytesPerRow: cropWidth, // For Y plane
      );

      return InputImage.fromBytes(
        bytes: croppedBuffer,
        metadata: metadata,
      );
    } catch (e) {
      print("Error cropping image: $e");
      return null;
    }
  }
  /// ✅ Extract Region (Bounding Box) from Image Bytes
  Uint8List? _extractRegion(Uint8List bytes, Rect boundingBox, int width, int height) {
    try {
      final int x = boundingBox.left.toInt();
      final int y = boundingBox.top.toInt();
      final int w = boundingBox.width.toInt();
      final int h = boundingBox.height.toInt();

      final croppedBytes = Uint8List(w * h);
      int i = 0;

      for (int row = y; row < y + h; row++) {
        for (int col = x; col < x + w; col++) {
          int index = (row * width) + col;
          if (index < bytes.length) {
            croppedBytes[i++] = bytes[index];
          }
        }
      }

      return croppedBytes;
    } catch (e) {
      print("Error extracting bounding box: $e");
      return null;
    }
  }

  /// ✅ Convert CameraImage to InputImage
  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    try {
      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.yuv420, // Use YUV420 format
        bytesPerRow: image.planes[0].bytesPerRow, // For Y plane
      );

      final buffer = _concatenatePlanes(image.planes);
      if (buffer == null) return null;

      return InputImage.fromBytes(
        bytes: buffer,
        metadata: metadata,
      );
    } catch (e) {
      print("Error converting CameraImage: $e");
      return null;
    }
  }
  /// ✅ Combines camera planes into a single byte buffer
  /// ✅ Combine camera planes into a single byte buffer
  Uint8List? _concatenatePlanes(List<Plane> planes) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in planes) {
        allBytes.putUint8List(plane.bytes);
      }
      return allBytes.done().buffer.asUint8List();
    } catch (e) {
      print("Error concatenating planes: $e");
      return null;
    }
  }

  void dispose() {
    _objectDetector.close();
  }
}
