// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:epub_reader/models/book.dart';
import 'package:epub_reader/models/book_saved_data.dart';
import '../providers/book_downloader/book_downloader.dart';

// import 'package:permission_handler/permission_handler.dart';


enum Stage {
  idle,
  download,
  processing,
  error,
  done,
}

class BookDownloaderInterfaceGetter {}

class BookDownloaderInterfaceDownloader
    implements BookDownloaderInterfaceGetter {
  final BookIdentifier bookIdentifier;
  final BookDownloader bookDownloader;

  BookDownloaderInterfaceDownloader({
    required this.bookIdentifier,
    required this.bookDownloader,
  });
}

class BookDownloaderInterfaceBytes implements BookDownloaderInterfaceGetter {
  final List<int> bookFileBytes;

  BookDownloaderInterfaceBytes({
    required this.bookFileBytes,
  });
}

class BookDownloaderInterface extends StatefulWidget {
  const BookDownloaderInterface({
    super.key,
    this.description,
    required this.getter,
    required this.booksDirectory,
    this.onDone,
  });

  final String? description;
  final BookDownloaderInterfaceGetter getter;
  final Directory booksDirectory;
  final void Function()? onDone;

  @override
  // ignore: library_private_types_in_public_api
  _BookDownloaderInterfaceState createState() =>
      _BookDownloaderInterfaceState();
}

class _BookDownloaderInterfaceState extends State<BookDownloaderInterface> {
  final Client httpClient = Client();
  final uuid = const Uuid();
  double? downloadProgress;
  Stage stage = Stage.idle;

  @override
  void initState() {
    super.initState();
    begin();
  }

  Future<List<int>?> downloadEpub(
      BookDownloaderInterfaceDownloader getter) async {
    // final completer = Completer<List<int>?>();

    final uri =
        (await getter.bookDownloader.getEpubDownload(getter.bookIdentifier));

    if (uri == null) {
      return null;
    }

    final res = await httpClient.get(uri);

    if (res.statusCode != 200) {
      return null;
    }

    return res.bodyBytes;
  }

  Future<void> begin() async {
    // final status = await Permission.storage.status;
    // switch (status) {
    //   case PermissionStatus.denied:
    //     await Permission.storage.request();
    //     return;
    //   case PermissionStatus.granted:
    //     break;
    //   case PermissionStatus.restricted:
    //   case PermissionStatus.limited:
    //   case PermissionStatus.permanentlyDenied:
    //     setState(() {
    //       stage = Stage.error;
    //     });
    //     return;
    //   case PermissionStatus.provisional:
    //     break;
    // }

    setState(() {
      stage = Stage.download;
      downloadProgress = 0;
    });

    List<int>? epubBytes;

    if (widget.getter is BookDownloaderInterfaceDownloader) {
      // epubBytes =
      //     (await rootBundle.load("assets/sample.epub")).buffer.asInt8List();
      epubBytes = await downloadEpub(
          widget.getter as BookDownloaderInterfaceDownloader);
    } else if (widget.getter is BookDownloaderInterfaceBytes) {
      epubBytes = (widget.getter as BookDownloaderInterfaceBytes).bookFileBytes;
    }

    if (epubBytes == null) {
      setState(() {
        stage = Stage.error;
      });
      return;
    }

    await File("${widget.booksDirectory.path}/test.epub")
        .writeAsBytes(epubBytes);

    setState(() {
      stage = Stage.processing;
      downloadProgress = 0.5;
    });

    await BookSavedData.writeFromEpub(
      epubBytes: epubBytes,
      description: widget.description,
      directory: Directory(
        p.join(widget.booksDirectory.path, uuid.v4()),
      ),
    );

    setState(() {
      stage = Stage.done;
    });

    widget.onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TextButton(
        //   child: const Text("Download"),
        //   onPressed: begin,
        // ),
        if (stage == Stage.download) const Text("Downloading..."),
        if (stage == Stage.processing) const Text("Processing..."),
        if (stage == Stage.error) const Text("Error."),
        if (stage == Stage.done) const Text("Done."),
        Visibility(
          visible: stage == Stage.download || stage == Stage.processing,
          child: LinearProgressIndicator(
            value: downloadProgress,
          ),
        )
      ],
    );
  }
}
