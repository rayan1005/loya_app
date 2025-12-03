import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MerchantsRecord extends FirestoreRecord {
  MerchantsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "merchant_id" field.
  String? _merchantId;
  String get merchantId => _merchantId ?? '';
  bool hasMerchantId() => _merchantId != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "logo_url" field.
  String? _logoUrl;
  String get logoUrl => _logoUrl ?? '';
  bool hasLogoUrl() => _logoUrl != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "contact_person" field.
  String? _contactPerson;
  String get contactPerson => _contactPerson ?? '';
  bool hasContactPerson() => _contactPerson != null;

  // "phone" field.
  String? _phone;
  String get phone => _phone ?? '';
  bool hasPhone() => _phone != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "user_id" field.
  DocumentReference? _userId;
  DocumentReference? get userId => _userId;
  bool hasUserId() => _userId != null;

  // "create_at" field.
  DateTime? _createAt;
  DateTime? get createAt => _createAt;
  bool hasCreateAt() => _createAt != null;

  // "updated_at" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "dec" field.
  String? _dec;
  String get dec => _dec ?? '';
  bool hasDec() => _dec != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  void _initializeFields() {
    _merchantId = snapshotData['merchant_id'] as String?;
    _name = snapshotData['name'] as String?;
    _logoUrl = snapshotData['logo_url'] as String?;
    _address = snapshotData['address'] as String?;
    _contactPerson = snapshotData['contact_person'] as String?;
    _phone = snapshotData['phone'] as String?;
    _email = snapshotData['email'] as String?;
    _userId = snapshotData['user_id'] as DocumentReference?;
    _createAt = snapshotData['create_at'] as DateTime?;
    _updatedAt = snapshotData['updated_at'] as DateTime?;
    _dec = snapshotData['dec'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('merchants');

  static Stream<MerchantsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MerchantsRecord.fromSnapshot(s));

  static Future<MerchantsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MerchantsRecord.fromSnapshot(s));

  static MerchantsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MerchantsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MerchantsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MerchantsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MerchantsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MerchantsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMerchantsRecordData({
  String? merchantId,
  String? name,
  String? logoUrl,
  String? address,
  String? contactPerson,
  String? phone,
  String? email,
  DocumentReference? userId,
  DateTime? createAt,
  DateTime? updatedAt,
  String? dec,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'merchant_id': merchantId,
      'name': name,
      'logo_url': logoUrl,
      'address': address,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'user_id': userId,
      'create_at': createAt,
      'updated_at': updatedAt,
      'dec': dec,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
    }.withoutNulls,
  );

  return firestoreData;
}

class MerchantsRecordDocumentEquality implements Equality<MerchantsRecord> {
  const MerchantsRecordDocumentEquality();

  @override
  bool equals(MerchantsRecord? e1, MerchantsRecord? e2) {
    return e1?.merchantId == e2?.merchantId &&
        e1?.name == e2?.name &&
        e1?.logoUrl == e2?.logoUrl &&
        e1?.address == e2?.address &&
        e1?.contactPerson == e2?.contactPerson &&
        e1?.phone == e2?.phone &&
        e1?.email == e2?.email &&
        e1?.userId == e2?.userId &&
        e1?.createAt == e2?.createAt &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.dec == e2?.dec &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber;
  }

  @override
  int hash(MerchantsRecord? e) => const ListEquality().hash([
        e?.merchantId,
        e?.name,
        e?.logoUrl,
        e?.address,
        e?.contactPerson,
        e?.phone,
        e?.email,
        e?.userId,
        e?.createAt,
        e?.updatedAt,
        e?.dec,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber
      ]);

  @override
  bool isValidKey(Object? o) => o is MerchantsRecord;
}
