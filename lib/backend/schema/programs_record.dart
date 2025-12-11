import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ProgramsRecord extends FirestoreRecord {
  ProgramsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "program_id" field.
  String? _programId;
  String get programId => _programId ?? '';
  bool hasProgramId() => _programId != null;

  // "merchant_id" field.
  DocumentReference? _merchantId;
  DocumentReference? get merchantId => _merchantId;
  bool hasMerchantId() => _merchantId != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "reward_type" field.
  String? _rewardType;
  String get rewardType => _rewardType ?? '';
  bool hasRewardType() => _rewardType != null;

  // "stamps_required" field.
  int? _stampsRequired;
  int get stampsRequired => _stampsRequired ?? 0;
  bool hasStampsRequired() => _stampsRequired != null;

  // "expiry_date" field.
  DateTime? _expiryDate;
  DateTime? get expiryDate => _expiryDate;
  bool hasExpiryDate() => _expiryDate != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updated_at" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "stamp_icon" field.
  String? _stampIcon;
  String get stampIcon => _stampIcon ?? '';
  bool hasStampIcon() => _stampIcon != null;

  // "reward_details" field.
  String? _rewardDetails;
  String get rewardDetails => _rewardDetails ?? '';
  bool hasRewardDetails() => _rewardDetails != null;

  // "status" field.
  bool? _status;
  bool get status => _status ?? false;
  bool hasStatus() => _status != null;

  // "terms_conditions" field.
  String? _termsConditions;
  String get termsConditions => _termsConditions ?? '';
  bool hasTermsConditions() => _termsConditions != null;

  // "business_icon" field.
  String? _businessIcon;
  String get businessIcon => _businessIcon ?? '';
  bool hasBusinessIcon() => _businessIcon != null;

  // "number" field.
  List<int>? _number;
  List<int> get number => _number ?? const [];
  bool hasNumber() => _number != null;

  // "latitude" field.
  double? _latitude;
  double get latitude => _latitude ?? 0.0;
  bool hasLatitude() => _latitude != null;

  // "longitude" field.
  double? _longitude;
  double get longitude => _longitude ?? 0.0;
  bool hasLongitude() => _longitude != null;

  // "pass_background_color" field.
  String? _passBackgroundColor;
  String get passBackgroundColor => _passBackgroundColor ?? '';
  bool hasPassBackgroundColor() => _passBackgroundColor != null;

  // "pass_foreground_color" field.
  String? _passForegroundColor;
  String get passForegroundColor => _passForegroundColor ?? '';
  bool hasPassForegroundColor() => _passForegroundColor != null;

  // "pass_label_color" field.
  String? _passLabelColor;
  String get passLabelColor => _passLabelColor ?? '';
  bool hasPassLabelColor() => _passLabelColor != null;

  // "pass_icon" field.
  String? _passIcon;
  String get passIcon => _passIcon ?? '';
  bool hasPassIcon() => _passIcon != null;

  // "pass_logo" field.
  String? _passLogo;
  String get passLogo => _passLogo ?? '';
  bool hasPassLogo() => _passLogo != null;

  void _initializeFields() {
    _programId = snapshotData['program_id'] as String?;
    _merchantId = snapshotData['merchant_id'] as DocumentReference?;
    _title = snapshotData['title'] as String?;
    _description = snapshotData['description'] as String?;
    _rewardType = snapshotData['reward_type'] as String?;
    _stampsRequired = castToType<int>(snapshotData['stamps_required']);
    _expiryDate = snapshotData['expiry_date'] as DateTime?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _updatedAt = snapshotData['updated_at'] as DateTime?;
    _stampIcon = snapshotData['stamp_icon'] as String?;
    _rewardDetails = snapshotData['reward_details'] as String?;
    _status = snapshotData['status'] as bool?;
    _termsConditions = snapshotData['terms_conditions'] as String?;
    _businessIcon = snapshotData['business_icon'] as String?;
    _number = getDataList(snapshotData['number']);
    _latitude = castToType<double>(snapshotData['latitude']);
    _longitude = castToType<double>(snapshotData['longitude']);
    _passBackgroundColor = snapshotData['pass_background_color'] as String?;
    _passForegroundColor = snapshotData['pass_foreground_color'] as String?;
    _passLabelColor = snapshotData['pass_label_color'] as String?;
    _passIcon = snapshotData['pass_icon'] as String?;
    _passLogo = snapshotData['pass_logo'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('programs');

  static Stream<ProgramsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ProgramsRecord.fromSnapshot(s));

  static Future<ProgramsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ProgramsRecord.fromSnapshot(s));

  static ProgramsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ProgramsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ProgramsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ProgramsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ProgramsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ProgramsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createProgramsRecordData({
  String? programId,
  DocumentReference? merchantId,
  String? title,
  String? description,
  String? rewardType,
  int? stampsRequired,
  DateTime? expiryDate,
  DateTime? createdAt,
  DateTime? updatedAt,
  String? stampIcon,
  String? rewardDetails,
  bool? status,
  String? termsConditions,
  String? businessIcon,
  String? passBackgroundColor,
  String? passForegroundColor,
  String? passLabelColor,
  String? passIcon,
  String? passLogo,
  double? latitude,
  double? longitude,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'program_id': programId,
      'merchant_id': merchantId,
      'title': title,
      'description': description,
      'reward_type': rewardType,
      'stamps_required': stampsRequired,
      'expiry_date': expiryDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'stamp_icon': stampIcon,
      'reward_details': rewardDetails,
      'status': status,
      'terms_conditions': termsConditions,
      'business_icon': businessIcon,
      'latitude': latitude,
      'longitude': longitude,
      'pass_background_color': passBackgroundColor,
      'pass_foreground_color': passForegroundColor,
      'pass_label_color': passLabelColor,
      'pass_icon': passIcon,
      'pass_logo': passLogo,
    }.withoutNulls,
  );

  return firestoreData;
}

