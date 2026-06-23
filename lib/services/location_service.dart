import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/contexts.dart';
import '../models/place_context.dart';
import 'place_resolver.dart';

enum LocationReadStatus { ready, denied, disabled, unavailable }

class LocationRead {
  const LocationRead({
    required this.status,
    required this.place,
    required this.context,
    required this.time,
    required this.message,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.cached = false,
  });

  final LocationReadStatus status;
  final PlaceType place;
  final PlaceContext context;
  final TimeContext time;
  final String message;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final bool cached;

  bool get isReady => status == LocationReadStatus.ready;

  String get accuracyLabel {
    final accuracy = accuracyMeters;
    if (accuracy == null) return '精度不明';
    return '約${accuracy.round()}m';
  }
}

class LocationHeuristics {
  const LocationHeuristics();

  static TimeContext timeFromHour(int hour) {
    if (hour >= 5 && hour < 11) return TimeContext.morning;
    if (hour >= 11 && hour < 16) return TimeContext.noon;
    if (hour >= 16 && hour < 20) return TimeContext.sunset;
    return TimeContext.night;
  }

  static PlaceType placeFromCoordinates(double latitude, double longitude) {
    final latBucket = (latitude.abs() * 1000).floor();
    final lonBucket = (longitude.abs() * 1000).floor();
    final bucket = (latBucket + lonBucket) % 8;
    return const [
      PlaceType.station,
      PlaceType.park,
      PlaceType.office,
      PlaceType.river,
      PlaceType.cafe,
      PlaceType.residential,
      PlaceType.shopping,
      PlaceType.nightStore,
    ][bucket];
  }
}

class DeviceLocationService {
  const DeviceLocationService();

  Future<LocationRead> readCurrentContext() async {
    final time = LocationHeuristics.timeFromHour(DateTime.now().hour);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationRead(
          status: LocationReadStatus.disabled,
          place: PlaceType.residential,
          context: PlaceContext.manual(PlaceType.residential),
          time: time,
          message: '端末の位置情報がオフです。手動で場所を選んで続けられます。',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return LocationRead(
          status: LocationReadStatus.denied,
          place: PlaceType.residential,
          context: PlaceContext.manual(PlaceType.residential),
          time: time,
          message: '位置情報の許可がないため、今日は手動選択で進めます。',
        );
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          ),
        );
        return await _fromPosition(position, time, cached: false);
      } on TimeoutException {
        final cached = await Geolocator.getLastKnownPosition();
        if (cached != null) {
          return await _fromPosition(cached, time, cached: true);
        }
        return LocationRead(
          status: LocationReadStatus.unavailable,
          place: PlaceType.residential,
          context: PlaceContext.manual(PlaceType.residential),
          time: time,
          message: '現在地の取得が時間切れになりました。手動で選べばそのまま遊べます。',
        );
      }
    } catch (_) {
      return LocationRead(
        status: LocationReadStatus.unavailable,
        place: PlaceType.residential,
        context: PlaceContext.manual(PlaceType.residential),
        time: time,
        message: 'この環境では現在地を取得できませんでした。手動選択で続けられます。',
      );
    }
  }

  Future<LocationRead> _fromPosition(
    Position position,
    TimeContext time, {
    required bool cached,
  }) async {
    final context = await PlaceResolver().resolve(
      position.latitude,
      position.longitude,
    );
    final cacheText = cached ? '前回取得した位置から' : '現在地から';
    return LocationRead(
      status: LocationReadStatus.ready,
      place: context.place,
      context: context,
      time: time,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      cached: cached,
      message:
          '$cacheText「${context.displayHint}」として読み取りました。記憶には住所ではなく場所カテゴリだけを使います。',
    );
  }
}
