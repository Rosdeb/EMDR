// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF07070F);
  static const Color surface = Color(0x0AFFFFFF);
  static const Color surface2 = Color(0x14FFFFFF);
  static const Color border = Color(0x1AFFFFFF);
  static const Color accent = Color(0xFF9F97EE);
  static const Color accentGlow = Color(0x339F97EE);
  static const Color text = Color(0xFFEEECFF);
  static const Color muted = Color(0xFF8885AA);

  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(primary: accent, surface: bg),
    fontFamily: 'serif',
  );
}

class AppConstants {
  static const int defaultSets = 34;
  static const int sweepsPerSet = 1;
  static const double defaultSpeed = 12.0;
}

// Background scene types
enum BgScene { deepSpace, ocean, forest, energy, aurora, crystal }

extension BgSceneExt on BgScene {
  String get label {
    switch (this) {
      case BgScene.deepSpace:
        return 'Deep Space';
      case BgScene.ocean:
        return 'Ocean Depths';
      case BgScene.forest:
        return 'Forest';
      case BgScene.energy:
        return 'Abstract Energy';
      case BgScene.aurora:
        return 'Mountain & Aurora';
      case BgScene.crystal:
        return 'Crystal Cave';
    }
  }

  Color get primaryColor {
    switch (this) {
      case BgScene.deepSpace:
        return const Color(0xFF5533AA);
      case BgScene.ocean:
        return const Color(0xFF00FFCC);
      case BgScene.forest:
        return const Color(0xFF44FF44);
      case BgScene.energy:
        return const Color(0xFFFF00CC);
      case BgScene.aurora:
        return const Color(0xFF00FF88);
      case BgScene.crystal:
        return const Color(0xFFAA44FF);
    }
  }
}

// Object types for bilateral stimulation
enum BilateralObject {
  orb,
  plasma,
  pulsar,
  sunbeam,
  star,
  comet,
  galaxy,
  nebula,
  blackhole,
  butterfly,
  lotus,
  feather,
  flame,
  snowflake,
  leaf,
  dandelion,
  crystal,
  diamond,
  prism,
  geode,
  jellyfish,
  droplet,
  ripple,
  bubble,
  aurora,
  mandala,
  torus,
  merkaba,
}

extension BilateralObjectExt on BilateralObject {
  String get key => name;

  String get label {
    switch (this) {
      case BilateralObject.orb:
        return 'Luminous Orb';
      case BilateralObject.plasma:
        return 'Plasma Ball';
      case BilateralObject.pulsar:
        return 'Pulsar Ring';
      case BilateralObject.sunbeam:
        return 'Sunbeam Disc';
      case BilateralObject.star:
        return 'Shooting Star';
      case BilateralObject.comet:
        return 'Comet Trail';
      case BilateralObject.galaxy:
        return 'Galaxy Spiral';
      case BilateralObject.nebula:
        return 'Nebula Cloud';
      case BilateralObject.blackhole:
        return 'Vortex Portal';
      case BilateralObject.butterfly:
        return 'Butterfly';
      case BilateralObject.lotus:
        return 'Lotus Bloom';
      case BilateralObject.feather:
        return 'Floating Feather';
      case BilateralObject.flame:
        return 'Gentle Flame';
      case BilateralObject.snowflake:
        return 'Snowflake';
      case BilateralObject.leaf:
        return 'Drifting Leaf';
      case BilateralObject.dandelion:
        return 'Dandelion Seed';
      case BilateralObject.crystal:
        return 'Crystal Shard';
      case BilateralObject.diamond:
        return 'Diamond';
      case BilateralObject.prism:
        return 'Prism Burst';
      case BilateralObject.geode:
        return 'Amethyst Geode';
      case BilateralObject.jellyfish:
        return 'Jellyfish';
      case BilateralObject.droplet:
        return 'Water Droplet';
      case BilateralObject.ripple:
        return 'Ripple Wave';
      case BilateralObject.bubble:
        return 'Soap Bubble';
      case BilateralObject.aurora:
        return 'Aurora Wave';
      case BilateralObject.mandala:
        return 'Mandala';
      case BilateralObject.torus:
        return 'Torus Knot';
      case BilateralObject.merkaba:
        return 'Merkaba Star';
    }
  }

  String get category {
    if ([
      BilateralObject.orb,
      BilateralObject.plasma,
      BilateralObject.pulsar,
      BilateralObject.sunbeam,
      BilateralObject.aurora,
    ].contains(this))
      return 'Light & Energy';
    if ([
      BilateralObject.comet,
      BilateralObject.star,
      BilateralObject.galaxy,
      BilateralObject.nebula,
      BilateralObject.blackhole,
    ].contains(this))
      return 'Cosmic';
    if ([
      BilateralObject.butterfly,
      BilateralObject.lotus,
      BilateralObject.feather,
      BilateralObject.flame,
      BilateralObject.snowflake,
      BilateralObject.leaf,
      BilateralObject.dandelion,
    ].contains(this))
      return 'Nature';
    if ([
      BilateralObject.crystal,
      BilateralObject.diamond,
      BilateralObject.prism,
      BilateralObject.geode,
    ].contains(this))
      return 'Crystal & Gem';
    if ([
      BilateralObject.jellyfish,
      BilateralObject.droplet,
      BilateralObject.ripple,
      BilateralObject.bubble,
    ].contains(this))
      return 'Fluid & Flow';
    return 'Sacred Geometry';
  }
}

BilateralObject? bilateralObjectFromSource(String source) {
  var id = source.trim();
  final separator = id.indexOf(':');
  if (separator >= 0) id = id.substring(separator + 1);
  id = id.toLowerCase().replaceAll('-', '').replaceAll('_', '');

  for (final object in BilateralObject.values) {
    if (object.name.toLowerCase() == id) return object;
  }

  return null;
}

bool isAdvancedBilateralObject(String source) =>
    bilateralObjectFromSource(source) != null;

double bilateralObjectDisplaySize(BilateralObject object) {
  switch (object) {
    case BilateralObject.comet:
    case BilateralObject.galaxy:
    case BilateralObject.jellyfish:
    case BilateralObject.aurora:
      return 132;
    case BilateralObject.butterfly:
    case BilateralObject.lotus:
    case BilateralObject.mandala:
    case BilateralObject.torus:
    case BilateralObject.merkaba:
      return 122;
    case BilateralObject.feather:
    case BilateralObject.dandelion:
    case BilateralObject.ripple:
      return 116;
    default:
      return 110;
  }
}

bool bilateralObjectHasReflection(BilateralObject object) {
  return const {
    BilateralObject.orb,
    BilateralObject.sunbeam,
    BilateralObject.star,
    BilateralObject.crystal,
    BilateralObject.diamond,
    BilateralObject.droplet,
    BilateralObject.bubble,
  }.contains(object);
}

// Sound types
enum SoundType { tick, chime, rain, bell, none }

extension SoundTypeExt on SoundType {
  String get label {
    switch (this) {
      case SoundType.tick:
        return 'Tick';
      case SoundType.chime:
        return 'Chime';
      case SoundType.rain:
        return 'Rain';
      case SoundType.bell:
        return 'Bell';
      case SoundType.none:
        return 'Off';
    }
  }
}
