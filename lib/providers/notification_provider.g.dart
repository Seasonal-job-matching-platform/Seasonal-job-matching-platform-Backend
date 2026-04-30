// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Notifications)
const notificationsProvider = NotificationsFamily._();

final class NotificationsProvider
    extends $AsyncNotifierProvider<Notifications, List<NotificationModel>> {
  const NotificationsProvider._({
    required NotificationsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'notificationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notificationsHash();

  @override
  String toString() {
    return r'notificationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Notifications create() => Notifications();

  @override
  bool operator ==(Object other) {
    return other is NotificationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationsHash() => r'f7424ee4efdfd617582f627c5eb8d1f66a32a86f';

final class NotificationsFamily extends $Family
    with
        $ClassFamilyOverride<
          Notifications,
          AsyncValue<List<NotificationModel>>,
          List<NotificationModel>,
          FutureOr<List<NotificationModel>>,
          int
        > {
  const NotificationsFamily._()
    : super(
        retry: null,
        name: r'notificationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NotificationsProvider call(int userId) =>
      NotificationsProvider._(argument: userId, from: this);

  @override
  String toString() => r'notificationsProvider';
}

abstract class _$Notifications extends $AsyncNotifier<List<NotificationModel>> {
  late final _$args = ref.$arg as int;
  int get userId => _$args;

  FutureOr<List<NotificationModel>> build(int userId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<NotificationModel>>,
              List<NotificationModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<NotificationModel>>,
                List<NotificationModel>
              >,
              AsyncValue<List<NotificationModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
