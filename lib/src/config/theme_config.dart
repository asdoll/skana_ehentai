import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_design/moon_design.dart';

class ThemeConfig {
  static ThemeData theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return (isDark
          ? ThemeData.dark().copyWith(
            primaryColor: MoonTheme(tokens: MoonTokens.dark).tokens.colors.piccolo,
              textTheme: GoogleFonts.notoSansTextTheme(
              ),
              appBarTheme: AppBarTheme(
                titleSpacing: 0,
                backgroundColor:
                    MoonTheme(tokens: MoonTokens.dark).tokens.colors.popo,
                surfaceTintColor: Colors.transparent,
              ),
              scaffoldBackgroundColor:
                  MoonTheme(tokens: MoonTokens.light).tokens.colors.bulma)
              
          : ThemeData.light().copyWith(
            primaryColor: MoonTheme(tokens: MoonTokens.light).tokens.colors.piccolo,
              textTheme: GoogleFonts.notoSansTextTheme(
              ),
              appBarTheme: AppBarTheme(
                titleSpacing: 0,
                backgroundColor:
                    MoonTheme(tokens: MoonTokens.dark).tokens.colors.goten,
                surfaceTintColor: Colors.transparent,
              ),
              scaffoldBackgroundColor:
                  MoonTheme(tokens: MoonTokens.light).tokens.colors.goten))
      .copyWith(extensions: <ThemeExtension<dynamic>>[
    MoonTheme(tokens: isDark ? MoonTokens.dark.copyWith(
      typography: MoonTypography.typography.copyWith(
        heading: MoonTypography.typography.heading.apply(
          fontFamily: GoogleFonts.notoSans().fontFamily,
        ),
        body: MoonTypography.typography.body.apply(
          fontFamily: GoogleFonts.notoSans().fontFamily,
        )
      )
    ) : MoonTokens.light.copyWith(
      typography: MoonTypography.typography.copyWith(
        heading: MoonTypography.typography.heading.apply(
          fontFamily: GoogleFonts.notoSans().fontFamily,
        ),
        body: MoonTypography.typography.body.apply(
          fontFamily: GoogleFonts.notoSans().fontFamily,
        )
      )
    ))
  ]);
  }
}
