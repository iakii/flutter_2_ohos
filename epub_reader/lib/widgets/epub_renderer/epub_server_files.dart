// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:epubx/epubx.dart';
import 'package:path/path.dart' as p;

class EpubServerFiles {
  final EpubBook epubBook;
  HttpServer? server;
  EpubServerFiles(this.epubBook);

  Future<void> initialize() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    server!.listen(_handleRequest);
  }

  void close() {
    server?.close();
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final path = Uri.decodeFull(request.requestedUri.path);
    final pathSplit =
        path.split("/").where((element) => element.isNotEmpty).toList();

    if (pathSplit.isEmpty) {
      final htmlContent = await rootBundle.loadString("assets/index.html");
      request.response
        ..headers.contentType = ContentType.html
        ..add(utf8.encode(htmlContent))
        ..close();
      return;
    }

    switch (pathSplit[0]) {
      case "_fonts":
        {
          final fontPath = pathSplit.skip(1).join("/");
          final Int8List bytes;
          try {
            bytes = (await rootBundle.load(p.join("assets/fonts", fontPath)))
                .buffer
                .asInt8List();
          } catch (e) {
            request.response
              ..statusCode = HttpStatus.notFound
              ..close();
            return;
          }

          request.response
            ..headers.contentType = ContentType.parse("font/ttf")
            ..add(bytes)
            ..close();

          return;
        }
      default:
        {
          final filePath = pathSplit.join("/");

          final EpubContentFile? file = epubBook.Content?.AllFiles?[filePath];

          if (file == null) {
            request.response
              ..statusCode = HttpStatus.notFound
              ..close();
            return;
          }

          final List<int> content;
          ContentType mimeType = ContentType.parse(file.ContentMimeType!);

          if (file is EpubTextContentFile) {
            content = utf8.encode(file.Content!);
          } else if (file is EpubByteContentFile) {
            content = file.Content!;
          } else {
            request.response
              ..statusCode = HttpStatus.badRequest
              ..close();
            return;
          }

          request.response
            ..headers.contentType = mimeType
            ..add(content)
            ..close();

          return;
        }
    }
  }
}
