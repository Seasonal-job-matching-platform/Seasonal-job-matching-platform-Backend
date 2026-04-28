// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'personal_information_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PersonalInformationModel {

@JsonKey(name: "id") int get id;@JsonKey(name: "name") String get name;@JsonKey(name: "country") String get country;@JsonKey(name: "number") String get number;@JsonKey(name: "email") String get email;@JsonKey(name: "wantsEmails") bool? get wantsEmails;@JsonKey(name: "favoriteJobIds") List<int> get favoriteJobs; List<int> get ownedjobs; List<int> get ownedapplications; List<int> get resume;@JsonKey(name: "fieldsOfInterest") List<String>? get fieldsOfInterest;
/// Create a copy of PersonalInformationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonalInformationModelCopyWith<PersonalInformationModel> get copyWith => _$PersonalInformationModelCopyWithImpl<PersonalInformationModel>(this as PersonalInformationModel, _$identity);

  /// Serializes this PersonalInformationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonalInformationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.country, country) || other.country == country)&&(identical(other.number, number) || other.number == number)&&(identical(other.email, email) || other.email == email)&&(identical(other.wantsEmails, wantsEmails) || other.wantsEmails == wantsEmails)&&const DeepCollectionEquality().equals(other.favoriteJobs, favoriteJobs)&&const DeepCollectionEquality().equals(other.ownedjobs, ownedjobs)&&const DeepCollectionEquality().equals(other.ownedapplications, ownedapplications)&&const DeepCollectionEquality().equals(other.resume, resume)&&const DeepCollectionEquality().equals(other.fieldsOfInterest, fieldsOfInterest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,country,number,email,wantsEmails,const DeepCollectionEquality().hash(favoriteJobs),const DeepCollectionEquality().hash(ownedjobs),const DeepCollectionEquality().hash(ownedapplications),const DeepCollectionEquality().hash(resume),const DeepCollectionEquality().hash(fieldsOfInterest));

@override
String toString() {
  return 'PersonalInformationModel(id: $id, name: $name, country: $country, number: $number, email: $email, wantsEmails: $wantsEmails, favoriteJobs: $favoriteJobs, ownedjobs: $ownedjobs, ownedapplications: $ownedapplications, resume: $resume, fieldsOfInterest: $fieldsOfInterest)';
}


}

