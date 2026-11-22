import 'dart:convert';
import 'package:flutter/services.dart';

class DiscoverPromo {
  final String id;
  final String badge;
  final String title;
  final String description;
  final String url;
  final String cta;

  const DiscoverPromo({
    required this.id,
    required this.badge,
    required this.title,
    required this.description,
    required this.url,
    required this.cta,
  });

  factory DiscoverPromo.fromJson(Map<String, dynamic> json) {
    return DiscoverPromo(
      id: json['id'] as String? ?? '',
      badge: json['badge'] as String? ?? 'DISCOVER',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? 'https://xweet.in',
      cta: json['cta'] as String? ?? 'Explore',
    );
  }

  static const List<DiscoverPromo> defaultPromos = [
    DiscoverPromo(
      id: 'xweet_web',
      badge: 'ECOSYSTEM',
      title: 'Explore Xweet',
      description: 'More clean apps, games and experiments at xweet.in',
      url: 'https://xweet.in',
      cta: 'xweet.in',
    ),
    DiscoverPromo(
      id: 'wallpapers',
      badge: 'GOODIES',
      title: 'Minimal Wallpapers',
      description: 'Get cool minimal wallpapers curated for your devices',
      url: 'https://xweet.in',
      cta: 'Get Wallpapers',
    ),
    DiscoverPromo(
      id: 'infyn_browser',
      badge: 'AD-FREE TOOL',
      title: 'Infyn Software',
      description: 'Check out cool ad-free browser tools at infyn.software',
      url: 'https://infyn.software',
      cta: 'infyn.software',
    ),
  ];

  static Future<List<DiscoverPromo>> loadFromAsset() async {
    try {
      final jsonString = await rootBundle.loadString('assets/discover_promos.json');
      final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((item) => DiscoverPromo.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return defaultPromos;
    }
  }
}
