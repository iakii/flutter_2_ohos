import 'dart:convert';

import 'base.dart';

class HotAudio {
  HotAudio({
    required this.type,
    required this.title,
    required this.menuId,
    required this.intro,
    required this.coverUrl,
    required this.audios,
  });

  factory HotAudio.fromJson(Map<String, dynamic> json) {
    final List<Audios>? audios = json['audios'] is List ? <Audios>[] : null;
    if (audios != null) {
      for (final dynamic item in json['audios']!) {
        if (item != null) {
          tryCatch(() {
            audios.add(Audios.fromJson(asT<Map<String, dynamic>>(item)!));
          });
        }
      }
    }
    return HotAudio(
      type: asT<int>(json['type'])!,
      title: asT<String>(json['title'])!,
      menuId: asT<int>(json['menuId'])!,
      intro: asT<String>(json['intro'])!,
      coverUrl: asT<String>(json['coverUrl'])!,
      audios: audios!,
    );
  }

  int type;
  String title;
  int menuId;
  String intro;
  String coverUrl;
  List<Audios> audios;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'title': title,
        'menuId': menuId,
        'intro': intro,
        'coverUrl': coverUrl,
        'audios': audios,
      };

  HotAudio copy() {
    return HotAudio(
      type: type,
      title: title,
      menuId: menuId,
      intro: intro,
      coverUrl: coverUrl,
      audios: audios.map((Audios e) => e.copy()).toList(),
    );
  }
}

class Audios {
  Audios({
    required this.title,
    required this.id,
    required this.author,
  });

  factory Audios.fromJson(Map<String, dynamic> json) => Audios(
        title: asT<String>(json['title'])!,
        id: asT<int>(json['id'])!,
        author: asT<String>(json['author'])!,
      );

  String title;
  int id;
  String author;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'id': id,
        'author': author,
      };

  Audios copy() {
    return Audios(
      title: title,
      id: id,
      author: author,
    );
  }
}
