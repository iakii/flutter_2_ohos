import 'dart:convert';
import 'dart:developer';

import 'base.dart';

class AudioDetail {
  AudioDetail({
    required this.videos,
    required this.upName,
    required this.upMid,
    required this.upIsFollow,
    required this.upImg,
    required this.upHitAudios,
    required this.upCertType,
    required this.upCertInfo,
    required this.title,
    required this.songAttr,
    required this.snum,
    required this.replyCount,
    this.region,
    required this.qualities,
    required this.playCount,
    this.pgcInfo,
    required this.mid,
    this.memberList,
    required this.lyricUrl,
    required this.limitdesc,
    required this.limit,
    required this.isOff,
    required this.isFromVideo,
    required this.isCollect,
    required this.isCacheable,
    required this.intro,
    required this.id,
    required this.fans,
    required this.duration,
    required this.ctimeStr,
    required this.ctime,
    required this.coverUrl,
    required this.collectCount,
    required this.coinceiling,
    required this.coinNum,
    required this.bvid,
    required this.avid,
    required this.author,
    required this.albumId,
  });

  factory AudioDetail.fromJson(Map<String, dynamic> json) {
    final List<Videos>? videos = json['videos'] is List ? <Videos>[] : null;
    if (videos != null) {
      for (final dynamic item in json['videos']!) {
        if (item != null) {
          tryCatch(() {
            videos.add(Videos.fromJson(asT<Map<String, dynamic>>(item)!));
          });
        }
      }
    }

    final List<UpHitAudios>? upHitAudios = json['up_hit_audios'] is List ? <UpHitAudios>[] : null;
    if (upHitAudios != null) {
      for (final dynamic item in json['up_hit_audios']!) {
        if (item != null) {
          tryCatch(() {
            upHitAudios.add(UpHitAudios.fromJson(asT<Map<String, dynamic>>(item)!));
          });
        }
      }
    }

    final List<Qualitie>? qualities = json['qualities'] is List ? <Qualitie>[] : null;
    if (qualities != null) {
      for (final dynamic item in json['qualities']!) {
        if (item != null) {
          tryCatch(() {
            qualities.add(Qualitie.fromJson(asT<Map<String, dynamic>>(item)!));
          });
        }
      }
    }
    return AudioDetail(
      videos: videos!,
      upName: asT<String>(json['up_name'])!,
      upMid: asT<int>(json['up_mid'])!,
      upIsFollow: asT<int>(json['up_is_follow'])!,
      upImg: asT<String>(json['up_img'])!,
      upHitAudios: upHitAudios!,
      upCertType: asT<int>(json['up_cert_type'])!,
      upCertInfo: asT<String>(json['up_cert_info'])!,
      title: asT<String>(json['title'])!,
      songAttr: asT<int>(json['songAttr'])!,
      snum: asT<int>(json['snum'])!,
      replyCount: asT<int>(json['reply_count'])!,
      region: asT<Object?>(json['region']),
      qualities: qualities!,
      playCount: asT<int>(json['play_count'])!,
      pgcInfo: asT<Object?>(json['pgc_info']),
      mid: asT<int>(json['mid'])!,
      memberList: asT<Object?>(json['memberList']),
      lyricUrl: asT<String>(json['lyric_url'])!,
      limitdesc: asT<String>(json['limitdesc'])!,
      limit: asT<int>(json['limit'])!,
      isOff: asT<int>(json['is_off'])!,
      isFromVideo: asT<int>(json['isFromVideo'])!,
      isCollect: asT<int>(json['is_collect'])!,
      isCacheable: asT<bool>(json['is_cacheable'])!,
      intro: asT<String>(json['intro'])!,
      id: asT<int>(json['id'])!,
      fans: asT<int>(json['fans'])!,
      duration: asT<int>(json['duration'])!,
      ctimeStr: asT<String>(json['ctime_str'])!,
      ctime: asT<int>(json['ctime'])!,
      coverUrl: asT<String>(json['cover_url'])!,
      collectCount: asT<int>(json['collect_count'])!,
      coinceiling: asT<int>(json['coinceiling'])!,
      coinNum: asT<int>(json['coin_num'])!,
      bvid: asT<String>(json['bvid'])!,
      avid: asT<String>(json['avid'])!,
      author: asT<String>(json['author'])!,
      albumId: asT<int>(json['album_id'])!,
    );
  }

