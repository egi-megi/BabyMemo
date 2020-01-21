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

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/components/contribute_photo_dialog.dart';
import 'package:sharing_codelab/components/primary_raised_button.dart';
import 'package:sharing_codelab/model/challenge.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/photos_library_api/album.dart';
import 'package:sharing_codelab/photos_library_api/batch_create_media_items_response.dart';
import 'package:sharing_codelab/photos_library_api/media_item.dart';
import 'package:sharing_codelab/photos_library_api/search_media_items_response.dart';
import 'package:sharing_codelab/components/baby_memo_app_bar.dart';
import 'package:sharing_codelab/util/to_be_implemented.dart';
import 'package:sharing_codelab/model/challenge.dart';
import 'package:image_picker/image_picker.dart';


class SingleChallengePage extends StatefulWidget {
  const SingleChallengePage({Key key, this.searchResponse, this.challenge})
      : super(key: key);

  final Future<SearchMediaItemsResponse> searchResponse;

  final Challenge challenge;

  @override
  State<StatefulWidget> createState() =>
      _SingleChallengeState(
          searchResponse: searchResponse, challenge: challenge);
}

class _SingleChallengeState extends State<SingleChallengePage> {
  _SingleChallengeState({this.searchResponse, this.challenge});

  File _image;
  String _uploadToken;
  DateTime _adddate=DateTime.now();
  bool _isUploading = false;
  Future<SearchMediaItemsResponse> searchResponse;

  Challenge challenge;


  bool _inSharingApiCall = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BabyMemoAppBar(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ScopedModelDescendant<PhotosLibraryApiModel>(
        builder: (context, child, photosLibraryApi) {
          return new Scaffold(
              body: Container(
                padding: const EdgeInsets.all(14),
                child: SingleChildScrollView(
                  child: Column(
                    children:
                    (challenge.date != null && challenge.mi != null) ?
                    <Widget>[ Text(
                      challenge.text,
                    ),
                      Text("${challenge.date.year}-${challenge.date
                          .month}-${challenge.date.day}  "),
                      Text(
                        challenge.longerDescription,
                      ),


                      CachedNetworkImage(
                        imageUrl: '${challenge.mi.baseUrl}=w364',
                        placeholder: (BuildContext context, String url) =>
                        const CircularProgressIndicator(),
                        errorWidget: (BuildContext context, String url,
                            Object error) {
                          print(error);
                          return const Icon(Icons.error);
                        },
                      ),
                    ] :
                    <Widget>[
                      _buildUploadButton(context),
                      Text(
                        challenge.text,
                      ),
                      Align(
                        child: _buildAddButton(context),
                        alignment: const FractionalOffset(1, 0),
                      )
                    ],
                  ),

                ),
              )
          );
        }
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    if (_image != null) {
      // An image has been selected, display it in the dialog
      return Container(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.file(_image),
              _isUploading ? const LinearProgressIndicator() : Container(),
              FutureBuilder<SearchMediaItemsResponse>(
                future: searchResponse,
                builder: _buildMediaItemList,
              )
            ],
          ),
        ),
      );
    }

    // TODO(developer): Implement error display

    // No image has been selected yet
    return Container(
      padding: const EdgeInsets.all(12),
      child: FlatButton.icon(
        onPressed: () => _getImage(context),
        label: const Text('UPLOAD PHOTO'),
        textColor: Colors.green[800],
        icon: const Icon(Icons.file_upload),
      ),
    );
  }

  /*Future<void> _shareAlbum(BuildContext context) async {
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
  }*/

  Widget _buildAddButton(BuildContext context) {
    if (_image == null) {
      // No image has been selected yet
      return const RaisedButton(
        child: Text('ADD'),
        onPressed: null,
      );
    }

    if (_uploadToken == null) {
      // Upload has not completed yet
      return const RaisedButton(
        child: Text('Waiting for image upload'),
        onPressed: null,
      );
    }
    if (_adddate==null) {
      _adddate=DateTime.now();
    }
    // Otherwise, the upload has completed and an upload token is set
    return Column (
        children: [
          RaisedButton(
              child: Text("${_adddate.year}-${_adddate
                  .month}-${_adddate.day}  "),
              onPressed: () {
                Future<DateTime> selectedDate = showDatePicker(
                    context: context,
                    initialDate: _adddate,
                    firstDate: DateTime(2018),
                    lastDate: DateTime(2030),
                    builder: (BuildContext context, Widget child) {
                      return Theme(
                        data: ThemeData.dark(),
                        child: child,
                      );
                    });
                selectedDate.then((date) {
                  _adddate=date;
               });}),
        RaisedButton(
      child: const Text('ADD'),
      onPressed: () =>
          Navigator.pop(
              context,
              _contributePhoto(context)),
      /*ContributePhotoResult(
          _uploadToken,
          challenge.getDescription(),
        ),*/
    )]);
    //);
  }

  Future _getImage(BuildContext context) async {
// Use the image_picker package to prompt the user for a photo from their
    // device.
    final File image = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );

    // Store the image that was selected.
    setState(() {
      _image = image;
      _isUploading = true;
    });

    // Make a request to upload the image to Google Photos once it was selected.
    final String uploadToken =
    await ScopedModel.of<PhotosLibraryApiModel>(context)
        .uploadMediaItem(image);

    setState(() {
      // Once the upload process has completed, store the upload token.
      // This token is used together with the description to create the media
      // item later.
      _uploadToken = uploadToken;
      _isUploading = false;
    });
  }

  void _contributePhoto(BuildContext context) {
    challenge.date = _adddate;
    setState(() {
      searchResponse =
          (ScopedModel.of<PhotosLibraryApiModel>(context)
              .createMediaItem(_uploadToken, challenge.getDescription())
          ).then((BatchCreateMediaItemsResponse response) {
            return ScopedModel.of<PhotosLibraryApiModel>(context)
                .searchMediaItems();
          });
    });
  }

  /*Widget _buildShareButtons(BuildContext context) {
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
  }*/

  Widget _buildMediaItemList(BuildContext context,
      AsyncSnapshot<SearchMediaItemsResponse> snapshot) {
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
