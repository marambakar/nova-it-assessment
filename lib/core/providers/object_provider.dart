import 'package:flutter/material.dart';

class ObjectProvider extends ChangeNotifier {
  String? _selectedObject;

  String? get selectedObject => _selectedObject;

  void setSelectedObject(String object) {
    _selectedObject = object;
    notifyListeners();
  }
}