  List<Videos> videos;
  String upName;
  int upMid;
  int upIsFollow;
  String upImg;
  List<UpHitAudios> upHitAudios;
  int upCertType;
  String upCertInfo;
  String title;
  int songAttr;
  int snum;
  int replyCount;
  Object? region;
  List<Qualitie> qualities;
  int playCount;
  Object? pgcInfo;
  int mid;
  Object? memberList;
  String lyricUrl;
  String limitdesc;
  int limit;
  int isOff;
  int isFromVideo;
  int isCollect;
  bool isCacheable;
  String intro;
  int id;
  int fans;
  int duration;
  String ctimeStr;
  int ctime;
  String coverUrl;
  int collectCount;
  int coinceiling;
  int coinNum;
  String bvid;
  String avid;
  String author;
  int albumId;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'videos': videos,
        'up_name': upName,
        'up_mid': upMid,
        'up_is_follow': upIsFollow,
        'up_img': upImg,
        'up_hit_audios': upHitAudios,
        'up_cert_type': upCertType,
        'up_cert_info': upCertInfo,
        'title': title,
        'songAttr': songAttr,
        'snum': snum,
        'reply_count': replyCount,
        'region': region,
        'qualities': qualities,
        'play_count': playCount,
        'pgc_info': pgcInfo,
        'mid': mid,
        'memberList': memberList,
        'lyric_url': lyricUrl,
        'limitdesc': limitdesc,
        'limit': limit,
        'is_off': isOff,
        'isFromVideo': isFromVideo,
        'is_collect': isCollect,
        'is_cacheable': isCacheable,
        'intro': intro,
        'id': id,
        'fans': fans,
        'duration': duration,
        'ctime_str': ctimeStr,
        'ctime': ctime,
        'cover_url': coverUrl,
        'collect_count': collectCount,
        'coinceiling': coinceiling,
        'coin_num': coinNum,
        'bvid': bvid,
        'avid': avid,
        'author': author,
        'album_id': albumId,
      };

  AudioDetail copy() {
    return AudioDetail(
      videos: videos.map((Videos e) => e.copy()).toList(),
      upName: upName,
      upMid: upMid,
      upIsFollow: upIsFollow,
      upImg: upImg,
      upHitAudios: upHitAudios.map((UpHitAudios e) => e.copy()).toList(),
      upCertType: upCertType,
      upCertInfo: upCertInfo,
      title: title,
      songAttr: songAttr,
      snum: snum,
      replyCount: replyCount,
      region: region,
      qualities: qualities.map((Qualitie e) => e.copy()).toList(),
      playCount: playCount,
      pgcInfo: pgcInfo,
      mid: mid,
      memberList: memberList,
      lyricUrl: lyricUrl,
      limitdesc: limitdesc,
      limit: limit,
      isOff: isOff,
      isFromVideo: isFromVideo,
      isCollect: isCollect,
      isCacheable: isCacheable,
      intro: intro,
      id: id,
      fans: fans,
      duration: duration,
      ctimeStr: ctimeStr,
      ctime: ctime,
      coverUrl: coverUrl,
      collectCount: collectCount,
      coinceiling: coinceiling,
      coinNum: coinNum,
      bvid: bvid,
      avid: avid,
      author: author,
      albumId: albumId,
    );
  }
}

class Videos {
  Videos({
    required this.view,
    required this.title,
    this.song,
    required this.reply,
    required this.ptitle,
    required this.pic,
    required this.page,
    required this.duration,
    required this.aid,
  });

  factory Videos.fromJson(Map<String, dynamic> json) => Videos(
        view: asT<int>(json['view'])!,
        title: asT<String>(json['title'])!,
        song: asT<Object?>(json['song']),
        reply: asT<int>(json['reply'])!,
        ptitle: asT<String>(json['ptitle'])!,
        pic: asT<String>(json['pic'])!,
        page: asT<int>(json['page'])!,
        duration: asT<int>(json['duration'])!,
        aid: asT<int>(json['aid'])!,
      );

