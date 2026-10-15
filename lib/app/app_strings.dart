import 'package:flutter/widgets.dart';

class AppStrings {
  const AppStrings._();

  static bool isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  static String t(BuildContext context, String ar, String en) =>
      isArabic(context) ? ar : en;
}
