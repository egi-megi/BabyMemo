/*
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/components/contribute_photo_dialog.dart';
import 'package:sharing_codelab/components/primary_raised_button.dart';
import 'package:sharing_codelab/model/chalange.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/photos_library_api/album.dart';
import 'package:sharing_codelab/photos_library_api/batch_create_media_items_response.dart';
import 'package:sharing_codelab/photos_library_api/media_item.dart';
import 'package:sharing_codelab/photos_library_api/search_media_items_response.dart';
import 'package:sharing_codelab/util/to_be_implemented.dart';

class SingleChallangePage extends StatefulWidget {
  const SingleChallangePage({Key key, this.searchResponse}) : super(key: key);

  final Future<SearchMediaItemsResponse> searchResponse;



  @override
  State<StatefulWidget> createState() =>
      _SingleChallengeState(searchResponse: searchResponse);
}

class _SingleChallengeState extends State<SingleChallangePage> {
  _SingleChallengeState({this.searchResponse});

  Future<SearchMediaItemsResponse> searchResponse;
  Challenge challenge;


  bool _inSharingApiCall = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
      ),
      body: Builder(builder: (BuildContext context) {
        return Column(
          children: <Widget>[
            Container(
              width: 370,
              child: Text(
                album.title ?? '[no title]',
                style: TextStyle(
                  fontSize: 36,
                ),
              ),
            ),
            _buildShareButtons(context),
            Container(
              width: 348,
              margin: const EdgeInsets.only(bottom: 32),
              child: PrimaryRaisedButton(
                label: const Text('ADD PHOTO'),
                onPressed: () => _contributePhoto(context),
              ),
            ),
            FutureBuilder<SearchMediaItemsResponse>(
              future: searchResponse,
              builder: _buildMediaItemList,
            )
          ],
        );
      }),
    );
  }

  Future<void> _shareAlbum(BuildContext context) async {
// Show the loading indicator
    setState(() {
      _inSharingApiCall = true;
    });
    final SnackBar snackBar = SnackBar(
      duration: Duration(seconds: 3),
      content: const Text('Sharing Album...'),
    );
    Scaffold.of(context).showSnackBar(snackBar);
    // Share the album and update the local model
    await ScopedModel.of<PhotosLibraryApiModel>(context).shareAlbum(album.id);
    final Album updatedAlbum =
    await ScopedModel.of<PhotosLibraryApiModel>(context).getAlbum(album.id);
    print('Album has been shared.');
    setState(() {
      album = updatedAlbum;
      // Hide the loading indicator
      _inSharingApiCall = false;
    });
  }

  void _showShareableUrl(BuildContext context) {
    if (album.shareInfo == null || album.shareInfo.shareableUrl == null) {
      print('Not shared, sharing album first.');
      // Album is not shared yet, share it first, then display dialog
      _shareAlbum(context).then((_) {
        _showUrlDialog(context);
      });
    } else {
      // Album is already shared, display dialog with URL
      _showUrlDialog(context);
    }
  }

  void _showShareToken(BuildContext context) {
    if (album.shareInfo == null) {
      print("Not shared, sharing album first.");
      // Album is not shared yet, share it first, then display dialog
      _shareAlbum(context).then((_) {
        _showTokenDialog(context);
      });
    } else {
      // Album is already shared, display dialog with token
      _showTokenDialog(context);
    }
  }

  void _showTokenDialog(BuildContext context) {
    print('This is the shareToken:\n${album.shareInfo.shareToken}');

    _showShareDialog(
        context, 'Use this token to share', album.shareInfo.shareToken);
  }

  void _showUrlDialog(BuildContext context) {
    print('This is the shareableUrl:\n${album.shareInfo.shareableUrl}');

    _showShareDialog(
        context,
        'Share this URL with anyone. '
            'Anyone with this URL can access all items.',
        album.shareInfo.shareableUrl);
  }

  void _showShareDialog(BuildContext context, String title, String text) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Row(
              children: [
                Flexible(
                  child: Text(
                    text,
                  ),
                ),
                FlatButton(
                  child: const Text('Copy'),
                  onPressed: () => Clipboard.setData(ClipboardData(text: text)),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _contributePhoto(BuildContext context) {
    setState(() {
      searchResponse = showDialog<ContributePhotoResult>(
          context: context,
          builder: (BuildContext context) {
            return ContributePhotoDialog();
          }).then((ContributePhotoResult result) {

            return ScopedModel.of<PhotosLibraryApiModel>(context)
            .createMediaItem(result.uploadToken, /*description from challenge here*/result.description);
      }).then((BatchCreateMediaItemsResponse response) {
        return ScopedModel.of<PhotosLibraryApiModel>(context)
            .searchMediaItems(album.id);
      });
    });
  }

  Widget _buildShareButtons(BuildContext context) {
    if (_inSharingApiCall) {
      return const CircularProgressIndicator();
    }

    return Column(children: <Widget>[
      Container(
        width: 254,
        child: FlatButton(
          onPressed: () => _showShareableUrl(context),
          textColor: Colors.green[800],
          child: const Text('SHARE WITH ANYONE'),
        ),
      ),
      Container(
        width: 254,
        child: FlatButton(
          onPressed: () => _showShareToken(context),
          textColor: Colors.green[800],
          child: const Text('SHARE IN FIELD TRIPPA'),
        ),
      ),
    ]);
  }

  Widget _buildMediaItemList(
      BuildContext context, AsyncSnapshot<SearchMediaItemsResponse> snapshot) {
    if (snapshot.hasData) {
      if (snapshot.data.mediaItems == null) {
        return Container();
      }

      return Expanded(
        child: ListView.builder(
          itemCount: snapshot.data.mediaItems.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildMediaItem(snapshot.data.mediaItems[index]);
          },
        ),
      );
    }

    if (snapshot.hasError) {
      print(snapshot.error);
      return Container();
    }

    return Center(
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildMediaItem(MediaItem mediaItem) {
    return Column(
      children: <Widget>[
        Center(
          child: CachedNetworkImage(
            imageUrl: '${mediaItem.baseUrl}=w364',
            placeholder: (BuildContext context, String url) =>
            const CircularProgressIndicator(),
            errorWidget: (BuildContext context, String url, Object error) {
              print(error);
              return const Icon(Icons.error);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 2),
          width: 364,
          child: Text(
            mediaItem.description ?? '',
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}

class ContributePhotoResult {
  ContributePhotoResult(this.uploadToken, this.description);

  String uploadToken;
  String description;
}
