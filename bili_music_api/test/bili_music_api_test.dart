// import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: avoid_print

import 'package:bili_music_api/bili_music_api.dart';

Future<void> main() async {
  // test('adds one to input values', () {
  //   final calculator = biliMusicApi.getHotList();
  //   expect(calculator.addOne(2), 3);
  //   expect(calculator.addOne(-7), -6);
  //   expect(calculator.addOne(0), 1);
  // });

  final calculator = await biliMusicApi.getSongStreamUrl(4059094, 2034122930);

  print(calculator?.cdns);
}
