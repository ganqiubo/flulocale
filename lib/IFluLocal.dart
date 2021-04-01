import 'package:flulocale/flulocale.dart';
import 'package:flutter/cupertino.dart';

abstract class IFluLocal{
  static const String TAG = "Ilocale";

  String localeLan(BuildContext context, String key){
    if(context==null){
      print(TAG + ", " + "context is null");
      return "";
    }
    if(key==null){
      print(TAG + ", " + "key is null");
      return "";
    }
    return FluLocalizations.of(context).value(key);
  }

  String locale(String key){}
}