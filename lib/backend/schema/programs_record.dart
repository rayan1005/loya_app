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

  // "merchant_uid" field.
  String? _merchantUid;
  String get merchantUid => _merchantUid ?? '';
  bool hasMerchantUid() => _merchantUid != null;

  // "merchant_ref" field.
  DocumentReference? _merchantRef;
  DocumentReference? get merchantRef => _merchantRef;
  bool hasMerchantRef() => _merchantRef != null;

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

  // "reward_title" field.
  String? _rewardTitle;
  String get rewardTitle => _rewardTitle ?? '';
  bool hasRewardTitle() => _rewardTitle != null;

  // "reward_description" field.
  String? _rewardDescription;
  String get rewardDescription => _rewardDescription ?? '';
  bool hasRewardDescription() => _rewardDescription != null;

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

  // "pass_latest_update" field.
  String? _passLatestUpdate;
  String get passLatestUpdate => _passLatestUpdate ?? '';
  bool hasPassLatestUpdate() => _passLatestUpdate != null;

  // "pass_latest_update_at" field.
  DateTime? _passLatestUpdateAt;
  DateTime? get passLatestUpdateAt => _passLatestUpdateAt;
  bool hasPassLatestUpdateAt() => _passLatestUpdateAt != null;

  // "pass_collect_rule" field.
  String? _passCollectRule;
  String get passCollectRule => _passCollectRule ?? '';
  bool hasPassCollectRule() => _passCollectRule != null;

  // "pass_locations" field.
  List<dynamic>? _passLocations;
  List<dynamic> get passLocations => _passLocations ?? const [];
  bool hasPassLocations() => _passLocations != null;

  // "pass_instagram" field.
  String? _passInstagram;
  String get passInstagram => _passInstagram ?? '';
  bool hasPassInstagram() => _passInstagram != null;

  // "pass_snapchat" field.
  String? _passSnapchat;
  String get passSnapchat => _passSnapchat ?? '';
  bool hasPassSnapchat() => _passSnapchat != null;

  // "pass_website" field.
  String? _passWebsite;
  String get passWebsite => _passWebsite ?? '';
  bool hasPassWebsite() => _passWebsite != null;

  // "pass_support_email" field.
  String? _passSupportEmail;
  String get passSupportEmail => _passSupportEmail ?? '';
  bool hasPassSupportEmail() => _passSupportEmail != null;

  // "pass_contact_name" field.
  String? _passContactName;
  String get passContactName => _passContactName ?? '';
  bool hasPassContactName() => _passContactName != null;

  void _initializeFields() {
    _programId = snapshotData['program_id'] as String?;
    _merchantId = snapshotData['merchant_id'] as DocumentReference?;
    _merchantUid = snapshotData['merchant_uid'] as String?;
    _merchantRef = snapshotData['merchant_ref'] as DocumentReference?;
    _title = snapshotData['title'] as String?;
    _description = snapshotData['description'] as String?;
    _rewardType = snapshotData['reward_type'] as String?;
    _stampsRequired = castToType<int>(snapshotData['stamps_required']);
    _expiryDate = snapshotData['expiry_date'] as DateTime?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _updatedAt = snapshotData['updated_at'] as DateTime?;
    _stampIcon = snapshotData['stamp_icon'] as String?;
    _rewardDetails = snapshotData['reward_details'] as String?;
    _rewardTitle = snapshotData['reward_title'] as String?;
    _rewardDescription = snapshotData['reward_description'] as String?;
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
    _passLatestUpdate = snapshotData['pass_latest_update'] as String?;
    _passLatestUpdateAt = snapshotData['pass_latest_update_at'] as DateTime?;
    _passCollectRule = snapshotData['pass_collect_rule'] as String?;
    _passLocations = getDataList(snapshotData['pass_locations']);
    _passInstagram = snapshotData['pass_instagram'] as String?;
    _passSnapchat = snapshotData['pass_snapchat'] as String?;
    _passWebsite = snapshotData['pass_website'] as String?;
    _passSupportEmail = snapshotData['pass_support_email'] as String?;
    _passContactName = snapshotData['pass_contact_name'] as String?;
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
  String? merchantUid,
  DocumentReference? merchantRef,
  String? title,
  String? description,
  String? rewardType,
  int? stampsRequired,
  DateTime? expiryDate,
  DateTime? createdAt,
  DateTime? updatedAt,
  String? stampIcon,
  String? rewardDetails,
  String? rewardTitle,
  String? rewardDescription,
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
  String? passLatestUpdate,
  DateTime? passLatestUpdateAt,
  String? passCollectRule,
  List<dynamic>? passLocations,
  String? passInstagram,
  String? passSnapchat,
  String? passWebsite,
  String? passSupportEmail,
  String? passContactName,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'program_id': programId,
      'merchant_id': merchantId,
      'merchant_uid': merchantUid,
      'merchant_ref': merchantRef,
      'title': title,
      'description': description,
      'reward_type': rewardType,
      'stamps_required': stampsRequired,
      'expiry_date': expiryDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'stamp_icon': stampIcon,
      'reward_details': rewardDetails,
      'reward_title': rewardTitle,
      'reward_description': rewardDescription,
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
      'pass_latest_update': passLatestUpdate,
      'pass_latest_update_at': passLatestUpdateAt,
      'pass_collect_rule': passCollectRule,
      'pass_locations': passLocations,
      'pass_instagram': passInstagram,
      'pass_snapchat': passSnapchat,
      'pass_website': passWebsite,
      'pass_support_email': passSupportEmail,
      'pass_contact_name': passContactName,
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
        e1?.merchantUid == e2?.merchantUid &&
        e1?.merchantRef == e2?.merchantRef &&
        e1?.title == e2?.title &&
        e1?.description == e2?.description &&
        e1?.rewardType == e2?.rewardType &&
        e1?.stampsRequired == e2?.stampsRequired &&
        e1?.expiryDate == e2?.expiryDate &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.stampIcon == e2?.stampIcon &&
        e1?.rewardDetails == e2?.rewardDetails &&
        e1?.rewardTitle == e2?.rewardTitle &&
        e1?.rewardDescription == e2?.rewardDescription &&
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
        e1?.passLogo == e2?.passLogo &&
        e1?.passLatestUpdate == e2?.passLatestUpdate &&
        e1?.passLatestUpdateAt == e2?.passLatestUpdateAt &&
        e1?.passCollectRule == e2?.passCollectRule &&
        listEquality.equals(e1?.passLocations, e2?.passLocations) &&
        e1?.passInstagram == e2?.passInstagram &&
        e1?.passSnapchat == e2?.passSnapchat &&
        e1?.passWebsite == e2?.passWebsite &&
        e1?.passSupportEmail == e2?.passSupportEmail &&
        e1?.passContactName == e2?.passContactName;
  }

  @override
  int hash(ProgramsRecord? e) => const ListEquality().hash([
        e?.programId,
        e?.merchantId,
        e?.merchantUid,
        e?.merchantRef,
        e?.title,
        e?.description,
        e?.rewardType,
        e?.stampsRequired,
        e?.expiryDate,
        e?.createdAt,
        e?.updatedAt,
        e?.stampIcon,
        e?.rewardDetails,
        e?.rewardTitle,
        e?.rewardDescription,
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
        e?.passLogo,
        e?.passLatestUpdate,
        e?.passLatestUpdateAt,
        e?.passCollectRule,
        e?.passLocations,
        e?.passInstagram,
        e?.passSnapchat,
        e?.passWebsite,
        e?.passSupportEmail,
        e?.passContactName
      ]);

  @override
  bool isValidKey(Object? o) => o is ProgramsRecord;
}