class ProgramsRecordDocumentEquality implements Equality<ProgramsRecord> {
  const ProgramsRecordDocumentEquality();

  @override
  bool equals(ProgramsRecord? e1, ProgramsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.programId == e2?.programId &&
        e1?.merchantId == e2?.merchantId &&
        e1?.title == e2?.title &&
        e1?.description == e2?.description &&
        e1?.rewardType == e2?.rewardType &&
        e1?.stampsRequired == e2?.stampsRequired &&
        e1?.expiryDate == e2?.expiryDate &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.stampIcon == e2?.stampIcon &&
        e1?.rewardDetails == e2?.rewardDetails &&
        e1?.status == e2?.status &&
        e1?.termsConditions == e2?.termsConditions &&
        e1?.businessIcon == e2?.businessIcon &&
        listEquality.equals(e1?.number, e2?.number) &&
        e1?.latitude == e2?.latitude &&
        e1?.longitude == e2?.longitude &&
        e1?.passBackgroundColor == e2?.passBackgroundColor &&
        e1?.passForegroundColor == e2?.passForegroundColor &&
        e1?.passLabelColor == e2?.passLabelColor &&
        e1?.passIcon == e2?.passIcon &&
        e1?.passLogo == e2?.passLogo;
  }

  @override
  int hash(ProgramsRecord? e) => const ListEquality().hash([
        e?.programId,
        e?.merchantId,
        e?.title,
        e?.description,
        e?.rewardType,
        e?.stampsRequired,
        e?.expiryDate,
        e?.createdAt,
        e?.updatedAt,
        e?.stampIcon,
        e?.rewardDetails,
        e?.status,
        e?.termsConditions,
        e?.businessIcon,
        e?.number,
        e?.latitude,
        e?.longitude,
        e?.passBackgroundColor,
        e?.passForegroundColor,
        e?.passLabelColor,
        e?.passIcon,
        e?.passLogo
      ]);

  @override
  bool isValidKey(Object? o) => o is ProgramsRecord;
}
