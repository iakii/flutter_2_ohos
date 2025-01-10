import 'package:bili_music_api/models/audio_detail.dart';
import 'package:bili_music_api/models/base.dart';
import 'package:dio/dio.dart';

import 'models/audio_stream.dart';
import 'models/hot.dart';

/// A Calculator.
class _BiliMusicApi {
  final _dio = Dio();

  Future<List<HotAudio>> getHotList({int pageSize = 20, int pageIndex = 1}) async {
    final respons = await _dio.get("https://api.bilibili.com/audio/music-service-c/menus/rank?cateId=1&pageNum=$pageIndex&pageSize=$pageSize");

    final result = BiliResponse<List<HotAudio>>.fromJson(respons.data);
    if (result.code == 0) return result.data ?? [];

    return [];
  }

  Future<AudioDetail?> getAudioInfo(int songId) async {
    final response = await _dio.get<Map<String, dynamic>>("https://api.bilibili.com/audio/music-service-c/songs/playing?song_id=$songId");

    // final result = BiliResponse<AudioDetail>.fromJson(response.data);
    if (response.statusCode == 200) return AudioDetail.fromJson(response.data!['data']);
    return null;
  }

  Future<AudioStream?> getSongStreamUrl(int songId, int mid) async {
    final response = await _dio.get("https://api.bilibili.com/audio/music-service-c/url?mid=$mid&platform=android&privilege=0&quality=3&songid=$songId");

    if (response.statusCode == 200) return AudioStream.fromJson(response.data!['data']);
    return null;
  }
}

final biliMusicApi = _BiliMusicApi();
