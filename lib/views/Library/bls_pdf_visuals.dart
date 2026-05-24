import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String blsScenePrefix = 'bls-scene:';
const String blsObjectPrefix = 'bls-object:';

/// Bundled watercolor scenes when API environments are unavailable.
const List<MapEntry<String, String>> kBlsLocalScenes = [
  MapEntry('meadow', 'Watercolor Meadow'),
  MapEntry('mountains', 'Mountains'),
  MapEntry('ocean', 'Ocean'),
  MapEntry('forest', 'Forest'),
  MapEntry('night', 'Night Sky'),
  MapEntry('autumn', 'Autumn'),
];

List<String> get kBlsLocalSceneIds =>
    kBlsLocalScenes.map((entry) => entry.key).toList(growable: false);

bool isBlsSceneSource(String value) => value.startsWith(blsScenePrefix);
bool isBlsObjectSource(String value) => value.startsWith(blsObjectPrefix);

String blsSourceId(String value) {
  final index = value.indexOf(':');
  return index >= 0 ? value.substring(index + 1) : value;
}

/// Normalises saved/API scene values to a renderable environment source.
String resolveBlsEnvironmentSource(String value, {String fallback = 'meadow'}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '$blsScenePrefix$fallback';
  if (isBlsSceneSource(trimmed)) return trimmed;
  if (trimmed.startsWith('http') || trimmed.startsWith('assets/')) {
    return trimmed;
  }

  final bareId = blsSourceId(trimmed);
  if (kBlsLocalSceneIds.contains(bareId)) {
    return '$blsScenePrefix$bareId';
  }

  return trimmed;
}

bool blsObjectHasReflection(String source) {
  if (!isBlsObjectSource(source)) return false;
  return const {
    'sun',
    'moon',
    'star',
    'orb',
    'crystal',
    'pearl',
  }.contains(blsSourceId(source));
}

class BlsSceneCanvas extends StatelessWidget {
  const BlsSceneCanvas({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
  });

  final String source;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final svg = _sceneSvgs[blsSourceId(source)];
    if (svg == null) {
      return const ColoredBox(color: Color(0xFFEDE7DE));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: SvgPicture.string(
            svg,
            fit: fit,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            alignment: Alignment.center,
          ),
        );
      },
    );
  }
}

class BlsObjectCanvas extends StatelessWidget {
  const BlsObjectCanvas({super.key, required this.source, this.size = 72});

  final String source;
  final double size;

  @override
  Widget build(BuildContext context) {
    final svg = _objectSvgs[blsSourceId(source)];
    if (svg == null) {
      return Icon(Icons.blur_on_rounded, size: size, color: Colors.white);
    }

    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(svg, fit: BoxFit.contain),
    );
  }
}

