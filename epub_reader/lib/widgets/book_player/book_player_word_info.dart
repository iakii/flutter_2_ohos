import 'package:flutter/material.dart';

// import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../models/word_definition.dart';
import '../../providers/word_dictionary/word_dictionary.dart';

class BookPlayerWordInfo extends StatefulWidget {
  const BookPlayerWordInfo({
    Key? key,
    required this.word,
    this.wordDictionary,
    this.onClose,
    this.onFocusChange,
  }) : super(key: key);

  final String word;
  final WordDictionary? wordDictionary;
  final void Function()? onClose;
  final void Function(bool)? onFocusChange;
  // final TranslateLanguage initialFromLanguage;
  // final TranslateLanguage initialToLanguage;
  // final OnDeviceTranslatorModelManager modelManager;
  // final void Function(TranslateLanguage from, TranslateLanguage to)?
  // onLanguagesChanged;

  @override
  State<BookPlayerWordInfo> createState() => _BookPlayerWordInfoState();
}

class _BookPlayerWordInfoState extends State<BookPlayerWordInfo> with SingleTickerProviderStateMixin {
  late TabController tabController;
  late String inputWord;
  late String previousWord;
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 1,
      initialIndex: 0,
      vsync: this,
    );
    inputWord = widget.word;
    previousWord = widget.word;
    textEditingController = TextEditingController(text: widget.word);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.word != previousWord) {
      inputWord = widget.word;
      textEditingController.text = widget.word;
      previousWord = widget.word;
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Focus(
                    child: TextFormField(
                      controller: textEditingController,
                      onFieldSubmitted: (String value) {
                        setState(() {
                          inputWord = value;
                        });
                      },
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    onFocusChange: widget.onFocusChange,
                  ),
                ),
                if (widget.onClose != null)
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      splashRadius: 20,
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose!,
                    ),
                  ),
              ],
            ),
            // SizedBox(
            //   height: 30,
            //   child: TabBar(
            //     controller: tabController,
            //     labelStyle: Theme.of(context).textTheme.titleSmall,
            //     tabs: const [
            //       Tab(text: "Definition"),
            //       // Tab(text: "Translation"),
            //     ],
            //   ),
            // ),
            Expanded(
              child: widget.wordDictionary == null
                  ? const Center(child: Text("No word dictionary"))
                  : FutureBuilder(
                      future: widget.wordDictionary!.getDefinition(inputWord),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final wordDefinitions = snapshot.data as List<WordDefinition>;
                          return _WordDefinitionDisplay(wordDefinition: wordDefinitions.first);
                        } else if (snapshot.hasError) {
                          return Text(
                            "Error: ${snapshot.error}",
                            style: Theme.of(context).textTheme.headline6,
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class _WordDefinitionDisplay extends StatelessWidget {
  const _WordDefinitionDisplay({
    Key? key,
    required this.wordDefinition,
  }) : super(key: key);

  final WordDefinition wordDefinition;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.separated(
        // padding: const EdgeInsets.only(top: 10),
        padding: EdgeInsets.zero,
        itemCount: wordDefinition.meanings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final meaning = wordDefinition.meanings[index];
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(meaning.partOfSpeech, style: Theme.of(context).textTheme.bodyLarge!),
              ),
              ...meaning.definitions.asMap().entries.map(
                    (entry) => Row(
                      children: [
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            "${entry.key + 1}: ${entry.value}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
