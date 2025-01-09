// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker_ohos/file_picker_ohos.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:http/http.dart';

// Project imports:
import 'package:epub_reader/pages/home_settings.dart';
import 'package:epub_reader/providers/book_downloader/book_downloader.dart';
import '../managers/settings_manager.dart';
import '../models/book.dart';
import '../widgets/book_downloader_interface.dart';
import '../widgets/clean_app_bar.dart';
import '../widgets/message_popup.dart';
import 'book_player.dart';
import 'library.dart';
import 'search.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.settingsManager});

  final SettingsManager settingsManager;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final httpClient = Client();
  late AnimationController animationController;
  late Animation<double> opacityAnimation;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(animationController);

    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      FutureBuilder(
        future: Future.wait([
          widget.settingsManager.loadAllBooks(),
          widget.settingsManager.loadShelves(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final books = (snapshot.data as List)[0] as List<Book>;
            final shelves = (snapshot.data as List)[1] as List<Shelf>;
            return Library(
              settingsManager: widget.settingsManager,
              onImageChanged: (book, newImageFile) async {
                await newImageFile.copy(book.savedData!.coverFile.path);

                final decodedImage = await decodeImageFromList(
                  newImageFile.readAsBytesSync(),
                );

                book.savedData!.data.coverSize = Size(
                  decodedImage.width.toDouble(),
                  decodedImage.height.toDouble(),
                );

                await book.savedData!.saveData();

                Phoenix.rebirth(context);
              },
              onDeleteBook: (book) async {
                await widget.settingsManager.deleteBook(book.savedData!.bookId);
                setState(() {});
              },
              books: books,
              shelves: shelves,
              onCreateShelf: (String name) async {
                await widget.settingsManager.createShelf(name);
                setState(() {});
              },
              onDeleteShelf: (shelf) async {
                await shelf.deleteConfig();
                setState(() {});
              },
              onReadBook: (book) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookPlayer(
                      initialStyle: book.savedData!.data.styleProperties,
                      book: book,
                      wordDictionaryEnum:
                          widget.settingsManager.config.wordDictionary,
                      bookOptions: BookOptions(
                        BookThemeData(
                          backgroundColor: Colors.white,
                          textColor: Colors.grey[400]!,
                        ),
                      ),
                      settingsManager: widget.settingsManager,
                      wordsPerPage: widget.settingsManager.config.wordsPerPage,
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: CupertinoActivityIndicator());
          }
        },
      ),
      Search(
        settingsManager: widget.settingsManager,
        bookMetadataEnum: widget.settingsManager.config.bookMetadata,
        onBookDownload: (book) async {
          final bookDownloader = await createBookDownloader(
              widget.settingsManager.config.bookDownloader);
          if (bookDownloader == null) {
            messagePopup(
              context,
              "Unknown book downloader",
              "Make sure you have selected a book downloader",
            );
            return;
          }

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: BookDownloaderInterface(
                  description: book.description,
                  getter: BookDownloaderInterfaceDownloader(
                    bookDownloader: bookDownloader,
                    bookIdentifier: book.bookIdentifier,
                  ),
                  booksDirectory: widget.settingsManager.directory,
                  onDone: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          );
        },
      ),
    ];

    return Scaffold(
      appBar: CleanAppBar(
        title: pageIndex == 0 ? "Library" : "Search",
        canBack: false,
        actions: [
          IconButton(
            splashRadius: 20,
            icon: const Icon(
              Icons.add_outlined,
            ),
            onPressed: () async {
              final files = (await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['epub'],
                allowMultiple: true,
              ))
                  ?.files;

              if (files?.isEmpty ?? true) {
                return;
              }

              final getter = BookDownloaderInterfaceBytes(
                bookFileBytes: await File(files!.single.path!).readAsBytes(),
              );

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: BookDownloaderInterface(
                      getter: getter,
                      booksDirectory: widget.settingsManager.directory,
                      onDone: () {
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            splashRadius: 20,
            icon: const Icon(
              Icons.settings_outlined,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeSettings(
                    settingsManager: widget.settingsManager,
                  ),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Opacity(
            opacity: opacityAnimation.value,
            child: child,
          );
        },
        child: pages[pageIndex],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: Theme.of(context).navigationBarTheme,
        child: NavigationBar(
          selectedIndex: pageIndex,
          onDestinationSelected: (index) {
            setState(() {
              pageIndex = index;
            });
            animationController.reset();
            animationController.forward();
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.library_books),
              label: "Library",
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ),
          ],
        ),
      ),
    );
  }
}