  int view;
  String title;
  Object? song;
  int reply;
  String ptitle;
  String pic;
  int page;
  int duration;
  int aid;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'view': view,
        'title': title,
        'song': song,
        'reply': reply,
        'ptitle': ptitle,
        'pic': pic,
        'page': page,
        'duration': duration,
        'aid': aid,
      };

  Videos copy() {
    return Videos(
      view: view,
      title: title,
      song: song,
      reply: reply,
      ptitle: ptitle,
      pic: pic,
      page: page,
      duration: duration,
      aid: aid,
    );
  }
}

class UpHitAudios {
  UpHitAudios({
    required this.uname,
    required this.uid,
    required this.title,
    required this.songAttr,
    required this.schema,
    required this.replyNum,
    required this.qualities,
    required this.playNum,
    this.payment,
    required this.page,
    required this.limitdesc,
    required this.limit,
    required this.isOff,
    required this.id,
    required this.duration,
    required this.ctimeFmt,
    required this.ctime,
    required this.cover,
    required this.avid,
    required this.author,
  });

  factory UpHitAudios.fromJson(Map<String, dynamic> json) {
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
    return UpHitAudios(
      uname: asT<String>(json['uname'])!,
      uid: asT<int>(json['uid'])!,
      title: asT<String>(json['title'])!,
      songAttr: asT<int>(json['song_attr'])!,
      schema: asT<String>(json['schema'])!,
      replyNum: asT<int>(json['reply_num'])!,
      qualities: qualities!,
      playNum: asT<int>(json['play_num'])!,
      payment: asT<Object?>(json['payment']),
      page: asT<int>(json['page'])!,
      limitdesc: asT<String>(json['limitdesc'])!,
      limit: asT<int>(json['limit'])!,
      isOff: asT<int>(json['is_off'])!,
      id: asT<int>(json['id'])!,
      duration: asT<int>(json['duration'])!,
      ctimeFmt: asT<String>(json['ctime_fmt'])!,
      ctime: asT<int>(json['ctime'])!,
      cover: asT<String>(json['cover'])!,
      avid: asT<String>(json['avid'])!,
      author: asT<String>(json['author'])!,
    );
  }

  String uname;
  int uid;
  String title;
  int songAttr;
  String schema;
  int replyNum;
  List<Qualities> qualities;
  int playNum;
  Object? payment;
  int page;
  String limitdesc;
  int limit;
  int isOff;
  int id;
  int duration;
  String ctimeFmt;
  int ctime;
  String cover;
  String avid;
  String author;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'uname': uname,
        'uid': uid,
        'title': title,
        'song_attr': songAttr,
        'schema': schema,
        'reply_num': replyNum,
        'qualities': qualities,
        'play_num': playNum,
        'payment': payment,
        'page': page,
        'limitdesc': limitdesc,
        'limit': limit,
        'is_off': isOff,
        'id': id,
        'duration': duration,
        'ctime_fmt': ctimeFmt,
        'ctime': ctime,
        'cover': cover,
        'avid': avid,
        'author': author,
      };

  UpHitAudios copy() {
    return UpHitAudios(
      uname: uname,
      uid: uid,
      title: title,
      songAttr: songAttr,
      schema: schema,
      replyNum: replyNum,
      qualities: qualities.map((Qualities e) => e.copy()).toList(),
      playNum: playNum,
      payment: payment,
      page: page,
      limitdesc: limitdesc,
      limit: limit,
      isOff: isOff,
      id: id,
      duration: duration,
      ctimeFmt: ctimeFmt,
      ctime: ctime,
      cover: cover,
      avid: avid,
      author: author,
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

class Qualitie {
  Qualitie({
    required this.type,
    required this.tag,
    required this.size,
    required this.requiredesc,
    required this.require,
    required this.desc,
    required this.bps,
  });

  factory Qualitie.fromJson(Map<String, dynamic> json) => Qualitie(
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

  Qualitie copy() {
    return Qualitie(
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
