class MetaModel {
  int top = 0;
  int skip = 0;
  int inlineCount = 0;

  MetaModel(){
    initialize();
  }

  initialize(){
    top = 0;
    skip = 0;
    inlineCount = 0;
  }


  deserialize(Map<String, dynamic> json) {
    top = json['top'];
    skip = json['skip'];
    inlineCount = json['inlineCount'];
  }


  Map<String, dynamic> serialize(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['top'] = top;
    data['skip'] = skip;
    data['inlineCount'] = inlineCount;
    return data;
  }

}
