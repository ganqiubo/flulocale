import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'FluLocalizations.dart';

class FluLocalizationsDelegate extends LocalizationsDelegate<FluLocalizations> {

  static final String TAG = "FluLocalizationsDelegate";
  const FluLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return FluLocalizations.supportLanguages.contains(locale);
  }

  @override
  Future<FluLocalizations> load(Locale locale) {
    print(TAG + ", flutter load");
    return SynchronousFuture(FluLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<FluLocalizations> old) {
    print(TAG + ", flutter shouldReload");
    return false;
  }

  static const FluLocalizationsDelegate delegate = const FluLocalizationsDelegate();
}