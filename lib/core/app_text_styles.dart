import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heading1 => GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.white, letterSpacing: -0.5, height: 1.2);
  static TextStyle get heading2 => GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.white, letterSpacing: -0.3, height: 1.3);
  static TextStyle get heading3 => GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.white, height: 1.4);
  static TextStyle get body1    => GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.7);
  static TextStyle get body2    => GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.6);
  static TextStyle get bodyBold => GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white, height: 1.5);
  static TextStyle get sectionTitle => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white);
  static TextStyle get caption  => GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.muted, letterSpacing: 0.3);
  static TextStyle get overline => GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 1.0);
  static TextStyle get badge    => GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.4);
  static TextStyle get goldLabel => GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold);
  static TextStyle get goldHeading => GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.gold);
  static TextStyle get cardTitle => GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white, height: 1.3);
  static TextStyle get cardSubtitle => GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.muted, height: 1.4);
  static TextStyle get verseText => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white, height: 1.7, fontStyle: FontStyle.italic);
  static TextStyle get verseRef  => GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 0.3);
  static TextStyle get navLabel  => GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700);
  static TextStyle get buttonPrimary   => GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black);
  static TextStyle get buttonSecondary => GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white);

  // Auth specific
  static TextStyle get authTitle   => GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.white, letterSpacing: -0.5);
  static TextStyle get authSubtitle => GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.muted, height: 1.5);
  static TextStyle get inputLabel  => GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.3);
  static TextStyle get linkText    => GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold);
}
