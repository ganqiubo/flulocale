class TransResultResp {
  String from;
  String to;
  List<TransResult> transResult;

  TransResultResp({this.from, this.to, this.transResult});

  TransResultResp.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    if (json['trans_result'] != null) {
      transResult = new List<TransResult>();
      json['trans_result'].forEach((v) {
        transResult.add(new TransResult.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['to'] = this.to;
    if (this.transResult != null) {
      data['trans_result'] = this.transResult.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TransResult {
  String src;
  String dst;

  TransResult({this.src, this.dst});

  TransResult.fromJson(Map<String, dynamic> json) {
    src = json['src'];
    dst = json['dst'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['src'] = this.src;
    data['dst'] = this.dst;
    return data;
  }
}