/// @nodoc
abstract mixin class $PersonalInformationModelCopyWith<$Res>  {
  factory $PersonalInformationModelCopyWith(PersonalInformationModel value, $Res Function(PersonalInformationModel) _then) = _$PersonalInformationModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "id") int id,@JsonKey(name: "name") String name,@JsonKey(name: "country") String country,@JsonKey(name: "number") String number,@JsonKey(name: "email") String email,@JsonKey(name: "wantsEmails") bool? wantsEmails,@JsonKey(name: "favoriteJobIds") List<int> favoriteJobs, List<int> ownedjobs, List<int> ownedapplications, List<int> resume,@JsonKey(name: "fieldsOfInterest") List<String>? fieldsOfInterest
});




}
/// @nodoc
class _$PersonalInformationModelCopyWithImpl<$Res>
    implements $PersonalInformationModelCopyWith<$Res> {
  _$PersonalInformationModelCopyWithImpl(this._self, this._then);

  final PersonalInformationModel _self;
  final $Res Function(PersonalInformationModel) _then;

/// Create a copy of PersonalInformationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? country = null,Object? number = null,Object? email = null,Object? wantsEmails = freezed,Object? favoriteJobs = null,Object? ownedjobs = null,Object? ownedapplications = null,Object? resume = null,Object? fieldsOfInterest = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,wantsEmails: freezed == wantsEmails ? _self.wantsEmails : wantsEmails // ignore: cast_nullable_to_non_nullable
as bool?,favoriteJobs: null == favoriteJobs ? _self.favoriteJobs : favoriteJobs // ignore: cast_nullable_to_non_nullable
as List<int>,ownedjobs: null == ownedjobs ? _self.ownedjobs : ownedjobs // ignore: cast_nullable_to_non_nullable
as List<int>,ownedapplications: null == ownedapplications ? _self.ownedapplications : ownedapplications // ignore: cast_nullable_to_non_nullable
as List<int>,resume: null == resume ? _self.resume : resume // ignore: cast_nullable_to_non_nullable
as List<int>,fieldsOfInterest: freezed == fieldsOfInterest ? _self.fieldsOfInterest : fieldsOfInterest // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonalInformationModel].
extension PersonalInformationModelPatterns on PersonalInformationModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonalInformationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonalInformationModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonalInformationModel value)  $default,){
final _that = this;
switch (_that) {
case _PersonalInformationModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonalInformationModel value)?  $default,){
final _that = this;
switch (_that) {
case _PersonalInformationModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: "id")  int id, @JsonKey(name: "name")  String name, @JsonKey(name: "country")  String country, @JsonKey(name: "number")  String number, @JsonKey(name: "email")  String email, @JsonKey(name: "wantsEmails")  bool? wantsEmails, @JsonKey(name: "favoriteJobIds")  List<int> favoriteJobs,  List<int> ownedjobs,  List<int> ownedapplications,  List<int> resume, @JsonKey(name: "fieldsOfInterest")  List<String>? fieldsOfInterest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonalInformationModel() when $default != null:
return $default(_that.id,_that.name,_that.country,_that.number,_that.email,_that.wantsEmails,_that.favoriteJobs,_that.ownedjobs,_that.ownedapplications,_that.resume,_that.fieldsOfInterest);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: "id")  int id, @JsonKey(name: "name")  String name, @JsonKey(name: "country")  String country, @JsonKey(name: "number")  String number, @JsonKey(name: "email")  String email, @JsonKey(name: "wantsEmails")  bool? wantsEmails, @JsonKey(name: "favoriteJobIds")  List<int> favoriteJobs,  List<int> ownedjobs,  List<int> ownedapplications,  List<int> resume, @JsonKey(name: "fieldsOfInterest")  List<String>? fieldsOfInterest)  $default,) {final _that = this;
switch (_that) {
case _PersonalInformationModel():
return $default(_that.id,_that.name,_that.country,_that.number,_that.email,_that.wantsEmails,_that.favoriteJobs,_that.ownedjobs,_that.ownedapplications,_that.resume,_that.fieldsOfInterest);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: "id")  int id, @JsonKey(name: "name")  String name, @JsonKey(name: "country")  String country, @JsonKey(name: "number")  String number, @JsonKey(name: "email")  String email, @JsonKey(name: "wantsEmails")  bool? wantsEmails, @JsonKey(name: "favoriteJobIds")  List<int> favoriteJobs,  List<int> ownedjobs,  List<int> ownedapplications,  List<int> resume, @JsonKey(name: "fieldsOfInterest")  List<String>? fieldsOfInterest)?  $default,) {final _that = this;
switch (_that) {
case _PersonalInformationModel() when $default != null:
return $default(_that.id,_that.name,_that.country,_that.number,_that.email,_that.wantsEmails,_that.favoriteJobs,_that.ownedjobs,_that.ownedapplications,_that.resume,_that.fieldsOfInterest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PersonalInformationModel implements PersonalInformationModel {
  const _PersonalInformationModel({@JsonKey(name: "id") required this.id, @JsonKey(name: "name") required this.name, @JsonKey(name: "country") required this.country, @JsonKey(name: "number") required this.number, @JsonKey(name: "email") required this.email, @JsonKey(name: "wantsEmails") this.wantsEmails, @JsonKey(name: "favoriteJobIds") final  List<int> favoriteJobs = const [], final  List<int> ownedjobs = const [], final  List<int> ownedapplications = const [], final  List<int> resume = const [], @JsonKey(name: "fieldsOfInterest") final  List<String>? fieldsOfInterest}): _favoriteJobs = favoriteJobs,_ownedjobs = ownedjobs,_ownedapplications = ownedapplications,_resume = resume,_fieldsOfInterest = fieldsOfInterest;
  factory _PersonalInformationModel.fromJson(Map<String, dynamic> json) => _$PersonalInformationModelFromJson(json);

@override@JsonKey(name: "id") final  int id;
@override@JsonKey(name: "name") final  String name;
@override@JsonKey(name: "country") final  String country;
@override@JsonKey(name: "number") final  String number;
@override@JsonKey(name: "email") final  String email;
@override@JsonKey(name: "wantsEmails") final  bool? wantsEmails;
 final  List<int> _favoriteJobs;
@override@JsonKey(name: "favoriteJobIds") List<int> get favoriteJobs {
  if (_favoriteJobs is EqualUnmodifiableListView) return _favoriteJobs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favoriteJobs);
}

 final  List<int> _ownedjobs;
@override@JsonKey() List<int> get ownedjobs {
  if (_ownedjobs is EqualUnmodifiableListView) return _ownedjobs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownedjobs);
}

 final  List<int> _ownedapplications;
@override@JsonKey() List<int> get ownedapplications {
  if (_ownedapplications is EqualUnmodifiableListView) return _ownedapplications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownedapplications);
}

 final  List<int> _resume;
@override@JsonKey() List<int> get resume {
  if (_resume is EqualUnmodifiableListView) return _resume;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_resume);
}

 final  List<String>? _fieldsOfInterest;
