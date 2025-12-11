import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  late SharedPreferences prefs;

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _UserOrMetchent = prefs.getString('_user_role') ?? '';
    });
  }

  void _safeInit(Function() initFn) {
    try {
      initFn();
    } catch (_) {}
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  String _UserOrMetchent = '';
  String get UserOrMetchent => _UserOrMetchent;
  set UserOrMetchent(String value) {
    _UserOrMetchent = value;
    prefs.setString('_user_role', value);
  }

  int _NumberOfStamp = 6;
  int get NumberOfStamp => _NumberOfStamp;
  set NumberOfStamp(int value) {
    _NumberOfStamp = value;
  }

  List<int> _stampCountInput = [1, 1, 1, 1, 1, 1];
  List<int> get stampCountInput => _stampCountInput;
  set stampCountInput(List<int> value) {
    _stampCountInput = value;
  }

  void addToStampCountInput(int value) {
    stampCountInput.add(value);
  }

  void removeFromStampCountInput(int value) {
    stampCountInput.remove(value);
  }

  void removeAtIndexFromStampCountInput(int index) {
    stampCountInput.removeAt(index);
  }

  void updateStampCountInputAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    stampCountInput[index] = updateFn(_stampCountInput[index]);
  }

  void insertAtIndexInStampCountInput(int index, int value) {
    stampCountInput.insert(index, value);
  }

  int _lightNumberOFstem = 3;
  int get lightNumberOFstem => _lightNumberOFstem;
  set lightNumberOFstem(int value) {
    _lightNumberOFstem = value;
  }

  List<int> _lightsteampCountInput = [1, 1, 1];
  List<int> get lightsteampCountInput => _lightsteampCountInput;
  set lightsteampCountInput(List<int> value) {
    _lightsteampCountInput = value;
  }

  void addToLightsteampCountInput(int value) {
    lightsteampCountInput.add(value);
  }

  void removeFromLightsteampCountInput(int value) {
    lightsteampCountInput.remove(value);
  }

  void removeAtIndexFromLightsteampCountInput(int index) {
    lightsteampCountInput.removeAt(index);
  }

  void updateLightsteampCountInputAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    lightsteampCountInput[index] = updateFn(_lightsteampCountInput[index]);
  }

  void insertAtIndexInLightsteampCountInput(int index, int value) {
    lightsteampCountInput.insert(index, value);
  }

  String _qrtext = '';
  String get qrtext => _qrtext;
  set qrtext(String value) {
    _qrtext = value;
  }

  int _addNewStamp = 0;
  int get addNewStamp => _addNewStamp;
  set addNewStamp(int value) {
    _addNewStamp = value;
  }

  String _qrserial = '';
  String get qrserial => _qrserial;
  set qrserial(String value) {
    _qrserial = value;
  }

  String _qrprogramid = '';
  String get qrprogramid => _qrprogramid;
  set qrprogramid(String value) {
    _qrprogramid = value;
  }

  String _qruid = '';
  String get qruid => _qruid;
  set qruid(String value) {
    _qruid = value;
  }
}
