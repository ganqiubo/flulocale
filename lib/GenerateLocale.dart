import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'UpFirstStr.dart';
import 'bean/TransResult.dart';

  /*void main() {
    GenerateLocale generateLocale = GenerateLocaleBuild()
      .targetPath("E:\\flutterPro\\testflutter\\lib\\localizations\\locals")
      .baseLanData(En.values)
      .baseLanName("en")
      .transLan(["en", "zh_cn", "ar", "bg"])
      .build();
    generateLocale.translate();
  }*/

class GenerateLocaleBuild {

  GenerateLocale _generateLocale = GenerateLocale();

  GenerateLocaleBuild targetPath(String targetPath){
    _generateLocale.targetPath = targetPath;
    return this;
  }

  GenerateLocaleBuild baseLanData(Map<String, String> baseLanData){
    _generateLocale.baseLanData = baseLanData;
    return this;
  }

  GenerateLocaleBuild baseLanName(String baseLanName){
    _generateLocale.baseLanName = baseLanName;
    return this;
  }

  GenerateLocaleBuild key(String appid, String secretKey){
    _generateLocale.appid = appid;
    _generateLocale.secretKey = secretKey;
    return this;
  }

  GenerateLocaleBuild maxTransLen(int maxLen){
    _generateLocale.maxTranslateLength = maxLen;
  }

  GenerateLocaleBuild transLan(List<String> transLans){
    if(transLans==null){
      return this;
    }
    Map<String, String> tempTransLans = {};
    for(int i=0;i<transLans.length;i++){
      if(!GenerateLocale.supportTransLan.containsKey(transLans.elementAt(i))){
        print("not support translate language: "
            + transLans.elementAt(i));
        continue;
      }
      tempTransLans[transLans.elementAt(i)] = GenerateLocale.supportTransLan[transLans.elementAt(i)];
    }
    _generateLocale.transLan = tempTransLans;
    return this;
  }

  GenerateLocaleBuild removeLan(String lan){
    _generateLocale.transLan.remove(lan);
    return this;
  }

  GenerateLocale build(){
    return _generateLocale;
  }

}

class GenerateLocale {
  String TAG = "GenerateLocale: ";
  String appid = "20210323000739274";
  String secretKey = "5akxK7W6Rss298f4wIqw";
  int maxTranslateLength = 1200;
  String targetPath;
  Map<String, String> baseLanData;
  String baseLanName;

  static Map<String, String> supportTransLan = {
    "en": "en",
    "zh_cn": "zh",
    "zh_tw": "cht",
    "ja": "jp",
    "ko": "kor",
    "fr": "fra",
    "es": "spa",
    "th": "th",
    "ar": "ara",
    "ru": "ru",
    "pt": "pt",
    "de": "de",
    "it": "it",
    "el": "el",
    "nl": "nl",
    "pl": "pl",
    "bg": "bul",
    "et": "est",
    "da": "dan",
    "fi": "fin",
    "cs": "cs",
    "ro": "rom",
    "sl": "slo",
    "sv": "swe",
    "hu": "hu",
    "vi": "vie",
  };

  Map<String, String> transLan = supportTransLan;

