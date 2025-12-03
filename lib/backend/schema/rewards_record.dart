import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RewardsRecord extends FirestoreRecord {
  RewardsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "reward_id" field.
  String? _rewardId;
  String get rewardId => _rewardId ?? '';
  bool hasRewardId() => _rewardId != null;

  // "card_id" field.
  DocumentReference? _cardId;
  DocumentReference? get cardId => _cardId;
  bool hasCardId() => _cardId != null;

  // "user_id" field.
  DocumentReference? _userId;
  DocumentReference? get userId => _userId;
  bool hasUserId() => _userId != null;

  // "program_id" field.
  DocumentReference? _programId;
  DocumentReference? get programId => _programId;
  bool hasProgramId() => _programId != null;

  // "reward_status" field.
  String? _rewardStatus;
  String get rewardStatus => _rewardStatus ?? '';
  bool hasRewardStatus() => _rewardStatus != null;

  // "claimed_at" field.
  DateTime? _claimedAt;
  DateTime? get claimedAt => _claimedAt;
  bool hasClaimedAt() => _claimedAt != null;

  // "expiry_date" field.
  DateTime? _expiryDate;
  DateTime? get expiryDate => _expiryDate;
  bool hasExpiryDate() => _expiryDate != null;

  void _initializeFields() {
    _rewardId = snapshotData['reward_id'] as String?;
    _cardId = snapshotData['card_id'] as DocumentReference?;
    _userId = snapshotData['user_id'] as DocumentReference?;
    _programId = snapshotData['program_id'] as DocumentReference?;
    _rewardStatus = snapshotData['reward_status'] as String?;
    _claimedAt = snapshotData['claimed_at'] as DateTime?;
    _expiryDate = snapshotData['expiry_date'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Rewards');

  static Stream<RewardsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RewardsRecord.fromSnapshot(s));

  static Future<RewardsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RewardsRecord.fromSnapshot(s));

  static RewardsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RewardsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RewardsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RewardsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RewardsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RewardsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRewardsRecordData({
  String? rewardId,
  DocumentReference? cardId,
  DocumentReference? userId,
  DocumentReference? programId,
  String? rewardStatus,
  DateTime? claimedAt,
  DateTime? expiryDate,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'reward_id': rewardId,
      'card_id': cardId,
      'user_id': userId,
      'program_id': programId,
      'reward_status': rewardStatus,
      'claimed_at': claimedAt,
      'expiry_date': expiryDate,
    }.withoutNulls,
  );

  return firestoreData;
}

class RewardsRecordDocumentEquality implements Equality<RewardsRecord> {
  const RewardsRecordDocumentEquality();

  @override
  bool equals(RewardsRecord? e1, RewardsRecord? e2) {
    return e1?.rewardId == e2?.rewardId &&
        e1?.cardId == e2?.cardId &&
        e1?.userId == e2?.userId &&
        e1?.programId == e2?.programId &&
        e1?.rewardStatus == e2?.rewardStatus &&
        e1?.claimedAt == e2?.claimedAt &&
        e1?.expiryDate == e2?.expiryDate;
  }

  @override
  int hash(RewardsRecord? e) => const ListEquality().hash([
        e?.rewardId,
        e?.cardId,
        e?.userId,
        e?.programId,
        e?.rewardStatus,
        e?.claimedAt,
        e?.expiryDate
      ]);

  @override
  bool isValidKey(Object? o) => o is RewardsRecord;
}
