import 'dart:convert';
import 'dart:typed_data';
import '../schema/structs/index.dart';

import 'package:flutter/foundation.dart';
import '/auth/firebase_auth/auth_util.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class CreateWalletPassCall {
  static Future<ApiCallResponse> call({
    String? programId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "program_id": "${escapeStringForJson(programId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createWalletPass',
      apiUrl:
          'https://us-central1-loya-app-ziqygx.cloudfunctions.net/api/createWalletPass',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $currentJwtToken',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? serialNumber(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.serialNumber''',
      ));
  static String? downloadURL(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.downloadURL''',
      ));
}

class AddStampCall {
  static Future<ApiCallResponse> call({
    String? programId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "program_id": "${escapeStringForJson(programId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'addStamp',
      apiUrl:
          'https://us-central1-loya-app-ziqygx.cloudfunctions.net/api/addStamp',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $currentJwtToken',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static int? totalStamps(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.total_stamps''',
      ));
  static String? serialNumber(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.serialNumber''',
      ));
}

class RefreshProgramPassesCall {
  static Future<ApiCallResponse> call({
    String? programId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "program_id": "${escapeStringForJson(programId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'refreshProgramPasses',
      apiUrl:
          'https://us-central1-loya-app-ziqygx.cloudfunctions.net/api/refreshProgramPasses',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $currentJwtToken',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static int? updated(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.updated''',
      ));
  static int? failed(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.failed''',
      ));
}

class WalletHealthCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'walletHealth',
      apiUrl:
          'https://us-central1-loya-app-ziqygx.cloudfunctions.net/api',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $currentJwtToken',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: true,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class BroadcastProgramMessageCall {
  static Future<ApiCallResponse> call({
    String? programId = '',
    String? message = '',
  }) async {
    final ffApiRequestBody = '''
{
  "program_id": "${escapeStringForJson(programId)}",
  "message": "${escapeStringForJson(message)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'broadcastProgramMessage',
      apiUrl:
          'https://us-central1-loya-app-ziqygx.cloudfunctions.net/api/broadcastMessage',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $currentJwtToken',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static int? updated(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.updated''',
      ));
  static int? pushed(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.pushed''',
      ));
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
