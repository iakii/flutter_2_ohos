import 'dart:convert';
import 'dart:developer';

import 'base.dart';

class AudioStream {
  AudioStream({
    required this.type,
    required this.title,
    required this.timeout,
    required this.size,
    required this.sid,
    required this.qualities,
    required this.info,
    required this.cover,
    required this.cdns,
  });

  factory AudioStream.fromJson(Map<String, dynamic> json) {
    final List<Qualities>? qualities = json['qualities'] is List ? <Qualities>[] : null;
    if (qualities != null) {
      for (final dynamic item in json['qualities']!) {
        if (item != null) {
          tryCatch(() {
            qualities.add(Qualities.fromJson(asT<Map<String, dynamic>>(item)!));
          });
        }
      }
    }

    final List<String>? cdns = json['cdns'] is List ? <String>[] : null;
    if (cdns != null) {
      for (final dynamic item in json['cdns']!) {
        if (item != null) {
          tryCatch(() {
            cdns.add(asT<String>(item)!);
          });
        }
      }
    }
    return AudioStream(
      type: asT<int>(json['type'])!,
      title: asT<String>(json['title'])!,
      timeout: asT<int>(json['timeout'])!,
      size: asT<int>(json['size'])!,
      sid: asT<int>(json['sid'])!,
      qualities: qualities!,
      info: asT<String>(json['info'])!,
      cover: asT<String>(json['cover'])!,
      cdns: cdns!,
    );
  }

  int type;
  String title;
  int timeout;
  int size;
  int sid;
  List<Qualities> qualities;
  String info;
  String cover;
  List<String> cdns;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'title': title,
        'timeout': timeout,
        'size': size,
        'sid': sid,
        'qualities': qualities,
        'info': info,
        'cover': cover,
        'cdns': cdns,
      };

  AudioStream copy() {
    return AudioStream(
      type: type,
      title: title,
      timeout: timeout,
      size: size,
      sid: sid,
      qualities: qualities.map((Qualities e) => e.copy()).toList(),
      info: info,
      cover: cover,
      cdns: cdns.map((String e) => e).toList(),
    );
  }
}

class Qualities {
  Qualities({
    required this.type,
    required this.tag,
    required this.size,
    required this.requiredesc,
    required this.require,
    required this.desc,
    required this.bps,
  });

  factory Qualities.fromJson(Map<String, dynamic> json) => Qualities(
        type: asT<int>(json['type'])!,
        tag: asT<String>(json['tag'])!,
        size: asT<int>(json['size'])!,
        requiredesc: asT<String>(json['requiredesc'])!,
        require: asT<int>(json['require'])!,
        desc: asT<String>(json['desc'])!,
        bps: asT<String>(json['bps'])!,
      );

  int type;
  String tag;
  int size;
  String requiredesc;
  int require;
  String desc;
  String bps;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'tag': tag,
        'size': size,
        'requiredesc': requiredesc,
        'require': require,
        'desc': desc,
        'bps': bps,
      };

  Qualities copy() {
    return Qualities(
      type: type,
      tag: tag,
      size: size,
      requiredesc: requiredesc,
      require: require,
      desc: desc,
      bps: bps,
    );
  }
}
