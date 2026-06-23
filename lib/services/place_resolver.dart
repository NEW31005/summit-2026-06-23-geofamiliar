import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/contexts.dart';
import '../models/place_context.dart';

class PlaceResolver {
  PlaceResolver({this.client, this.timeout = const Duration(seconds: 4)});

  final http.Client? client;
  final Duration timeout;

  static final Map<String, PlaceContext> _cache = {};

  Future<PlaceContext> resolve(double latitude, double longitude) async {
    final coarseLat = _coarse(latitude);
    final coarseLon = _coarse(longitude);
    final cacheKey = '$coarseLat,$coarseLon';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final fallback = _fallback(latitude, longitude, coarseLat, coarseLon);
    final httpClient = client ?? http.Client();
    final shouldClose = client == null;

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'jsonv2',
        'lat': latitude.toStringAsFixed(6),
        'lon': longitude.toStringAsFixed(6),
        'zoom': '17',
        'addressdetails': '1',
      });
      final response = await httpClient
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _cache[cacheKey] = fallback;
        return fallback;
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        _cache[cacheKey] = fallback;
        return fallback;
      }

      final category = PlaceMeaningMapper.fromNominatim(decoded);
      final context = PlaceContext.fromCategory(
        category,
        source: 'openstreetmap',
        coarseLatitude: coarseLat,
        coarseLongitude: coarseLon,
      );
      _cache[cacheKey] = context;
      return context;
    } catch (_) {
      _cache[cacheKey] = fallback;
      return fallback;
    } finally {
      if (shouldClose) httpClient.close();
    }
  }

  PlaceContext _fallback(
    double latitude,
    double longitude,
    double coarseLat,
    double coarseLon,
  ) {
    final place = _placeFromCoordinates(latitude, longitude);
    return PlaceContext.fromCategory(
      PlaceMeaningMapper.fromPlaceType(place),
      source: 'offline',
      coarseLatitude: coarseLat,
      coarseLongitude: coarseLon,
    );
  }

  static double _coarse(double value) => double.parse(value.toStringAsFixed(3));

  static PlaceType _placeFromCoordinates(double latitude, double longitude) {
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

class PlaceMeaningMapper {
  const PlaceMeaningMapper._();

  static PlaceMeaningCategory fromPlaceType(PlaceType place) {
    return switch (place) {
      PlaceType.station => PlaceMeaningCategory.station,
      PlaceType.park => PlaceMeaningCategory.park,
      PlaceType.office => PlaceMeaningCategory.office,
      PlaceType.river => PlaceMeaningCategory.waterside,
      PlaceType.cafe => PlaceMeaningCategory.cafe,
      PlaceType.residential => PlaceMeaningCategory.residential,
      PlaceType.shopping => PlaceMeaningCategory.commercial,
      PlaceType.nightStore => PlaceMeaningCategory.convenience,
      PlaceType.travel => PlaceMeaningCategory.travel,
    };
  }

  static PlaceMeaningCategory fromNominatim(Map<String, dynamic> json) {
    final text = _flatten(json);
    if (_hasAny(text, ['station', 'railway', 'subway', 'tram', 'bus_stop'])) {
      return PlaceMeaningCategory.station;
    }
    if (_hasAny(text, [
      'river',
      'stream',
      'canal',
      'lake',
      'pond',
      'waterway',
    ])) {
      return PlaceMeaningCategory.waterside;
    }
    if (_hasAny(text, ['park', 'garden', 'grass', 'forest', 'wood', 'green'])) {
      return PlaceMeaningCategory.park;
    }
    if (_hasAny(text, ['school', 'university', 'college', 'kindergarten'])) {
      return PlaceMeaningCategory.school;
    }
    if (_hasAny(text, [
      'hospital',
      'clinic',
      'pharmacy',
      'dentist',
      'medical',
    ])) {
      return PlaceMeaningCategory.medical;
    }
    if (_hasAny(text, ['shrine', 'temple', 'place_of_worship'])) {
      return PlaceMeaningCategory.shrineTemple;
    }
    if (_hasAny(text, ['cafe', 'coffee', 'restaurant'])) {
      return PlaceMeaningCategory.cafe;
    }
    if (_hasAny(text, ['convenience', 'supermarket'])) {
      return PlaceMeaningCategory.convenience;
    }
    if (_hasAny(text, ['mall', 'retail', 'shop', 'store', 'commercial'])) {
      return PlaceMeaningCategory.commercial;
    }
    if (_hasAny(text, ['office', 'business', 'industrial'])) {
      return PlaceMeaningCategory.office;
    }
    if (_hasAny(text, ['residential', 'neighbourhood', 'suburb', 'quarter'])) {
      return PlaceMeaningCategory.residential;
    }
    return PlaceMeaningCategory.other;
  }

  static String _flatten(Object? value) {
    final chunks = <String>[];
    void visit(Object? node) {
      if (node == null) return;
      if (node is String || node is num || node is bool) {
        chunks.add(node.toString().toLowerCase());
        return;
      }
      if (node is List) {
        for (final item in node) {
          visit(item);
        }
        return;
      }
      if (node is Map) {
        for (final entry in node.entries) {
          visit(entry.key);
          visit(entry.value);
        }
      }
    }

    visit(value);
    return chunks.join(' ');
  }

  static bool _hasAny(String text, List<String> needles) {
    return needles.any(text.contains);
  }
}
