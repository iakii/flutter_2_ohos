/*
 *     Copyright (C) 2024 Valeri Gokadze
 *
 *     Musify is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Musify is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Musify, including how to contribute,
 *     please visit: https://github.com/gokadzev/Musify
 */

// Package imports:
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
// Flutter imports:
import 'package:flutter/material.dart';
// Project imports:
import 'package:musify/API/musify.dart';
import 'package:musify/extensions/l10n.dart';
import 'package:musify/main.dart';
import 'package:musify/services/router_service.dart';
import 'package:musify/utilities/common_variables.dart';
import 'package:musify/utilities/flutter_toast.dart';
import 'package:musify/utilities/utils.dart';
import 'package:musify/widgets/confirmation_dialog.dart';
import 'package:musify/widgets/playlist_bar.dart';
import 'package:musify/widgets/section_title.dart';
import 'package:musify/widgets/spinner.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late Future<List> _userPlaylistsFuture = getUserPlaylists();

  Future<void> _refreshUserPlaylists() async {
    setState(() {
      _userPlaylistsFuture = getUserPlaylists();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n!.library)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _buildUserPlaylistsSection(primaryColor),
                  _buildUserLikedPlaylistsSection(primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPlaylistsSection(Color primaryColor) {
    final isUserPlaylistsEmpty = userPlaylists.isEmpty && userCustomPlaylists.isEmpty;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionTitle(context.l10n!.userPlaylists, primaryColor),
            IconButton(
              padding: const EdgeInsets.only(right: 10),
              onPressed: _showAddPlaylistDialog,
              icon: Icon(
                FluentIcons.add_24_filled,
                color: primaryColor,
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            PlaylistBar(
              context.l10n!.recentlyPlayed,
              onPressed: () => NavigationManager.router.go('/library/userSongs/recents'),
              cubeIcon: FluentIcons.history_24_filled,
              borderRadius: commonCustomBarRadiusFirst,
              showBuildActions: false,
            ),
            PlaylistBar(
              context.l10n!.likedSongs,
              onPressed: () => NavigationManager.router.go('/library/userSongs/liked'),
              cubeIcon: FluentIcons.music_note_2_24_regular,
              showBuildActions: false,
            ),
            PlaylistBar(
              context.l10n!.offlineSongs,
              onPressed: () => NavigationManager.router.go('/library/userSongs/offline'),
              cubeIcon: FluentIcons.cellular_off_24_filled,
              borderRadius: isUserPlaylistsEmpty ? commonCustomBarRadiusLast : BorderRadius.zero,
              showBuildActions: false,
            ),
          ],
        ),
        FutureBuilder<List>(
          future: _userPlaylistsFuture,
          builder: _buildPlaylistsList,
        ),
      ],
    );
  }

  Widget _buildUserLikedPlaylistsSection(Color primaryColor) {
    return ValueListenableBuilder(
      valueListenable: currentLikedPlaylistsLength,
      builder: (_, value, __) {
        return userLikedPlaylists.isNotEmpty
            ? Column(
                children: [
                  SectionTitle(
                    context.l10n!.likedPlaylists,
                    primaryColor,
                  ),
                  _buildPlaylistListView(context, userLikedPlaylists),
                ],
              )
            : const SizedBox();
      },
    );
  }

  Widget _buildPlaylistsList(
    BuildContext context,
    AsyncSnapshot<List> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Spinner();
    } else if (snapshot.hasError) {
      return _handleSnapshotError(context, snapshot);
    }

    return _buildPlaylistListView(context, snapshot.data!);
  }

  Widget _handleSnapshotError(
    BuildContext context,
    AsyncSnapshot<List> snapshot,
  ) {
    logger.log(
      'Error while fetching playlists',
      snapshot.error,
      snapshot.stackTrace,
    );
    return Center(child: Text(context.l10n!.error));
  }

  Widget _buildPlaylistListView(BuildContext context, List playlists) {
    final isUserPlaylists = playlists.isNotEmpty && (playlists[0]['source'] == 'user-created' || playlists[0]['source'] == 'user-youtube');
    final _length = playlists.length + (isUserPlaylists ? 3 : 0);
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: playlists.length,
      padding: commonListViewBottmomPadding,
      itemBuilder: (BuildContext context, index) {
        final playlist = playlists[index];
        final _index = index + (isUserPlaylists ? 3 : 0);
        final borderRadius = getItemBorderRadius(_index, _length);
        return PlaylistBar(
          key: ValueKey(playlist['ytid']),
          playlist['title'],
          playlistId: playlist['ytid'],
          playlistArtwork: playlist['image'],
          isAlbum: playlist['isAlbum'],
          playlistData: playlist['source'] == 'user-created' ? playlist : null,
          onDelete: playlist['source'] == 'user-created' || playlist['source'] == 'user-youtube' ? () => _showRemovePlaylistDialog(playlist) : null,
          borderRadius: borderRadius,
        );
      },
    );
  }

  void _showAddPlaylistDialog() => showDialog(
        context: context,
        builder: (BuildContext context) {
          var id = '';
          var customPlaylistName = '';
          var isYouTubeMode = true;
          String? imageUrl;

          return StatefulBuilder(
            builder: (context, setState) {
              final theme = Theme.of(context);
              final activeButtonBackground = theme.colorScheme.surfaceContainer;
              final inactiveButtonBackground = theme.colorScheme.secondaryContainer;
              final dialogBackgroundColor = theme.dialogBackgroundColor;

              return AlertDialog(
                backgroundColor: dialogBackgroundColor,
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isYouTubeMode = true;
                                id = '';
                                customPlaylistName = '';
                                imageUrl = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isYouTubeMode ? inactiveButtonBackground : activeButtonBackground,
                            ),
                            child: const Icon(
                              FluentIcons.globe_add_24_filled,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isYouTubeMode = false;
                                id = '';
                                customPlaylistName = '';
                                imageUrl = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isYouTubeMode ? activeButtonBackground : inactiveButtonBackground,
                            ),
                            child: const Icon(
                              FluentIcons.person_add_24_filled,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (isYouTubeMode)
                        TextField(
                          decoration: InputDecoration(
                            labelText: context.l10n!.youtubePlaylistLinkOrId,
                          ),
                          onChanged: (value) {
                            id = value;
                          },
                        )
                      else ...[
                        TextField(
                          decoration: InputDecoration(
                            labelText: context.l10n!.customPlaylistName,
                          ),
                          onChanged: (value) {
                            customPlaylistName = value;
                          },
                        ),
                        const SizedBox(height: 7),
                        TextField(
                          decoration: InputDecoration(
                            labelText: context.l10n!.customPlaylistImgUrl,
                          ),
                          onChanged: (value) {
                            imageUrl = value;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      context.l10n!.add.toUpperCase(),
                    ),
                    onPressed: () async {
                      if (isYouTubeMode && id.isNotEmpty) {
                        showToast(
                          context,
                          await addUserPlaylist(
                            id,
                            context,
                          ),
                        );
                      } else if (!isYouTubeMode && customPlaylistName.isNotEmpty) {
                        showToast(
                          context,
                          createCustomPlaylist(
                            customPlaylistName,
                            imageUrl,
                            context,
                          ),
                        );
                      } else {
                        showToast(
                          context,
                          '${context.l10n!.provideIdOrNameError}.',
                        );
                      }

                      Navigator.pop(context);

                      await _refreshUserPlaylists();
                    },
                  ),
                ],
              );
            },
          );
        },
      );

  void _showRemovePlaylistDialog(Map playlist) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmationDialog(
            confirmationMessage: context.l10n!.removePlaylistQuestion,
            submitMessage: context.l10n!.remove,
            onCancel: () {
              Navigator.of(context).pop();
            },
            onSubmit: () {
              Navigator.of(context).pop();

              if (playlist['ytid'] == null && playlist['source'] == 'user-created') {
                removeUserCustomPlaylist(playlist);
              } else {
                removeUserPlaylist(playlist['ytid']);
              }

              _refreshUserPlaylists();
            },
          );
        },
      );
}
