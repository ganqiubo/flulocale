import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'FluLocalizationsDelegate.dart';

class FluLocalizations{
  static final String TAG = "FluLocalizations";

  Locale locale;
  FluLocalizations(this.locale);


  static Map<String, Map<String, String>> localizedValues = {};
  static List<Locale> getListKeys() {
    print(TAG + ", getListKeys: " + localizedValues.toString());
    if(localizedValues==null || localizedValues.length<=0){
      return [];
    }
    List<Locale> keys = [];
    for(int i=0; i<localizedValues.keys.length;i++){
      if(localizedValues.keys.elementAt(i)==null)continue;
      List<String> localStrs = localizedValues.keys.elementAt(i).split("_");
      if(localStrs.length==1 && localStrs.elementAt(0)!=null){
        keys.add(Locale(localStrs.elementAt(0).toLowerCase()));
      }else if(localStrs.length==2&&localStrs.elementAt(0)!=null&&localStrs.elementAt(1)!=null){
        keys.add(Locale(localStrs.elementAt(0).toLowerCase(),
            localStrs.elementAt(1).toUpperCase()));
      }
    }
    return keys;
  }

  String value(String key){
    if(key==null || localizedValues==null || localizedValues.length<=0){
      return "";
    }
    if(!localizedValues.containsKey(locale.toString().toLowerCase()) || localizedValues[locale.toString().toLowerCase()]==null
        || localizedValues[locale.toString().toLowerCase()][key]==null){
      String baseLanguage = locale.toString().split("_")[0].toLowerCase();
      if(localizedValues.containsKey(baseLanguage) && localizedValues[baseLanguage]!=null
            &&localizedValues[baseLanguage][key]!=null){
        return localizedValues[baseLanguage][key];
      }
      if(localizedValues.values.elementAt(0)!=null && localizedValues.values.elementAt(0)[key]!=null){
        return localizedValues.values.elementAt(0)[key];
      }
      return "";
    }
    if(localizedValues[locale.toString().toLowerCase()]==null)return "";
    String value =  localizedValues[locale.toString().toLowerCase()][key];
    return value??"";
  }


  static LocaleResolutionCallback localeResolutionCallback = (local, supportLocals){
    bool isSupports = supportLocals.contains(local);
    if(isSupports){
      return local;
    }
    if(supportLocals==null || supportLocals.length<=0){
      return Locale('en', 'us');
    }
    for(int i=0; i<supportLocals.length;i++){
      if(supportLocals.elementAt(i).languageCode==local.languageCode){
        return supportLocals.elementAt(i);
      }
    }
    return Locale('en', 'US');
  };

  static List<Locale> supportLanguages = getListKeys();
  static const Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    // ... app-specific localization delegate[s] here
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    FluLocalizationsDelegate.delegate
  ];
  //此处
  static FluLocalizations of(BuildContext context){
    return Localizations.of(context, FluLocalizations);
  }
}