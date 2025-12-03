import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StampCardsRecord extends FirestoreRecord {
  StampCardsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "card_id" field.
  String? _cardId;
  String get cardId => _cardId ?? '';
  bool hasCardId() => _cardId != null;

  // "program_id" field.
  DocumentReference? _programId;
  DocumentReference? get programId => _programId;
  bool hasProgramId() => _programId != null;

  // "user_id" field.
  DocumentReference? _userId;
  DocumentReference? get userId => _userId;
  bool hasUserId() => _userId != null;

  // "current_stamps" field.
  int? _currentStamps;
  int get currentStamps => _currentStamps ?? 0;
  bool hasCurrentStamps() => _currentStamps != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updated_at" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "wallet_pass_id" field.
  String? _walletPassId;
  String get walletPassId => _walletPassId ?? '';
  bool hasWalletPassId() => _walletPassId != null;

  // "wallet_pass_url" field.
  String? _walletPassUrl;
  String get walletPassUrl => _walletPassUrl ?? '';
  bool hasWalletPassUrl() => _walletPassUrl != null;

  // "qr_value" field.
  String? _qrValue;
  String get qrValue => _qrValue ?? '';
  bool hasQrValue() => _qrValue != null;

  void _initializeFields() {
    _cardId = snapshotData['card_id'] as String?;
    _programId = snapshotData['program_id'] as DocumentReference?;
    _userId = snapshotData['user_id'] as DocumentReference?;
    _currentStamps = castToType<int>(snapshotData['current_stamps']);
    _status = snapshotData['status'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _updatedAt = snapshotData['updated_at'] as DateTime?;
    _walletPassId = snapshotData['wallet_pass_id'] as String?;
    _walletPassUrl = snapshotData['wallet_pass_url'] as String?;
    _qrValue = snapshotData['qr_value'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('StampCards');

  static Stream<StampCardsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StampCardsRecord.fromSnapshot(s));

  static Future<StampCardsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StampCardsRecord.fromSnapshot(s));

  static StampCardsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      StampCardsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StampCardsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StampCardsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StampCardsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StampCardsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStampCardsRecordData({
  String? cardId,
  DocumentReference? programId,
  DocumentReference? userId,
  int? currentStamps,
  String? status,
  DateTime? createdAt,
  DateTime? updatedAt,
  String? walletPassId,
  String? walletPassUrl,
  String? qrValue,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'card_id': cardId,
      'program_id': programId,
      'user_id': userId,
      'current_stamps': currentStamps,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'wallet_pass_id': walletPassId,
      'wallet_pass_url': walletPassUrl,
      'qr_value': qrValue,
    }.withoutNulls,
  );

  return firestoreData;
}

class StampCardsRecordDocumentEquality implements Equality<StampCardsRecord> {
  const StampCardsRecordDocumentEquality();

  @override
  bool equals(StampCardsRecord? e1, StampCardsRecord? e2) {
    return e1?.cardId == e2?.cardId &&
        e1?.programId == e2?.programId &&
        e1?.userId == e2?.userId &&
        e1?.currentStamps == e2?.currentStamps &&
        e1?.status == e2?.status &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.walletPassId == e2?.walletPassId &&
        e1?.walletPassUrl == e2?.walletPassUrl &&
        e1?.qrValue == e2?.qrValue;
  }

  @override
  int hash(StampCardsRecord? e) => const ListEquality().hash([
        e?.cardId,
        e?.programId,
        e?.userId,
        e?.currentStamps,
        e?.status,
        e?.createdAt,
        e?.updatedAt,
        e?.walletPassId,
        e?.walletPassUrl,
        e?.qrValue
      ]);

  @override
  bool isValidKey(Object? o) => o is StampCardsRecord;
}
