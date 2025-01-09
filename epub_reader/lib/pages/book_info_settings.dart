// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker_ohos/file_picker_ohos.dart';

// Project imports:
import 'package:epub_reader/providers/character_metadata/character_metadata.dart';
import 'package:epub_reader/widgets/clean_app_bar.dart';
import '../models/book.dart';
import '../widgets/settings_enum_dropdown.dart';

class BookInfoSettings extends StatefulWidget {
  const BookInfoSettings({
    super.key,
    required this.book,
    required this.onImageChanged,
    required this.onDelete,
    required this.characterMetadataNames,
  });

  final Book book;
  final void Function() onDelete;
  final void Function(File) onImageChanged;
  final List<String> characterMetadataNames;

  @override
  _BookInfoSettingsState createState() => _BookInfoSettingsState();
}

class _BookInfoSettingsState extends State<BookInfoSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CleanAppBar(
        title: 'Settings for ${widget.book.name}',
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 80,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  color: Theme.of(context).primaryColor,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 160,
                      height: 200,
                      child: widget.book.coverProvider != null
                          ? Image(
                              image: widget.book.coverProvider!,
                            )
                          : Container(
                              color: Colors.purple,
                            ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          TextButton(
                            onPressed: () async {
                              final files = (await FilePicker.platform
                                      .pickFiles(type: FileType.image))
                                  ?.files;

                              if (files?.isEmpty ?? true) {
                                return;
                              }

                              final imageFile = File(files!.single.path!);

                              widget.onImageChanged(imageFile);
                            },
                            style: ButtonStyle(
                              foregroundColor:
                                  WidgetStateProperty.all(Colors.white),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Set a new cover",
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SettingsEnumDropdown(
                settingName: "Character Metadata",
                value: widget.book.savedData!.data.characterMetadata,
                dropdownItems: CharacterMetadataEnum.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name),
                      ),
                    )
                    .toList(),
                onChange: (CharacterMetadataEnum? value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    widget.book.savedData!.data.characterMetadata = value;
                  });
                  widget.book.savedData!.saveData();
                },
              ),
              if (widget.book.savedData!.data.characterMetadata ==
                  CharacterMetadataEnum.local)
                SettingsEnumDropdown(
                  settingName: "List of local characters",
                  dropdownItems: widget.characterMetadataNames
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChange: (String? value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      widget.book.savedData!.data.characterMetadataName = value;
                    });
                    widget.book.savedData!.saveData();
                  },
                  value: widget.characterMetadataNames.contains(
                          widget.book.savedData!.data.characterMetadataName)
                      ? widget.book.savedData!.data.characterMetadataName
                      : null,
                ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  color: Theme.of(context).primaryColor,
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        widget.onDelete();
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.red),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                      ),
                      child: const Text('Delete'),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ]
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: e,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