  translate() async {
    if (targetPath == null) {
      print(TAG + "targetPath is empty");
      return;
    }
    if (baseLanName == null) {
      print(TAG + "baseLanName is empty");
      return;
    }
    if (baseLanData == null || baseLanData.length <= 0) {
      print(TAG + "no data need to translate");
      return;
    }
    File file = new File(targetPath);
    if (file.existsSync()) {
      print(TAG + "targetPath is not exit");
      return;
    }
    if (!supportTransLan.containsKey(baseLanName)) {
      print(TAG + "baseLanName is not in supportTranslateLan");
      return;
    }
    String from = supportTransLan[baseLanName];
    transLan.remove(baseLanName);
    Map<String, Map<String, String>> translateDatas = {};
    for (String key in transLan.keys) {
      String to = transLan[key];
      print(TAG + "start translate language: " + key);

      Map<String, String> lanDatas = await translateItemLan(from, to, baseLanData);

      translateDatas[key] = lanDatas;
      print(TAG + lanDatas.toString() + " ;finish translate language: " + key);
    }

    print(TAG + "finish translate all language: ");

    print(TAG + ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

    print(TAG + "data: " + translateDatas.toString());

    generateFile(targetPath, translateDatas);
  }

  Future<void> generateFile(String targetPath,
      Map<String, Map<String, String>> translateDatas) async {
    print(TAG + "start create local files");
    Map<String, String> localFileNames = {};
    for (String key in translateDatas.keys) {
      String fileName = "";
      List<String> names = key.split("_");
      if (names.length == 2) {
        fileName = UpFirstStr.convert(names.elementAt(0)) +
            UpFirstStr.convert(names.elementAt(1));
      } else {
        fileName = UpFirstStr.convert(names[0]);
      }
      localFileNames[key] = fileName;
      File file1 = new File((targetPath + "/" + fileName + ".dart"));
      bool isFileExit = await file1.exists();
      if (isFileExit) {
        await file1.delete();
      }
      await file1.create();
      Map<String, String> itemDatas = translateDatas[key];
      if (itemDatas == null) {
        print(TAG + "local " + key + " is empty, skip it");
        continue;
      }
      String content = "class " + fileName +
          "{\n  static Map<String, String> values = {\n";
      for (String keyItem in itemDatas.keys) {
        content = content + "    \"" + keyItem + "\": \"" + itemDatas[keyItem] +
            "\",\n";
      }
      content = content + "  };\n}";
      await file1.writeAsString(content);
      print(TAG + "create local file " + fileName + ".dart success");
    }
    print(TAG + "finish create local files");
    createlocalsMapFile(targetPath, localFileNames);
  }

  Future<void> createlocalsMapFile(String targetPath,
      Map<String, String> localFileNames) async {
    print(TAG + "start create locals map file");
    if (localFileNames == null || localFileNames.length <= 0) {
      print(TAG + "no locals map data");
      return;
    }
    String localMapsClassContent = "class Locals{\n  static Map<String, Map<String, String>> localizedValues = {\n";
    String localMapsImportContent = "";
    File localMapsFile = new File((targetPath + "/" + "Locals" + ".dart"));
    bool islocalMapsExit = await localMapsFile.exists();
    if (islocalMapsExit) {
      await localMapsFile.delete();
    }
    for (String key in localFileNames.keys) {
      File localItemFile = new File(
          (targetPath + "/" + localFileNames[key] + ".dart"));
      bool islocalItemFileExit = await localItemFile.exists();
      if (!islocalItemFileExit) {
        continue;
      }
      localMapsImportContent =
          localMapsImportContent + "import '" + localFileNames[key] +
              ".dart';\n";
      localMapsClassContent =
          localMapsClassContent + "    \"" + key.toLowerCase()
              + "\": " + localFileNames[key] + ".values,\n";
      ;
    }
    localMapsClassContent = localMapsClassContent + "  };\n}";
    localMapsImportContent = localMapsImportContent + "\n";
    await localMapsFile.writeAsString(
        (localMapsImportContent + localMapsClassContent));
    print(TAG + "finish create locals map file");
  }

  Future<Map<String, String>> translateItemLan(String from, String to,
      Map<String, String> baseLan) async {
    int mapIndex = 0;
    List<String> translateKeys = [];
    List<String> translateValues = [];
    String q = "";
    for (String key in baseLan.keys) {
      mapIndex ++;
      translateKeys.add(key);
      if (baseLan[key].indexOf("\n") >= 0) {
        List<String> translateItemValues = await translateNormalItems(
            from, to, q);
        if (translateItemValues == null || translateItemValues.length <= 0) {
          print(TAG + "translate has troubles");
          return null;
        }
        translateValues.addAll(translateItemValues);
        q = "";
        String translateValue = await translateEnterItem(
            from, to, baseLan[key]);
        if (translateValue == null || translateValue.isEmpty) {
          print(TAG + "translate has troubles");
          return null;
        }
        translateValues.add(translateValue);
      } else {
        q = q + baseLan[key] + "\n";
        if (q.length >= maxTranslateLength || mapIndex >= baseLan.length) {
          List<String> translateItemValues = await translateNormalItems(
              from, to, q);
          if (translateItemValues == null || translateItemValues.length <= 0) {
            print(TAG + "translate has troubles");
            return null;
          }
          translateValues.addAll(translateItemValues);
          q = "";
        }
      }
    }

    if (translateKeys.length != translateValues.length) {
      print(TAG + translateValues.toString() +
          " :translate occurred error, translate key's length is not equal value's length: " +
          translateKeys.toString());
      return null;
    }
    Map<String, String> lanDatas = {};
    for (int i = 0; i < translateKeys.length; i++) {
      lanDatas[translateKeys[i]] = translateValues[i];
    }
    return lanDatas;
  }

  Future<List<String>> translateNormalItems(String from, String to,
      String q) async {
    await new Future.delayed(new Duration(milliseconds: 3000));
    List<String> itemTranslateDatas = [];
    var httpClient = new HttpClient();
    String salt = new DateTime.now().millisecondsSinceEpoch.toString();
    String sign = getSign((appid + q + salt + secretKey));
    Map<String, String> params = {"q": q,
      "from": from,
      "to": to,
      "appid": appid,
      "salt": salt,
      "sign": sign};
    //print(TAG + " :translateNormalItems: " + params.toString());
    var uri = new Uri.http(
        'api.fanyi.baidu.com', '/api/trans/vip/translate', params
    );

    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      return null;
    }
    var responseBody = await response.transform(utf8.decoder).join();
    TransResultResp resp = TransResultResp.fromJson(
        json.decode(responseBody.toString()));
    print(TAG + responseBody.toString());
    if (resp == null || resp.transResult == null ||
        resp.transResult.length < 0) {
      return null;
    }
    for (int i = 0; i < resp.transResult.length; i++) {
      itemTranslateDatas.add(resp.transResult
          .elementAt(i)
          .dst);
    }
    return itemTranslateDatas;
  }

