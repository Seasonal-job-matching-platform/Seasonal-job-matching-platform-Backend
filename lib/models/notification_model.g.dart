// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    _NotificationModel(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
      isRead: json['isRead'] as bool? ?? false,
      applicationId: json['applicationId'] as String?,
      jobTitle: json['jobTitle'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'message': instance.message,
      'timestamp': instance.timestamp,
      'isRead': instance.isRead,
      'applicationId': instance.applicationId,
      'jobTitle': instance.jobTitle,
      'status': instance.status,
    };
