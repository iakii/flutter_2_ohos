// Package imports:
import 'package:epubx/epubx.dart';

// ignore: implementation_imports

List<EpubManifestItem> getSpineItemsFromEpub(EpubBook epubBook) {
  return epubBook.Schema!.Package!.Spine!.Items!.map((item) {
    // print(item);

    return epubBook.Schema!.Package!.Manifest!.Items!.where((element) {
      if (element.MediaType == "application/x-dtbncx+xml") {
        return false;
      }
      // print(">> $element");
      return element.Id == item.IdRef;
    }).first;
  }).toList();
}