const Map<String, String> _sceneSvgs = {
  'mountains':
      r'''<svg viewBox="0 0 1000 600" preserveAspectRatio="xMidYMid slice">
<defs>
<linearGradient id="skyGrad" x1="0%" y1="0%" x2="0%" y2="100%">
<stop offset="0%" style="stop-color:#faf8f2"/><stop offset="35%" style="stop-color:#f2e5d5"/>
<stop offset="70%" style="stop-color:#d8e0d8"/><stop offset="100%" style="stop-color:#c5d5d0"/>
</linearGradient>
<linearGradient id="mountNear" x1="0%" y1="0%" x2="0%" y2="100%">
<stop offset="0%" style="stop-color:#5a7a68"/><stop offset="100%" style="stop-color:#3a5a48"/>
</linearGradient>
<linearGradient id="lakeGrad" x1="0%" y1="0%" x2="0%" y2="100%">
<stop offset="0%" style="stop-color:#8ab0a5"/><stop offset="100%" style="stop-color:#5a807a"/>
</linearGradient>
<filter id="wc" x="-20%" y="-20%" width="140%" height="140%"><feTurbulence type="fractalNoise" baseFrequency="0.04" numOctaves="2"/><feDisplacementMap in="SourceGraphic" scale="4"/></filter>
</defs>
<rect width="1000" height="600" fill="url(#skyGrad)"/>
<circle cx="500" cy="175" r="70" fill="rgba(255,252,242,0.5)"/><circle cx="500" cy="175" r="45" fill="rgba(255,254,248,0.85)"/>
<path d="M-50,320 Q150,220 350,280 Q550,180 750,250 Q900,180 1050,260 L1050,380 L-50,380 Z" fill="rgba(180,170,160,0.5)" filter="url(#wc)"/>
<path d="M-50,380 Q150,300 350,350 Q550,280 750,340 Q900,280 1050,350 L1050,450 L-50,450 Z" fill="rgba(140,160,140,0.6)" filter="url(#wc)"/>
<path d="M-50,440 Q200,380 450,420 Q700,370 1050,430 L1050,500 L-50,500 Z" fill="url(#mountNear)" filter="url(#wc)"/>
<g fill="#2a4535"><path d="M0,490 L30,380 L60,490 Z"/><path d="M50,490 L75,390 L100,490 Z"/><path d="M90,490 L120,370 L150,490 Z"/><path d="M140,490 L165,385 L190,490 Z"/><path d="M780,490 L810,375 L840,490 Z"/><path d="M830,490 L855,390 L880,490 Z"/><path d="M870,490 L900,370 L930,490 Z"/><path d="M920,490 L950,385 L980,490 Z"/></g>
<path d="M180,490 Q400,475 600,485 Q800,475 820,490 L820,600 L180,600 Z" fill="url(#lakeGrad)" filter="url(#wc)"/>
<ellipse cx="500" cy="520" rx="50" ry="18" fill="rgba(255,252,240,0.2)"/>
<g fill="none" stroke="rgba(70,65,55,0.4)" stroke-width="1.5"><path d="M420,130 Q432,118 444,130"/><path d="M470,120 Q485,105 500,120"/><path d="M530,135 Q542,123 554,135"/></g>
</svg>''',
  'ocean': r'''<svg viewBox="0 0 1000 600" preserveAspectRatio="xMidYMid slice">
<defs>
<linearGradient id="oceanSky" x1="0%" y1="0%" x2="0%" y2="100%">
<stop offset="0%" style="stop-color:#fdf8f0"/><stop offset="40%" style="stop-color:#f5ddd0"/>
<stop offset="80%" style="stop-color:#d0dce5"/><stop offset="100%" style="stop-color:#b5ccd8"/>
</linearGradient>
<linearGradient id="oceanWater" x1="0%" y1="0%" x2="0%" y2="100%">
<stop offset="0%" style="stop-color:#8ec5d8"/><stop offset="50%" style="stop-color:#55a5b8"/><stop offset="100%" style="stop-color:#358598"/>
</linearGradient>
<filter id="wco" x="-20%" y="-20%" width="140%" height="140%"><feTurbulence type="fractalNoise" baseFrequency="0.03" numOctaves="2"/><feDisplacementMap in="SourceGraphic" scale="5"/></filter>
</defs>
<rect width="1000" height="600" fill="url(#oceanSky)"/>
<circle cx="500" cy="200" r="55" fill="rgba(255,252,240,0.6)"/><circle cx="500" cy="200" r="35" fill="rgba(255,254,248,0.9)"/>
<g fill="rgba(255,255,255,0.45)" filter="url(#wco)"><ellipse cx="150" cy="90" rx="100" ry="35"/><ellipse cx="750" cy="80" rx="110" ry="38"/></g>
<path d="M0,420 Q100,350 200,380 Q280,340 350,380 L0,450 Z" fill="rgba(130,145,155,0.3)" filter="url(#wco)"/>
<path d="M650,420 Q750,340 850,380 Q920,340 1000,390 L1000,450 L650,450 Z" fill="rgba(130,145,155,0.25)" filter="url(#wco)"/>
<path d="M0,440 Q250,420 500,430 Q750,420 1000,440 L1000,600 L0,600 Z" fill="url(#oceanWater)" filter="url(#wco)"/>
<g fill="rgba(255,255,255,0.1)"><path d="M0,460 Q250,450 500,460 Q750,450 1000,460 L1000,475 L0,475 Z"/><path d="M0,490 Q250,480 500,490 Q750,480 1000,490 L1000,505 L0,505 Z"/></g>
<ellipse cx="500" cy="480" rx="60" ry="20" fill="rgba(255,250,230,0.25)"/>
<g fill="none" stroke="rgba(60,70,80,0.45)" stroke-width="1.8"><path d="M340,170 Q355,155 370,170"/><path d="M620,180 Q638,162 656,180"/></g>
</svg>''',
  'night': r'''<svg viewBox="0 0 1000 600" preserveAspectRatio="xMidYMid slice">
<defs>
<linearGradient id="nightSky" x1="0%" y1="0%" x2="0%" y2="100%">
<stop offset="0%" style="stop-color:#050510"/><stop offset="40%" style="stop-color:#151535"/>
<stop offset="80%" style="stop-color:#2a2a60"/><stop offset="100%" style="stop-color:#354075"/>
</linearGradient>
<linearGradient id="nightLake" x1="0%" y1="0%" x2="0%" y2="100%">
<stop offset="0%" style="stop-color:#202045"/><stop offset="100%" style="stop-color:#101028"/>
</linearGradient>
<filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="3"/></filter>
</defs>
<rect width="1000" height="600" fill="url(#nightSky)"/>
<g fill="white"><circle cx="100" cy="60" r="1.5" opacity="0.8"/><circle cx="250" cy="90" r="1.2" opacity="0.7"/><circle cx="380" cy="50" r="1.8" opacity="0.85"/><circle cx="520" cy="80" r="1" opacity="0.6"/><circle cx="650" cy="45" r="1.5" opacity="0.8"/><circle cx="780" cy="100" r="1.3" opacity="0.7"/><circle cx="900" cy="60" r="1.6" opacity="0.8"/><circle cx="150" cy="130" r="1" opacity="0.5"/><circle cx="450" cy="120" r="1.2" opacity="0.6"/><circle cx="700" cy="140" r="1" opacity="0.5"/></g>
<circle cx="750" cy="120" r="50" fill="rgba(200,210,235,0.15)" filter="url(#glow)"/>
<circle cx="750" cy="120" r="28" fill="rgba(235,240,250,0.92)"/>
<g fill="rgba(180,190,210,0.2)"><circle cx="742" cy="112" r="5"/><circle cx="758" cy="125" r="4"/></g>
<path d="M0,400 Q200,300 400,350 Q600,270 800,330 Q900,280 1000,340 L1000,450 L0,450 Z" fill="#0a0a18"/>
<g fill="#050510"><path d="M0,450 L35,350 L70,450 Z"/><path d="M60,450 L90,360 L120,450 Z"/><path d="M850,450 L885,350 L920,450 Z"/><path d="M910,450 L940,365 L970,450 Z"/></g>
<path d="M150,450 Q400,440 650,445 Q850,440 850,450 L850,600 L150,600 Z" fill="url(#nightLake)"/>
<ellipse cx="750" cy="500" rx="35" ry="12" fill="rgba(200,210,235,0.15)"/>
<g fill="rgba(255,255,180,0.8)" filter="url(#glow)"><circle cx="250" cy="400" r="2.5"/><circle cx="700" cy="410" r="2.5"/></g>
</svg>''',
  'forest':
      r'''<svg viewBox="0 0 1000 600" preserveAspectRatio="xMidYMid slice">
<defs>
<linearGradient id="forestBg" x1="0%" y1="0%" x2="0%" y2="100%">
<stop offset="0%" style="stop-color:#1a2a20"/><stop offset="50%" style="stop-color:#304540"/><stop offset="100%" style="stop-color:#3a5548"/>
</linearGradient>
<linearGradient id="stream" x1="0%" y1="0%" x2="0%" y2="100%">
<stop offset="0%" style="stop-color:#5a9a88"/><stop offset="100%" style="stop-color:#3a7a68"/>
</linearGradient>
<filter id="ray" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="8"/></filter>
</defs>
<rect width="1000" height="600" fill="url(#forestBg)"/>
<g filter="url(#ray)" opacity="0.2"><polygon points="300,0 370,350 250,350" fill="rgba(200,220,180,0.5)"/><polygon points="500,0 560,320 440,320" fill="rgba(195,215,175,0.45)"/><polygon points="700,0 760,340 640,340" fill="rgba(190,210,170,0.4)"/></g>
<g fill="rgba(255,255,220,0.35)"><circle cx="320" cy="150" r="2"/><circle cx="520" cy="180" r="1.5"/><circle cx="720" cy="160" r="2"/></g>
<g fill="#152520"><path d="M-20,520 L60,150 L140,520 Z"/><path d="M100,520 L170,180 L240,520 Z"/><path d="M760,520 L830,150 L900,520 Z"/><path d="M860,520 L930,180 L1000,520 Z"/></g>
<path d="M0,460 Q200,430 350,470 L0,600 Z" fill="#3a5545"/>
<path d="M1000,460 Q800,430 650,470 L1000,600 Z" fill="#3a5545"/>
<path d="M350,470 Q500,440 650,470 Q580,510 500,520 Q420,510 350,470" fill="url(#stream)"/>
<g fill="rgba(255,255,255,0.4)"><circle cx="480" cy="490" r="2"/><circle cx="520" cy="495" r="1.5"/></g>
</svg>''',
  'meadow':
      r'''<svg viewBox="0 0 1000 600" preserveAspectRatio="xMidYMid slice">
<defs>
<linearGradient id="meadowSky" x1="0%" y1="0%" x2="0%" y2="100%">
<stop offset="0%" style="stop-color:#b8d9f0"/><stop offset="15%" style="stop-color:#90c4e8"/>
<stop offset="55%" style="stop-color:#c8e8c8"/><stop offset="78%" style="stop-color:#9dc87a"/><stop offset="100%" style="stop-color:#72a850"/>
</linearGradient>
<linearGradient id="meadowGrass" x1="0%" y1="0%" x2="0%" y2="100%">
<stop offset="0%" style="stop-color:#88c050"/><stop offset="100%" style="stop-color:#5a9030"/>
</linearGradient>
<radialGradient id="meadowSun" cx="50%" cy="50%" r="50%">
<stop offset="30%" style="stop-color:#fffde0"/><stop offset="65%" style="stop-color:#ffd740"/><stop offset="72%" style="stop-color:transparent"/>
</radialGradient>
</defs>
<rect width="1000" height="600" fill="url(#meadowSky)"/>
<circle cx="870" cy="90" r="55" fill="url(#meadowSun)" opacity="0.95"/>
<g fill="rgba(255,255,255,0.82)"><ellipse cx="150" cy="80" rx="90" ry="32"/><ellipse cx="800" cy="140" rx="100" ry="35"/></g>
<path d="M-50,360 Q200,280 450,330 Q700,260 1050,320 L1050,420 L-50,420 Z" fill="rgba(125,184,90,0.55)"/>
<path d="M-50,400 Q250,360 500,385 Q750,360 1050,400 L1050,600 L-50,600 Z" fill="url(#meadowGrass)"/>
<g><circle cx="80" cy="420" r="6" fill="rgba(247,201,72,0.9)"/><circle cx="200" cy="440" r="5" fill="rgba(247,108,108,0.9)"/><circle cx="320" cy="425" r="6" fill="rgba(192,106,200,0.9)"/><circle cx="720" cy="425" r="6" fill="rgba(247,156,72,0.9)"/><circle cx="820" cy="440" r="5" fill="rgba(96,200,240,0.9)"/><circle cx="900" cy="430" r="6" fill="rgba(247,108,168,0.9)"/></g>
</svg>''',
  'autumn':
      r'''<svg viewBox="0 0 1000 600" preserveAspectRatio="xMidYMid slice">
<defs>
<linearGradient id="autumnSky" x1="0%" y1="0%" x2="0%" y2="100%">
<stop offset="0%" style="stop-color:#faf0e0"/><stop offset="50%" style="stop-color:#f5e0c8"/><stop offset="100%" style="stop-color:#e8d0b0"/>
</linearGradient>
<linearGradient id="autumnHill" x1="0%" y1="0%" x2="0%" y2="100%">
<stop offset="0%" style="stop-color:#b07848"/><stop offset="100%" style="stop-color:#906038"/>
</linearGradient>
<filter id="wcA" x="-20%" y="-20%" width="140%" height="140%"><feTurbulence type="fractalNoise" baseFrequency="0.05" numOctaves="2"/><feDisplacementMap in="SourceGraphic" scale="3"/></filter>
</defs>
<rect width="1000" height="600" fill="url(#autumnSky)"/>
<circle cx="600" cy="120" r="45" fill="rgba(255,250,235,0.6)"/><circle cx="600" cy="120" r="28" fill="rgba(255,254,248,0.9)"/>
<path d="M0,320 Q200,260 400,300 Q600,240 800,290 Q1000,250 1000,300 L1000,380 L0,380 Z" fill="rgba(200,150,100,0.5)" filter="url(#wcA)"/>
<path d="M0,370 Q250,310 500,360 Q750,300 1000,360 L1000,420 L0,420 Z" fill="url(#autumnHill)" filter="url(#wcA)"/>
<g><circle cx="120" cy="340" r="28" fill="rgba(220,130,60,0.8)"/><circle cx="300" cy="325" r="32" fill="rgba(200,80,60,0.8)"/><circle cx="500" cy="335" r="30" fill="rgba(240,200,80,0.8)"/><circle cx="700" cy="320" r="34" fill="rgba(190,70,50,0.8)"/><circle cx="880" cy="330" r="28" fill="rgba(230,140,50,0.8)"/></g>
<g fill="#5a4535"><rect x="117" y="360" width="6" height="28"/><rect x="297" y="350" width="7" height="35"/><rect x="497" y="358" width="6" height="30"/><rect x="697" y="348" width="7" height="38"/><rect x="877" y="352" width="6" height="32"/></g>
<path d="M0,410 Q250,390 500,405 Q750,385 1000,410 L1000,600 L0,600 Z" fill="#8a6848" filter="url(#wcA)"/>
<g fill="none" stroke="rgba(80,60,40,0.45)" stroke-width="1.5"><path d="M500,100 Q512,88 524,100"/><path d="M540,110 Q550,100 560,110"/></g>
</svg>''',
};

