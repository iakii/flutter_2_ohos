// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/book.dart';

// class BookPlayerBottomOptions extends StatelessWidget {
//   const BookPlayerBottomOptions({
//     Key? key,
//     required this.pageIndex,
//     required this.book,
//     required this.onPageChanged,
//   }) : super(key: key);

//   final int pageIndex;
//   final Book book;
//   final void Function(int) onPageChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Expanded(
//           child: Slider(
//         value: pageIndex + 1,
//         min: 1,
//         max: book.pages.length.toDouble(),
//         onChanged: (double value) {
//           if (value.round() != pageIndex + 1) {
//             onPageChanged(value.round() - 1);
//           }
//         },
//         activeColor: Colors.blue,
//         inactiveColor: Colors.blue,
//       )),
//       Text(
//         "${pageIndex + 1} / ${book.pages.length}",
//         style: const TextStyle(fontSize: 16),
//       ),
//       const SizedBox(width: 10),
//     ]);
//   }
// }

class BookPlayerBottomOptions extends StatefulWidget {
  const BookPlayerBottomOptions({
    super.key,
    required this.page,
    required this.pages,
    required this.book,
    required this.onPageChanged,
    required this.onChaptersViewPressed,
    required this.onExit,
    required this.onOptions,
    required this.onNotesPressed,
    required this.onLocationBack,
    required this.onSearch,
    required this.locationBackEnabled,
  });

  final int page;
  final int pages;
  final Book book;
  final void Function(int) onPageChanged;
  final void Function() onChaptersViewPressed;
  final void Function() onExit;
  final void Function() onOptions;
  final void Function() onNotesPressed;
  final void Function() onLocationBack;
  final void Function() onSearch;
  final bool locationBackEnabled;

  @override
  // ignore: library_private_types_in_public_api
  _BookPlayerBottomOptionsState createState() =>
      _BookPlayerBottomOptionsState();
}

class _BookPlayerBottomOptionsState extends State<BookPlayerBottomOptions> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 16),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: IconButton(
              splashRadius: 20,
              icon: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi),
                child: const Icon(Icons.logout_rounded),
              ),
              onPressed: widget.onExit,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              splashRadius: 20,
              icon: const Icon(Icons.menu_open_rounded),
              onPressed: widget.onChaptersViewPressed,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              splashRadius: 20,
              icon: const Icon(Icons.book_outlined, size: 20),
              onPressed: widget.onNotesPressed,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              splashRadius: 20,
              icon: const Icon(Icons.brush_outlined),
              onPressed: widget.onOptions,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              splashRadius: 20,
              icon: const Icon(Icons.search_rounded),
              onPressed: widget.onSearch,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              splashRadius: 20,
              icon: const Icon(Icons.reply_rounded),
              onPressed:
                  widget.locationBackEnabled ? widget.onLocationBack : null,
            ),
          ),
          Expanded(
            child: Text(
              "${widget.page} / ${widget.pages}",
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