@override@JsonKey(name: "fieldsOfInterest") List<String>? get fieldsOfInterest {
  final value = _fieldsOfInterest;
  if (value == null) return null;
  if (_fieldsOfInterest is EqualUnmodifiableListView) return _fieldsOfInterest;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of PersonalInformationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonalInformationModelCopyWith<_PersonalInformationModel> get copyWith => __$PersonalInformationModelCopyWithImpl<_PersonalInformationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonalInformationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonalInformationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.country, country) || other.country == country)&&(identical(other.number, number) || other.number == number)&&(identical(other.email, email) || other.email == email)&&(identical(other.wantsEmails, wantsEmails) || other.wantsEmails == wantsEmails)&&const DeepCollectionEquality().equals(other._favoriteJobs, _favoriteJobs)&&const DeepCollectionEquality().equals(other._ownedjobs, _ownedjobs)&&const DeepCollectionEquality().equals(other._ownedapplications, _ownedapplications)&&const DeepCollectionEquality().equals(other._resume, _resume)&&const DeepCollectionEquality().equals(other._fieldsOfInterest, _fieldsOfInterest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,country,number,email,wantsEmails,const DeepCollectionEquality().hash(_favoriteJobs),const DeepCollectionEquality().hash(_ownedjobs),const DeepCollectionEquality().hash(_ownedapplications),const DeepCollectionEquality().hash(_resume),const DeepCollectionEquality().hash(_fieldsOfInterest));

@override
String toString() {
  return 'PersonalInformationModel(id: $id, name: $name, country: $country, number: $number, email: $email, wantsEmails: $wantsEmails, favoriteJobs: $favoriteJobs, ownedjobs: $ownedjobs, ownedapplications: $ownedapplications, resume: $resume, fieldsOfInterest: $fieldsOfInterest)';
}


}

/// @nodoc
abstract mixin class _$PersonalInformationModelCopyWith<$Res> implements $PersonalInformationModelCopyWith<$Res> {
  factory _$PersonalInformationModelCopyWith(_PersonalInformationModel value, $Res Function(_PersonalInformationModel) _then) = __$PersonalInformationModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: "id") int id,@JsonKey(name: "name") String name,@JsonKey(name: "country") String country,@JsonKey(name: "number") String number,@JsonKey(name: "email") String email,@JsonKey(name: "wantsEmails") bool? wantsEmails,@JsonKey(name: "favoriteJobIds") List<int> favoriteJobs, List<int> ownedjobs, List<int> ownedapplications, List<int> resume,@JsonKey(name: "fieldsOfInterest") List<String>? fieldsOfInterest
});




}
/// @nodoc
class __$PersonalInformationModelCopyWithImpl<$Res>
    implements _$PersonalInformationModelCopyWith<$Res> {
  __$PersonalInformationModelCopyWithImpl(this._self, this._then);

  final _PersonalInformationModel _self;
  final $Res Function(_PersonalInformationModel) _then;

/// Create a copy of PersonalInformationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? country = null,Object? number = null,Object? email = null,Object? wantsEmails = freezed,Object? favoriteJobs = null,Object? ownedjobs = null,Object? ownedapplications = null,Object? resume = null,Object? fieldsOfInterest = freezed,}) {
  return _then(_PersonalInformationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,wantsEmails: freezed == wantsEmails ? _self.wantsEmails : wantsEmails // ignore: cast_nullable_to_non_nullable
as bool?,favoriteJobs: null == favoriteJobs ? _self._favoriteJobs : favoriteJobs // ignore: cast_nullable_to_non_nullable
as List<int>,ownedjobs: null == ownedjobs ? _self._ownedjobs : ownedjobs // ignore: cast_nullable_to_non_nullable
as List<int>,ownedapplications: null == ownedapplications ? _self._ownedapplications : ownedapplications // ignore: cast_nullable_to_non_nullable
as List<int>,resume: null == resume ? _self._resume : resume // ignore: cast_nullable_to_non_nullable
as List<int>,fieldsOfInterest: freezed == fieldsOfInterest ? _self._fieldsOfInterest : fieldsOfInterest // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
