import 'package:flutter/widgets.dart';

import 'contexts.dart';
import 'dna_trait.dart';

/// A collected memory - a single diary line in the companion's voice, generated
/// from a walk. Memories are the keepsakes that make a companion hard to leave.
class MemoryCard {
  const MemoryCard({
    required this.id,
    required this.title,
    required this.diary,
    required this.lead,
    required this.places,
    required this.time,
    required this.weather,
    required this.dayLabel,
    this.premium = false,
  });

  final String id;
  final String title;
  final String diary;
  final DnaTrait lead;
  final List<PlaceType> places;
  final TimeContext time;
  final WeatherContext weather;

  /// Human label like "Day 3" - we avoid real timestamps in the mock build.
  final String dayLabel;

  /// Premium memories carry a richer, voice-style flourish.
  final bool premium;

  /// The icon that fronts the memory - drawn from the place it began at.
  IconData get icon => places.isNotEmpty ? places.first.icon : lead.icon;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'diary': diary,
        'lead': lead.name,
        'places': places.map((p) => p.name).toList(),
        'time': time.name,
        'weather': weather.name,
        'dayLabel': dayLabel,
        'premium': premium,
      };

  factory MemoryCard.fromJson(Map<String, dynamic> json) => MemoryCard(
        id: json['id'] as String,
        title: json['title'] as String,
        diary: json['diary'] as String,
        lead: DnaTrait.fromName(json['lead'] as String),
        places: (json['places'] as List)
            .map((p) => PlaceType.fromName(p as String))
            .toList(),
        time: TimeContext.fromName(json['time'] as String),
        weather: WeatherContext.fromName(json['weather'] as String),
        dayLabel: json['dayLabel'] as String,
        premium: json['premium'] as bool? ?? false,
      );
}
