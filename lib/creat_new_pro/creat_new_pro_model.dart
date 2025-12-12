import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'creat_new_pro_widget.dart' show CreatNewProWidget;
import 'package:flutter/material.dart';

class CreatNewProModel extends FlutterFlowModel<CreatNewProWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  bool isDataUploading_uploadData5kx = false;
  FFUploadedFile uploadedLocalFile_uploadData5kx =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadData5kx = '';

  bool isDataUploading_uploadDataP22222 = false;
  FFUploadedFile uploadedLocalFile_uploadDataP22222 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController5;
  String? Function(BuildContext, String?)? textController5Validator;
  bool isDataUploading_uploadDataXoh = false;
  FFUploadedFile uploadedLocalFile_uploadDataXoh =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataXoh = '';

  bool isDataUploading_passLogo = false;
  FFUploadedFile uploadedLocalFile_passLogo =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_passLogo = '';

  bool isDataUploading_background = false;
  FFUploadedFile uploadedLocalFile_background =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_background = '';

  // State field(s) for pass background color.
  FocusNode? passBgColorFocusNode;
  TextEditingController? passBgColorController;
  String? Function(BuildContext, String?)? passBgColorControllerValidator;
  // State field(s) for pass foreground color.
  FocusNode? passFgColorFocusNode;
  TextEditingController? passFgColorController;
  String? Function(BuildContext, String?)? passFgColorControllerValidator;
  // State field(s) for pass label color.
  FocusNode? passLabelColorFocusNode;
  TextEditingController? passLabelColorController;
  String? Function(BuildContext, String?)? passLabelColorControllerValidator;

  // Location fields
  FocusNode? latFocusNode;
  TextEditingController? latController;
  String? Function(BuildContext, String?)? latControllerValidator;
  FocusNode? lngFocusNode;
  TextEditingController? lngController;
  String? Function(BuildContext, String?)? lngControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController2?.dispose();

    textFieldFocusNode2?.dispose();
    textController3?.dispose();

    textFieldFocusNode3?.dispose();
    textController4?.dispose();

    textFieldFocusNode4?.dispose();
    textController5?.dispose();

    passBgColorFocusNode?.dispose();
    passBgColorController?.dispose();

    passFgColorFocusNode?.dispose();
    passFgColorController?.dispose();

    passLabelColorFocusNode?.dispose();
    passLabelColorController?.dispose();

    latFocusNode?.dispose();
    latController?.dispose();

    lngFocusNode?.dispose();
    lngController?.dispose();
  }
}
