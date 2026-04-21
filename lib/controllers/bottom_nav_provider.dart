import 'package:flutter/material.dart';

class BottomNavProvider extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  void setIndex(int i) {
    _index = i;
    notifyListeners();
  }
}
