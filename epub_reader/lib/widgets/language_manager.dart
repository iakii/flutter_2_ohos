// import 'package:epub_reader/widgets/clean_app_bar.dart';
// import 'package:epub_reader/widgets/message_popup.dart';
// import 'package:flutter/material.dart';

// class LanguageManager extends StatefulWidget {
//   const LanguageManager({
//     Key? key,
//   }) : super(key: key);


//   @override
//   _LanguageManagerState createState() => _LanguageManagerState();
// }

// class _LanguageManagerState extends State<LanguageManager> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CleanAppBar(title: "Language Manager"),
//       body: ListView.builder(
//         itemBuilder: (context, index) {
//           final language = TranslateLanguage.values[index];
//           return ListTile(
//             title: Text(language.name),
//             trailing: FutureBuilder<bool>(
//               future: widget.modelManager.isModelDownloaded(language.bcpCode),
//               builder: (context, snapshot) => Icon(
//                 snapshot.hasData && snapshot.data == true
//                     ? Icons.download_done
//                     : null,
//               ),
//             ),
//             onTap: () async {
//               if (await widget.modelManager.downloadModel(language.bcpCode)) {
//                 messagePopup(
//                   context,
//                   "Finished downloading",
//                   "Successfully downloaded ${language.name}.",
//                 );
//               } else {
//                 messagePopup(
//                   context,
//                   "Error while downloading",
//                   "Couldn't download ${language.name}.",
//                 );
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
// }
