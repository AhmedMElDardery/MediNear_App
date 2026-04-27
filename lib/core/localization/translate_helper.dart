import 'package:flutter/material.dart';
import 'package:medinear_app/core/localization/app_localizations.dart';

extension LocalizationExt on BuildContext {
  String tr(String key, {Map<String, String>? params}) {
    return AppLocalizations.of(this)!.translate(key, params: params);
  }
}