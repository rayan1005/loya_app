import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TransactionsRecord extends FirestoreRecord {
  TransactionsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "transaction_id" field.
  String? _transactionId;
  String get transactionId => _transactionId ?? '';
  bool hasTransactionId() => _transactionId != null;

  // "user_id" field.
  DocumentReference? _userId;
  DocumentReference? get userId => _userId;
  bool hasUserId() => _userId != null;

  // "card_id" field.
  DocumentReference? _cardId;
  DocumentReference? get cardId => _cardId;
  bool hasCardId() => _cardId != null;

  // "merchant_id" field.
  DocumentReference? _merchantId;
  DocumentReference? get merchantId => _merchantId;
  bool hasMerchantId() => _merchantId != null;

  // "action" field.
  String? _action;
  String get action => _action ?? '';
  bool hasAction() => _action != null;

  // "value" field.
  int? _value;
  int get value => _value ?? 0;
  bool hasValue() => _value != null;

  // "scanned_by" field.
  String? _scannedBy;
  String get scannedBy => _scannedBy ?? '';
  bool hasScannedBy() => _scannedBy != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _transactionId = snapshotData['transaction_id'] as String?;
    _userId = snapshotData['user_id'] as DocumentReference?;
    _cardId = snapshotData['card_id'] as DocumentReference?;
    _merchantId = snapshotData['merchant_id'] as DocumentReference?;
    _action = snapshotData['action'] as String?;
    _value = castToType<int>(snapshotData['value']);
    _scannedBy = snapshotData['scanned_by'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Transactions');

  static Stream<TransactionsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TransactionsRecord.fromSnapshot(s));

  static Future<TransactionsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TransactionsRecord.fromSnapshot(s));

  static TransactionsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TransactionsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TransactionsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TransactionsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TransactionsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TransactionsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTransactionsRecordData({
  String? transactionId,
  DocumentReference? userId,
  DocumentReference? cardId,
  DocumentReference? merchantId,
  String? action,
  int? value,
  String? scannedBy,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'transaction_id': transactionId,
      'user_id': userId,
      'card_id': cardId,
      'merchant_id': merchantId,
      'action': action,
      'value': value,
      'scanned_by': scannedBy,
      'created_at': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class TransactionsRecordDocumentEquality
    implements Equality<TransactionsRecord> {
  const TransactionsRecordDocumentEquality();

  @override
  bool equals(TransactionsRecord? e1, TransactionsRecord? e2) {
    return e1?.transactionId == e2?.transactionId &&
        e1?.userId == e2?.userId &&
        e1?.cardId == e2?.cardId &&
        e1?.merchantId == e2?.merchantId &&
        e1?.action == e2?.action &&
        e1?.value == e2?.value &&
        e1?.scannedBy == e2?.scannedBy &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(TransactionsRecord? e) => const ListEquality().hash([
        e?.transactionId,
        e?.userId,
        e?.cardId,
        e?.merchantId,
        e?.action,
        e?.value,
        e?.scannedBy,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is TransactionsRecord;
}
