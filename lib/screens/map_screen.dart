import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/contexts.dart';
import '../models/dna_trait.dart';
import '../models/map_familiar.dart';
import '../models/map_spot.dart';
import '../services/location_service.dart';
import '../services/spot_placement_service.dart';
import '../services/spot_grid_service.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.showTiles = true});

  final bool showTiles;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();

  LatLng _current = SpotGridService.defaultCenter;
  List<MapSpot> _spots = SpotPlacementService.generateAround(
    SpotGridService.defaultCenter,
  );
  StreamSubscription<Position>? _positionSub;
  bool _hasGps = false;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapReady = true;
      _setPosition(SpotGridService.defaultCenter, centerMap: false);
      _startLocation();
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _startLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
      _setPosition(
        LatLng(position.latitude, position.longitude),
        centerMap: true,
        fromGps: true,
      );

      _positionSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              distanceFilter: 8,
            ),
          ).listen((position) {
            _setPosition(
              LatLng(position.latitude, position.longitude),
              centerMap: true,
              fromGps: true,
            );
          });
    } catch (_) {
      _setPosition(SpotGridService.defaultCenter, centerMap: false);
    }
  }

  void _setPosition(
    LatLng point, {
    required bool centerMap,
    bool fromGps = false,
  }) {
    if (!mounted) return;
    setState(() {
      _current = point;
      _hasGps = fromGps || _hasGps;
      _spots = SpotPlacementService.generateAround(point);
    });

    if (centerMap && _mapReady) {
      _mapController.move(point, 17);
    }
    _captureEnteredSpot();
  }

  void _captureEnteredSpot() {
    final state = AppScope.of(context);
    final spot = SpotGridService.enteredSpot(
      _current,
      _spots,
      state.capturedSpotIds,
    );
    if (spot == null) return;

    final familiar = state.collectSpot(
      spot,
      time: LocationHeuristics.timeFromHour(DateTime.now().hour),
      weather: WeatherContext.clear,
      placeContext: spot.toPlaceContext(),
    );
    if (familiar == null || !mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final captured = state.capturedSpotIds;
    final uncaptured = _spots
        .where((spot) => !captured.contains(spot.id))
        .toList(growable: false);

    return Scaffold(
      key: const ValueKey('geo-map-screen'),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _current,
              initialZoom: 17,
              minZoom: 15,
              maxZoom: 19,
              onTap: (_, point) {
                if (!_hasGps || kIsWeb) {
                  _setPosition(point, centerMap: false);
                }
              },
            ),
            children: [
              if (widget.showTiles)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'geofamiliar',
                  maxZoom: 19,
                )
              else
                const _FallbackMapLayer(),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _current,
                    radius: SpotGridService.captureRadiusMeters,
                    useRadiusInMeter: true,
                    color: AppColors.mint.withValues(alpha: 0.16),
                    borderColor: AppColors.mintDeep.withValues(alpha: 0.45),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  for (final spot in uncaptured)
                    Marker(
                      point: LatLng(spot.latitude, spot.longitude),
                      width: 48,
                      height: 48,
                      child: _SpotPin(spot: spot),
                    ),
                  for (final familiar in state.familiars)
                    Marker(
                      point: LatLng(familiar.latitude, familiar.longitude),
                      width: 56,
                      height: 56,
                      child: _FamiliarPin(familiar: familiar),
                    ),
                  Marker(
                    point: _current,
                    width: 42,
                    height: 42,
                    child: const _CurrentPositionPin(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FallbackMapLayer extends StatelessWidget {
  const _FallbackMapLayer();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: Color(0xFFE9F4EF), child: SizedBox.expand());
  }
}

class _CurrentPositionPin extends StatelessWidget {
  const _CurrentPositionPin();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.skyBlue, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.skyBlue.withValues(alpha: 0.35),
            blurRadius: 16,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.near_me_rounded, size: 18, color: AppColors.skyBlue),
      ),
    );
  }
}

class _SpotPin extends StatelessWidget {
  const _SpotPin({required this.spot});

  final MapSpot spot;

  @override
  Widget build(BuildContext context) {
    final color = _placeColor(spot.place);
    final background = spot.isConfirmed ? color : Colors.white;
    final iconColor = spot.isConfirmed ? Colors.white : color;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: spot.isConfirmed ? 4 : 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.32),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(_placeIcon(spot.place), color: iconColor, size: 24),
    );
  }
}

class _FamiliarPin extends StatelessWidget {
  const _FamiliarPin({required this.familiar});

  final MapFamiliar familiar;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        shape: BoxShape.circle,
        border: Border.all(color: _placeColor(familiar.place), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _FamiliarSprite(place: familiar.place, size: 48),
    );
  }
}

class _FamiliarSprite extends StatelessWidget {
  const _FamiliarSprite({required this.place, required this.size});

  final PlaceType place;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/companion/hatchling/${_traitForPlace(place).name}_normal.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

IconData _placeIcon(PlaceType place) {
  return switch (place) {
    PlaceType.station => Icons.train_rounded,
    PlaceType.park => Icons.park_rounded,
    PlaceType.office => Icons.business_rounded,
    PlaceType.river => Icons.water_rounded,
    PlaceType.cafe => Icons.local_cafe_rounded,
    PlaceType.residential => Icons.home_rounded,
    PlaceType.shopping => Icons.storefront_rounded,
    PlaceType.nightStore => Icons.local_convenience_store_rounded,
    PlaceType.travel => Icons.luggage_rounded,
  };
}

Color _placeColor(PlaceType place) => _traitForPlace(place).color;

DnaTrait _traitForPlace(PlaceType place) {
  return switch (place) {
    PlaceType.station => DnaTrait.vitality,
    PlaceType.park => DnaTrait.calm,
    PlaceType.office => DnaTrait.focus,
    PlaceType.river => DnaTrait.calm,
    PlaceType.cafe => DnaTrait.warmth,
    PlaceType.residential => DnaTrait.warmth,
    PlaceType.shopping => DnaTrait.curiosity,
    PlaceType.nightStore => DnaTrait.wonder,
    PlaceType.travel => DnaTrait.curiosity,
  };
}
