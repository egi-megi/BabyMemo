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

import 'dart:collection';
import 'dart:io';
import 'package:semaphore/lock.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/model/chalange.dart';
import 'package:sharing_codelab/model/chalanges.dart';
import 'package:sharing_codelab/photos_library_api/album.dart';
import 'package:sharing_codelab/photos_library_api/batch_create_media_items_request.dart';
import 'package:sharing_codelab/photos_library_api/batch_create_media_items_response.dart';
import 'package:sharing_codelab/photos_library_api/create_album_request.dart';
import 'package:sharing_codelab/photos_library_api/join_shared_album_request.dart';
import 'package:sharing_codelab/photos_library_api/get_album_request.dart';
import 'package:sharing_codelab/photos_library_api/join_shared_album_response.dart';
import 'package:sharing_codelab/photos_library_api/list_albums_response.dart';
import 'package:sharing_codelab/photos_library_api/list_shared_albums_response.dart';
import 'package:sharing_codelab/photos_library_api/photos_library_api_client.dart';
import 'package:sharing_codelab/photos_library_api/search_media_items_request.dart';
import 'package:sharing_codelab/photos_library_api/search_media_items_response.dart';
import 'package:sharing_codelab/photos_library_api/share_album_request.dart';
import 'package:sharing_codelab/photos_library_api/share_album_response.dart';

import 'google_http_clent.dart';

class PhotosLibraryApiModel extends Model {
  static const  ALBUM_NAME="first2years";

  PhotosLibraryApiModel(mIssues) {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      _currentUser = account;
      notifyListeners();

    });
    this.mChallanges=mIssues;
  }

  Challenges mChallanges;

  final LinkedHashSet<Album> _albums = LinkedHashSet<Album>();
  Album _twoFirstYears=null;
  bool hasAlbums = false;
  PhotosLibraryApiClient client;
  CalendarApi calendarClient;

  GoogleSignInAccount _currentUser;


  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
    'profile',
    'https://www.googleapis.com/auth/photoslibrary',
    'https://www.googleapis.com/auth/photoslibrary.sharing',
    'https://www.googleapis.com/auth/calendar',
  ]);
  GoogleSignInAccount get user => _currentUser;

  Lock loading=new Lock();

  Future<bool> isLoggedInAndLoaded() async {
    loading.acquire();
    loading.release();
    return _currentUser != null;
  }

  bool isLoggedIn()  {
    return _currentUser != null && client!=null;
  }

  Future<bool> signIn() async {
    loading.acquire();
    await _googleSignIn.signIn();
    if (_currentUser == null) {
      // User could not be signed in
      loading.release();
      return false;
    }

    client = PhotosLibraryApiClient(_currentUser.authHeaders);
    final authHeaders = _currentUser.authHeaders;
    // custom IOClient from below
    final httpClient = GoogleHttpClient(await authHeaders);
    calendarClient=new CalendarApi(httpClient);
    if (false) { //calendar not exists
      Calendar c = new Calendar();

      c.description = "babby memo description";
      c.summary = "test baby memo";
      calendarClient.calendars.insert(c);
    }
    _updateAlbumsAndReleaseLoading();
    return true;
  }

  void _updateAlbumsAndReleaseLoading() async {
    await updateAlbums();
    loading.release();
  }


  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    client = null;
  }

  Future<void> signInSilently() async {
    await _googleSignIn.signInSilently();
    if (_currentUser == null) {
      // User could not be signed in
      return;
    }
    client = PhotosLibraryApiClient(_currentUser.authHeaders);
    updateAlbums();
  }

  Future<Album> createAlbum(String title) async {
    return client
        .createAlbum(CreateAlbumRequest.fromTitle(title))
        .then((Album album) {
      updateAlbums();
      return album;
    });
  }

  Future<Album> getAlbum(String id) async {
    return client
        .getAlbum(GetAlbumRequest.defaultOptions(id))
        .then((Album album) {
      return album;
    });
  }

  Future<JoinSharedAlbumResponse> joinSharedAlbum(String shareToken) {
    return client
        .joinSharedAlbum(JoinSharedAlbumRequest(shareToken))
        .then((JoinSharedAlbumResponse response) {
      updateAlbums();
      return response;
    });
  }

  Future<ShareAlbumResponse> shareAlbum(String id) async {
    return client
        .shareAlbum(ShareAlbumRequest.defaultOptions(id))
        .then((ShareAlbumResponse response) {
      updateAlbums();
      return response;
    });
  }

  Future<SearchMediaItemsResponse> searchMediaItems(String albumId) async {
    return client
        .searchMediaItems(SearchMediaItemsRequest.albumId(albumId))
        .then((SearchMediaItemsResponse response) {
      return response;
    });
  }

  Future<String> uploadMediaItem(File image) {
    return client.uploadMediaItem(image);
  }

  Future<BatchCreateMediaItemsResponse> createMediaItem(
      String uploadToken,  String description) {
    // Construct the request with the token, albumId and description.
    final BatchCreateMediaItemsRequest request =
    BatchCreateMediaItemsRequest.inAlbum(uploadToken, _twoFirstYears.id , description);

    // Make the API call to create the media item. The response contains a
    // media item.
    return client
        .batchCreateMediaItems(request)
        .then((BatchCreateMediaItemsResponse response) {
      // Print and return the response.
      print(response.newMediaItemResults[0].toJson());
      return response;
    });
  }

  UnmodifiableListView<Album> get albums =>
      UnmodifiableListView<Album>(_albums ?? <Album>[]);

  void updateAlbums() async {
    // Reset the flag before loading new albums
    hasAlbums = false;
    // Clear all albums
    _albums.clear();
    // Add albums from the user's Google Photos account
    // var ownedAlbums = await _loadAlbums();
    // if (ownedAlbums != null) {
    //   _albums.addAll(ownedAlbums);
    // }

    // Load albums from owned and shared albums
    final List<List<Album>> list =
    await Future.wait([_loadSharedAlbums(), _loadAlbums()]);

    _albums.addAll(list.expand((a) => a ?? []));

    notifyListeners();
    print("albums updated");

    // find your album
    _twoFirstYears=_albums.firstWhere((a)=>a.title==ALBUM_NAME, orElse:()=> null);
    if (_twoFirstYears==null) {
      //create album
      _twoFirstYears=await createAlbum(ALBUM_NAME);
    }
   // and fix challenges

    await searchMediaItems(_twoFirstYears.id).then((item)=>{
      if (item!=null && item.mediaItems!=null){
        item.mediaItems.forEach((mi) =>
        {
          if (mChallanges.idToChallengesMap.containsKey(
              Challenge.findIdFromDescription(mi.description))){
            mChallanges.idToChallengesMap[(Challenge.findIdFromDescription(
                mi.description))]
                .date = (Challenge.findDateFromDescription(mi.description))
          }
        })
      }
    });


    hasAlbums = true;

  }




  /// Load Albums into the model by retrieving the list of all albums shared
  /// with the user.
  Future<List<Album>> _loadSharedAlbums() {
    return client.listSharedAlbums().then(
      (ListSharedAlbumsResponse response) {
        return response.sharedAlbums;
      },
    );
  }

  /// Load albums into the model by retrieving the list of all albums owned
  /// by the user.
  Future<List<Album>> _loadAlbums() {
    return client.listAlbums().then(
      (ListAlbumsResponse response) {
        return response.albums;
      },
    );
  }
}
