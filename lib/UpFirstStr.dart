class UpFirstStr{

  static String TAG = "UpFirstStr: ";

  static convert(String str){
    if(str==null||str.length<=0){
      return "";
    }
    String tempStr="";
    if(str.length==1){
      tempStr = str[0].toUpperCase();
    }else{
      tempStr = str[0].toUpperCase() + str.substring(1);
    }
    return tempStr;
  }

}