import 'package:freezed_annotation/freezed_annotation.dart';

part 'personal_information_model.freezed.dart';
part 'personal_information_model.g.dart';

@freezed
abstract class PersonalInformationModel with _$PersonalInformationModel {
  const factory PersonalInformationModel({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "name") required String name,
    @JsonKey(name: "country") required String country,
    @JsonKey(name: "number") required String number,
    @JsonKey(name: "email") required String email,
    @JsonKey(name: "wantsEmails") bool? wantsEmails,
    @JsonKey(name: "favoriteJobIds") @Default([]) List<int> favoriteJobs,
    @Default([]) List<int> ownedjobs,
    @Default([]) List<int> ownedapplications,
    @Default([]) List<int> resume,
    @JsonKey(name: "fieldsOfInterest") List<String>? fieldsOfInterest,
  }) = _PersonalInformationModel;

  factory PersonalInformationModel.fromJson(Map<String, dynamic> json) =>
      _$PersonalInformationModelFromJson(json);
}
