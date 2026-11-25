import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class EZColors {
  EZColors._();

  static const bg = Color(0xFF1F1F1F);
  static const page = Color(0xFF1F1F1F);
  static const container = Color(0x992E2E2E);
  static const panel = Color(0xFF232323);
  static const card = Color(0xFF242424);
  static const cardBorder = Color(0xFF2E2E2E);
  static const button = Color(0xFF383838);
  static const buttonHover = Color(0xFF404040);
  static const buttonPressed = Color(0xFF363636);
  static const separator = Color(0xFF3D3D3D);
  static const text = Color(0xFFA8A8A8);
  static const textDim = Color(0xFF7E7E7E);
  static const textBright = Color(0xFFECECEC);
  static Color accent = const Color(0xFF7FBB06);
  static Color accentHover = const Color(0xFF92D40A);
  static const warn = Color(0xFFF59E0B);
  static const bad = Color(0xFFEF4444);
  static const ok = Color(0xFF22C55E);
  static const consoleBg = Color(0xFF161616);
  static const checkbox = Color(0xFF677EA1);
  static const banner = Color(0xFF2A2418);
  static const bannerBorder = Color(0xFF3D3220);
  static const exitHover = Color(0xFFE81123);
  static const exitPressed = Color(0xFFF1707A);

  static const accentChoices = <String, Color>{
    'Green': Color(0xFF7FBB06),
    'Blue': Color(0xFF3B82F6),
    'Purple': Color(0xFF8B5CF6),
    'Pink': Color(0xFFEC4899),
    'Orange': Color(0xFFF97316),
    'Teal': Color(0xFF14B8A6),
    'Yellow': Color(0xFFEAB308),
    'Red': Color(0xFFEF4444),
  };

  static void applyAccent(String name) {
    accent = accentChoices[name] ?? accentChoices['Green']!;
    accentHover = Color.lerp(accent, Colors.white, .15)!;
  }
}

class EZText {
  EZText._();

  static const family = 'Segoe UI';

  static const label = TextStyle(
    color: EZColors.text,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: family,
  );

  static const containerLabel = TextStyle(
    color: EZColors.textDim,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    fontFamily: family,
  );

  static const section = TextStyle(
    color: Color(0xFFD8D8D8),
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const hint = TextStyle(
    color: EZColors.textDim,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static const title = TextStyle(
    color: EZColors.textBright,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const group = TextStyle(
    color: Color(0xFF6A6A6A),
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.0,
  );

  static const console = TextStyle(
    color: Color(0xFFD0D0D0),
    fontSize: 12,
    fontFamily: 'Consolas',
    fontFamilyFallback: ['Courier New', 'monospace'],
  );
}

BoxDecoration cardDecoration({double radius = 12}) => BoxDecoration(
  color: EZColors.card,
  border: Border.all(color: EZColors.cardBorder),
  borderRadius: BorderRadius.circular(radius),
);

MarkdownStyleSheet get mdStyle => MarkdownStyleSheet(
  p: const TextStyle(color: EZColors.text, fontSize: 13, height: 1.45),
  h1: const TextStyle(
    color: EZColors.textBright,
    fontSize: 19,
    fontWeight: FontWeight.w700,
  ),
  h2: const TextStyle(
    color: EZColors.textBright,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  ),
  h3: const TextStyle(
    color: EZColors.textBright,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  ),
  h4: const TextStyle(
    color: Color(0xFFD8D8D8),
    fontSize: 13,
    fontWeight: FontWeight.w700,
  ),
  strong: const TextStyle(
    color: EZColors.textBright,
    fontWeight: FontWeight.w700,
  ),
  em: const TextStyle(color: EZColors.text, fontStyle: FontStyle.italic),
  code: const TextStyle(
    color: Color(0xFFD8D8D8),
    backgroundColor: EZColors.consoleBg,
    fontFamily: 'Consolas',
    fontSize: 12,
  ),
  codeblockDecoration: BoxDecoration(
    color: EZColors.consoleBg,
    borderRadius: BorderRadius.circular(8),
  ),
  blockquote: const TextStyle(color: EZColors.textDim, fontSize: 13),
  blockquoteDecoration: BoxDecoration(
    border: Border(left: BorderSide(color: EZColors.accent, width: 3)),
  ),
  listBullet: const TextStyle(color: EZColors.textDim, fontSize: 13),
  listBulletPadding: const EdgeInsets.only(right: 6),
  a: TextStyle(color: EZColors.accent, decoration: TextDecoration.underline),
  horizontalRuleDecoration: const BoxDecoration(
    border: Border(top: BorderSide(color: EZColors.separator)),
  ),
);

ThemeData buildEZTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: EZColors.bg,
    fontFamily: EZText.family,
    colorScheme: ColorScheme.dark(
      surface: EZColors.bg,
      primary: EZColors.accent,
    ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(const Color(0xFF3D3D3D)),
      thickness: WidgetStateProperty.all(6),
      radius: const Radius.circular(3),
    ),
  );
}