const Map<String, String> _objectSvgs = {
  'sun':
      r'''<svg viewBox="0 0 140 140"><defs><radialGradient id="sunC" cx="50%" cy="50%" r="50%"><stop offset="0%" style="stop-color:#fffef8"/><stop offset="70%" style="stop-color:#fff8e5"/><stop offset="100%" style="stop-color:#f5e8d0"/></radialGradient></defs><circle cx="70" cy="70" r="60" fill="rgba(255,240,200,0.12)"/><circle cx="70" cy="70" r="45" fill="rgba(255,245,215,0.25)"/><circle cx="70" cy="70" r="32" fill="rgba(255,250,230,0.5)"/><circle cx="70" cy="70" r="22" fill="url(#sunC)"/></svg>''',
  'moon':
      r'''<svg viewBox="0 0 120 120"><circle cx="60" cy="60" r="50" fill="rgba(200,215,240,0.1)"/><circle cx="60" cy="60" r="38" fill="rgba(210,220,242,0.2)"/><circle cx="60" cy="60" r="28" fill="rgba(235,240,250,0.92)"/><circle cx="50" cy="50" r="6" fill="rgba(180,190,210,0.22)"/><circle cx="68" cy="58" r="4" fill="rgba(180,190,210,0.18)"/><circle cx="55" cy="68" r="3" fill="rgba(180,190,210,0.15)"/></svg>''',
  'butterfly':
      r'''<svg viewBox="0 0 120 100"><g><ellipse cx="35" cy="35" rx="28" ry="30" fill="rgba(225,165,145,0.78)" stroke="rgba(180,120,100,0.35)" stroke-width="1"/><ellipse cx="32" cy="30" rx="12" ry="14" fill="rgba(245,190,170,0.4)"/><circle cx="26" cy="24" r="5" fill="rgba(190,90,70,0.3)"/><ellipse cx="30" cy="68" rx="18" ry="20" fill="rgba(215,155,135,0.7)"/></g><g><ellipse cx="85" cy="35" rx="28" ry="30" fill="rgba(225,165,145,0.78)" stroke="rgba(180,120,100,0.35)" stroke-width="1"/><ellipse cx="88" cy="30" rx="12" ry="14" fill="rgba(245,190,170,0.4)"/><circle cx="94" cy="24" r="5" fill="rgba(190,90,70,0.3)"/><ellipse cx="90" cy="68" rx="18" ry="20" fill="rgba(215,155,135,0.7)"/></g><ellipse cx="60" cy="50" rx="5" ry="24" fill="rgba(65,50,40,0.88)"/><circle cx="60" cy="22" r="6" fill="rgba(60,45,38,0.9)"/><path d="M56,18 Q48,6 44,0" stroke="rgba(55,42,35,0.7)" stroke-width="1.5" fill="none"/><path d="M64,18 Q72,6 76,0" stroke="rgba(55,42,35,0.7)" stroke-width="1.5" fill="none"/><circle cx="44" cy="0" r="2.5" fill="rgba(55,42,35,0.7)"/><circle cx="76" cy="0" r="2.5" fill="rgba(55,42,35,0.7)"/></svg>''',
  'bird':
      r'''<svg viewBox="0 0 100 65"><ellipse cx="50" cy="35" rx="26" ry="12" fill="rgba(80,80,88,0.88)"/><path d="M22,35 L5,25 Q12,33 16,35 Q12,37 5,45 L22,35" fill="rgba(70,70,78,0.8)"/><circle cx="70" cy="28" r="11" fill="rgba(75,75,82,0.92)"/><circle cx="74" cy="25" r="3.5" fill="rgba(20,20,25,0.95)"/><circle cx="75" cy="24" r="1.2" fill="rgba(255,255,255,0.6)"/><path d="M80,28 L92,26 L80,30 Z" fill="rgba(185,145,85,0.92)"/><g><path d="M38,30 Q22,15 52,24 Q44,28 38,30" fill="rgba(95,95,102,0.85)"/></g></svg>''',
  'leaf':
      r'''<svg viewBox="0 0 90 75"><path d="M45,5 Q70,14 78,38 Q72,58 58,66 Q45,70 32,66 Q18,58 12,38 Q20,14 45,5" fill="rgba(185,125,75,0.88)" stroke="rgba(145,95,58,0.5)" stroke-width="1"/><ellipse cx="32" cy="30" rx="10" ry="14" fill="rgba(210,145,90,0.25)"/><ellipse cx="58" cy="45" rx="8" ry="12" fill="rgba(155,95,55,0.2)"/><path d="M45,10 L45,62" stroke="rgba(130,85,50,0.5)" stroke-width="2" fill="none"/><g stroke="rgba(130,85,50,0.3)" stroke-width="1" fill="none"><path d="M45,22 Q32,30 22,34"/><path d="M45,22 Q58,30 68,34"/><path d="M45,38 Q28,48 18,54"/><path d="M45,38 Q62,48 72,54"/></g></svg>''',
  'feather':
      r'''<svg viewBox="0 0 70 105"><path d="M35,5 Q56,22 50,58 Q44,85 35,92 Q26,85 20,58 Q14,22 35,5" fill="rgba(248,244,240,0.92)" stroke="rgba(185,180,172,0.4)" stroke-width="1"/><path d="M35,10 L35,88" stroke="rgba(170,165,158,0.5)" stroke-width="1.8" fill="none"/><g stroke="rgba(175,170,162,0.28)" stroke-width="0.8" fill="none"><path d="M35,20 L22,30"/><path d="M35,32 L18,45"/><path d="M35,46 L16,62"/><path d="M35,20 L48,30"/><path d="M35,32 L52,45"/><path d="M35,46 L54,62"/></g></svg>''',
  'star':
      r'''<svg viewBox="0 0 110 110"><circle cx="55" cy="55" r="48" fill="rgba(255,250,220,0.1)"/><circle cx="55" cy="55" r="36" fill="rgba(255,252,230,0.18)"/><polygon points="55,12 62,40 92,40 68,58 76,86 55,68 34,86 42,58 18,40 48,40" fill="rgba(255,252,240,0.94)" stroke="rgba(255,240,180,0.4)" stroke-width="1"/><polygon points="55,22 60,42 78,42 64,54 70,72 55,62 40,72 46,54 32,42 50,42" fill="rgba(255,255,250,0.35)"/></svg>''',
  'dragonfly':
      r'''<svg viewBox="0 0 130 80"><g><ellipse cx="65" cy="32" rx="42" ry="10" fill="rgba(190,210,230,0.35)" stroke="rgba(150,170,190,0.3)" stroke-width="0.8"/><ellipse cx="65" cy="48" rx="35" ry="8" fill="rgba(180,200,220,0.28)"/></g><ellipse cx="65" cy="40" rx="48" ry="5" fill="rgba(90,130,150,0.82)"/><ellipse cx="65" cy="40" rx="38" ry="3.5" fill="rgba(100,140,160,0.5)"/><g stroke="rgba(50,80,100,0.25)" stroke-width="1" fill="none"><line x1="45" y1="36" x2="45" y2="44"/><line x1="55" y1="35" x2="55" y2="45"/><line x1="75" y1="35" x2="75" y2="45"/><line x1="85" y1="36" x2="85" y2="44"/><line x1="95" y1="37" x2="95" y2="43"/><line x1="105" y1="38" x2="105" y2="42"/></g><circle cx="18" cy="40" r="9" fill="rgba(70,100,120,0.88)"/><ellipse cx="14" cy="37" rx="4.5" ry="4" fill="rgba(40,65,85,0.95)"/><ellipse cx="22" cy="37" rx="4.5" ry="4" fill="rgba(40,65,85,0.95)"/><circle cx="12" cy="35" r="1.5" fill="rgba(130,160,190,0.45)"/><circle cx="20" cy="35" r="1.5" fill="rgba(130,160,190,0.45)"/></svg>''',
  'orb':
      r'''<svg viewBox="0 0 120 120"><defs><radialGradient id="orbG" cx="38%" cy="32%" r="58%"><stop offset="0%" style="stop-color:#ffffff"/><stop offset="38%" style="stop-color:#dff2f0"/><stop offset="75%" style="stop-color:#8fbfb5"/><stop offset="100%" style="stop-color:#5f938a"/></radialGradient><filter id="orbBlur"><feGaussianBlur stdDeviation="5"/></filter></defs><circle cx="60" cy="60" r="50" fill="rgba(190,230,220,0.22)" filter="url(#orbBlur)"/><circle cx="60" cy="60" r="34" fill="url(#orbG)" stroke="rgba(255,255,255,0.55)" stroke-width="1.2"/><ellipse cx="48" cy="42" rx="11" ry="7" fill="rgba(255,255,255,0.55)"/></svg>''',
  'crystal':
      r'''<svg viewBox="0 0 110 120"><defs><linearGradient id="crystalG" x1="20%" y1="0%" x2="80%" y2="100%"><stop offset="0%" style="stop-color:#ffffff"/><stop offset="42%" style="stop-color:#d8eef2"/><stop offset="100%" style="stop-color:#87b7c2"/></linearGradient></defs><path d="M55 8 L88 38 L74 102 L55 114 L36 102 L22 38 Z" fill="url(#crystalG)" stroke="rgba(80,120,130,0.3)" stroke-width="1.5"/><path d="M55 8 L55 114 M22 38 L55 48 L88 38 M36 102 L55 48 L74 102" stroke="rgba(255,255,255,0.45)" stroke-width="1.2" fill="none"/><path d="M34 35 L47 20 L42 47 Z" fill="rgba(255,255,255,0.35)"/></svg>''',
  'lotus':
      r'''<svg viewBox="0 0 130 95"><g><ellipse cx="65" cy="55" rx="18" ry="36" fill="rgba(235,185,195,0.88)" transform="rotate(0 65 55)"/><ellipse cx="42" cy="60" rx="17" ry="32" fill="rgba(220,165,180,0.82)" transform="rotate(-34 42 60)"/><ellipse cx="88" cy="60" rx="17" ry="32" fill="rgba(220,165,180,0.82)" transform="rotate(34 88 60)"/><ellipse cx="28" cy="70" rx="14" ry="28" fill="rgba(196,145,165,0.75)" transform="rotate(-58 28 70)"/><ellipse cx="102" cy="70" rx="14" ry="28" fill="rgba(196,145,165,0.75)" transform="rotate(58 102 70)"/></g><path d="M20 78 Q65 92 110 78" stroke="rgba(110,145,110,0.55)" stroke-width="5" stroke-linecap="round" fill="none"/><ellipse cx="65" cy="67" rx="12" ry="18" fill="rgba(255,225,210,0.5)"/></svg>''',
  'pearl':
      r'''<svg viewBox="0 0 120 120"><defs><radialGradient id="pearlG" cx="35%" cy="28%" r="60%"><stop offset="0%" style="stop-color:#ffffff"/><stop offset="38%" style="stop-color:#f7f4ef"/><stop offset="72%" style="stop-color:#ded8cf"/><stop offset="100%" style="stop-color:#b8b0a8"/></radialGradient></defs><circle cx="60" cy="60" r="42" fill="rgba(255,255,255,0.12)"/><circle cx="60" cy="60" r="30" fill="url(#pearlG)" stroke="rgba(255,255,255,0.65)" stroke-width="1.4"/><ellipse cx="49" cy="44" rx="9" ry="6" fill="rgba(255,255,255,0.62)"/></svg>''',
};
