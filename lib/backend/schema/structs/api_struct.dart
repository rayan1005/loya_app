// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class ApiStruct extends FFFirebaseStruct {
  ApiStruct({
    String? serialNumber,
    String? downloadURL,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _serialNumber = serialNumber,
        _downloadURL = downloadURL,
        super(firestoreUtilData);

  // "serialNumber" field.
  String? _serialNumber;
  String get serialNumber => _serialNumber ?? '';
  set serialNumber(String? val) => _serialNumber = val;

  bool hasSerialNumber() => _serialNumber != null;

  // "downloadURL" field.
  String? _downloadURL;
  String get downloadURL => _downloadURL ?? '';
  set downloadURL(String? val) => _downloadURL = val;

  bool hasDownloadURL() => _downloadURL != null;

  static ApiStruct fromMap(Map<String, dynamic> data) => ApiStruct(
        serialNumber: data['serialNumber'] as String?,
        downloadURL: data['downloadURL'] as String?,
      );

  static ApiStruct? maybeFromMap(dynamic data) =>
      data is Map ? ApiStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'serialNumber': _serialNumber,
        'downloadURL': _downloadURL,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'serialNumber': serializeParam(
          _serialNumber,
          ParamType.String,
        ),
        'downloadURL': serializeParam(
          _downloadURL,
          ParamType.String,
        ),
      }.withoutNulls;

  static ApiStruct fromSerializableMap(Map<String, dynamic> data) => ApiStruct(
        serialNumber: deserializeParam(
          data['serialNumber'],
          ParamType.String,
          false,
        ),
        downloadURL: deserializeParam(
          data['downloadURL'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'ApiStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ApiStruct &&
        serialNumber == other.serialNumber &&
        downloadURL == other.downloadURL;
  }

  @override
  int get hashCode => const ListEquality().hash([serialNumber, downloadURL]);
}

ApiStruct createApiStruct({
  String? serialNumber,
  String? downloadURL,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ApiStruct(
      serialNumber: serialNumber,
      downloadURL: downloadURL,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ApiStruct? updateApiStruct(
  ApiStruct? api, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    api
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addApiStructData(
  Map<String, dynamic> firestoreData,
  ApiStruct? api,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (api == null) {
    return;
  }
  if (api.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue && api.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final apiData = getApiFirestoreData(api, forFieldValue);
  final nestedData = apiData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = api.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getApiFirestoreData(
  ApiStruct? api, [
  bool forFieldValue = false,
]) {
  if (api == null) {
    return {};
  }
  final firestoreData = mapToFirestore(api.toMap());

  // Add any Firestore field values
  api.firestoreUtilData.fieldValues.forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getApiListFirestoreData(
  List<ApiStruct>? apis,
) =>
    apis?.map((e) => getApiFirestoreData(e, true)).toList() ?? [];
