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
import 'package:flutter_svg/svg.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/model/challenge.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/pages/create_trip_page.dart';
import 'package:sharing_codelab/pages/join_trip_page.dart';
import 'package:sharing_codelab/components/primary_raised_button.dart';
import 'package:sharing_codelab/components/baby_memo_app_bar.dart';
import 'package:sharing_codelab/pages/trip_page.dart';
import 'package:sharing_codelab/pages/upload_challenge.dart';
import 'package:sharing_codelab/pages/calendar_3_page.dart';
import 'package:sharing_codelab/photos_library_api/album.dart';
import 'package:sharing_codelab/util/to_be_implemented.dart';

import 'dart:collection';
import 'package:kalendar/kalendar.dart';

class ChalangesListPage extends StatefulWidget {
  @override
  _CustomizedChalangesListState createState() =>
      _CustomizedChalangesListState();
}

class _CustomizedChalangesListState extends State<ChalangesListPage> {
  var _events = Map<String, List<String>>();
  final _selectedDates = HashSet<String>();
  bool _isLoading = false;

  //Challenge challenge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BabyMemoAppBar(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ScopedModelDescendant<PhotosLibraryApiModel>(
        builder: (context, child, photosLibraryApi)
    {
      return new Scaffold(
          body: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ListView(
                //alignment: WrapAlignment.center,
                //spacing: 16,
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                children: photosLibraryApi.mChallanges
                    .getUnHappened()
                    .map((x) =>
                    ButtonTheme(
                        minWidth: MediaQuery
                            .of(context)
                            .size
                            .width,
                        //height: 100.0,
                        buttonColor: Colors.indigo,
                        child: RaisedButton(
                          padding: EdgeInsets.all(0),
                          child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    color: Colors.indigo[50],
                                    padding: new EdgeInsets.all(8.0),
                                    child: new Text(
                                      x.title,
                                      style: new TextStyle(
                                        fontSize: 17.0,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    color: Colors.white,
                                    padding: new EdgeInsets.all(8.0),
                                    child: new Text(
                                      x.longerDescription,
                                      textAlign: TextAlign.left,
                                      style: new TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.indigo,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 8,
                                  child: Container(
                                    color: Colors.indigoAccent,
                                    padding: new EdgeInsets.all(8.0),
                                  ),
                                ),
                              ]),
                          onPressed: () =>
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      UploadChallengePage(
                                        challenge: x,
                                        searchResponse:
                                        photosLibraryApi.searchMediaItems(),
                                      ),
                                ),
                              ),
                        )))
                    .toList(),

              )
          )
      );
    }
    );
  }

  void _showSignInError(BuildContext context) {
    final SnackBar snackBar = SnackBar(
      duration: Duration(seconds: 3),
      content: const Text('Could not sign in.\n'
          'Is the Google Services file missing?'),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }



}

class CustomDayTile extends StatelessWidget {
  final DayProps props;

  CustomDayTile(this.props);

  @override
  Widget build(BuildContext context) {
    if (props.events != null && props.events[0] == 'Holiday') {
      return Container(
        color: Colors.red,
        child: Center(
          child: Text(
            '${props.dateTime.day}',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (props.events != null && props.events[0] == 'Blackday') {
      return Container(
        color: Colors.black,
        child: Center(
          child: Text(
            '${props.dateTime.day}',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(props.dayTileMargin ?? 3),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor
            // width: 1,
            // color: props.dayTileBorderColor ?? Colors.grey,
            ),
        // borderRadius: BorderRadius.circular(props.borderRadius),
        color: props.isSelected ? Colors.green : Colors.transparent,
      ),
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment:
                props.events != null && props.events[0] == 'Tennis'
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                '${props.dateTime.day}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: props.isDayOfCurrentMonth
                      ? Colors.black87
                      : props.isSelected ? Colors.white54 : Colors.grey,
                ),
              ),
            ],
          ),
          _EventMark(props.events),
        ],
      ),
    );
  }
}

class _EventMark extends StatelessWidget {
  final List<String> events;

  _EventMark(this.events);

  @override
  Widget build(BuildContext context) {
    if (events == null) {
      return Container();
    }

    if (events[0] == 'Wedding') {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(2),
          padding: EdgeInsets.all(2),
          color: Colors.purple,
          child: Text('Wedding',
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(color: Colors.white, fontSize: 11)),
        ),
      );
    }

    if (events[0] == 'Dentist') {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(2),
          padding: EdgeInsets.all(2),
          color: Colors.deepOrange,
          child: Text('Dentist',
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(color: Colors.white, fontSize: 11)),
        ),
      );
    }

    if (events[0] == 'Tennis') {
      return Container(
        margin: EdgeInsets.all(2),
        padding: EdgeInsets.all(2),
        child: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/c/c3/P_tennis.png',
          width: 40,
        ),
      );
    }

    if (events[0] == 'Interview') {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(2),
          padding: EdgeInsets.all(2),
          color: Colors.black,
          child: Text('Interview',
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(color: Colors.white, fontSize: 11)),
        ),
      );
    }

    return Container();
  }
}
