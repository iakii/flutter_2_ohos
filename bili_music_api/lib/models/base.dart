import 'dart:convert';
import 'dart:developer';

import 'package:bili_music_api/models/hot.dart';

import 'audio_detail.dart';

void tryCatch(Function? f) {
  try {
    f?.call();
  } catch (e, stack) {
    log('$e');
    log('$stack');
  }
}

class FFConvert {
  FFConvert._();
  static T? Function<T extends Object?>(dynamic value) convert = <T>(dynamic value) {
    if (value == null) {
      return null;
    }
    return json.decode(value.toString()) as T?;
  };
}

T? asT<T extends Object?>(dynamic value, [T? defaultValue]) {
  if (value is T) {
    return value;
  }
  try {
    if (value != null) {
      final String valueS = value.toString();
      if ('' is T) {
        return valueS as T;
      } else if (0 is T) {
        return int.parse(valueS) as T;
      } else if (0.0 is T) {
        return double.parse(valueS) as T;
      } else if (false is T) {
        if (valueS == '0' || valueS == '1') {
          return (valueS == '1') as T;
        }
        return (valueS == 'true') as T;
      } else {
        return FFConvert.convert<T>(value);
      }
    }
  } catch (e, stackTrace) {
    log('asT<$T>', error: e, stackTrace: stackTrace);
    return defaultValue;
  }

  return defaultValue;
}

class BiliResponse<T> {
  BiliResponse({
    required this.msg,
    required this.data,
    required this.code,
  });

  factory BiliResponse.fromJson(Map<String, dynamic> json) {
    if (T is AudioDetail) {
      print("老子又进来了");
      return BiliResponse(
        msg: asT<String>(json['msg'])!,
        data: json['data'] != null ? AudioDetail.fromJson(json['data']) as T : null as T,
        code: asT<int>(json['code'])!,
      );
    }

    if (List<HotAudio>.empty() is T) {
      final List<HotAudio>? data = json['data'] is List ? <HotAudio>[] : null;
      if (data != null) {
        for (final dynamic item in json['data']!) {
          if (item != null) {
            tryCatch(() {
              data.add(HotAudio.fromJson(asT<Map<String, dynamic>>(item)!));
            });
          }
        }
      }
      return BiliResponse(
        msg: asT<String>(json['msg'])!,
        data: data as T,
        code: asT<int>(json['code'])!,
      );
    }
    return BiliResponse(
      msg: asT<String>(json['msg'])!,
      data: null as T,
      code: asT<int>(json['code'])!,
    );
  }

  String msg;
  T data;
  int code;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'msg': msg,
        'data': data,
        'code': code,
      };

  BiliResponse copy() {
    return BiliResponse(
      msg: msg,
      data: data,
      code: code,
    );
  }
}
