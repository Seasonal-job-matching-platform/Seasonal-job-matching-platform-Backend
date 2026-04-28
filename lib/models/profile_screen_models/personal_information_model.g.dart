// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_information_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PersonalInformationModel _$PersonalInformationModelFromJson(
  Map<String, dynamic> json,
) => _PersonalInformationModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  country: json['country'] as String,
  number: json['number'] as String,
  email: json['email'] as String,
  wantsEmails: json['wantsEmails'] as bool?,
  favoriteJobs:
      (json['favoriteJobIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  ownedjobs:
      (json['ownedjobs'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  ownedapplications:
      (json['ownedapplications'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  resume:
      (json['resume'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  fieldsOfInterest: (json['fieldsOfInterest'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$PersonalInformationModelToJson(
  _PersonalInformationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'country': instance.country,
  'number': instance.number,
  'email': instance.email,
  'wantsEmails': instance.wantsEmails,
  'favoriteJobIds': instance.favoriteJobs,
  'ownedjobs': instance.ownedjobs,
  'ownedapplications': instance.ownedapplications,
  'resume': instance.resume,
  'fieldsOfInterest': instance.fieldsOfInterest,
};