  Future<String> translateEnterItem(String from, String to, String q) async {
    await new Future.delayed(new Duration(milliseconds: 3000));
    String itemTranslateData = "";
    var httpClient = new HttpClient();
    String salt = new DateTime.now().millisecondsSinceEpoch.toString();
    String sign = getSign((appid + q + salt + secretKey));
    Map<String, String> params = {"q": q,
      "from": from,
      "to": to,
      "appid": appid,
      "salt": salt,
      "sign": sign};
    //print(TAG + " :translateNormalItems: " + params.toString());
    var uri = new Uri.http(
        'api.fanyi.baidu.com', '/api/trans/vip/translate', params
    );

    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      return null;
    }
    var responseBody = await response.transform(utf8.decoder).join();
    TransResultResp resp = TransResultResp.fromJson(
        json.decode(responseBody.toString()));
    print(TAG + responseBody.toString());
    if (resp == null || resp.transResult == null ||
        resp.transResult.length < 0) {
      return null;
    }
    for (int i = 0; i < resp.transResult.length; i++) {
      if (i == 0) {
        itemTranslateData = itemTranslateData + resp.transResult
            .elementAt(i)
            .dst;
      } else {
        itemTranslateData = itemTranslateData + "\n" + resp.transResult
            .elementAt(i)
            .dst;
      }
    }
    return itemTranslateData;
  }

  String getSign(String data) {
    return md5.convert(utf8.encode(data)).toString();
  }
}