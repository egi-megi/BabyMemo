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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/pages/create_trip_page.dart';
import 'package:sharing_codelab/pages/join_trip_page.dart';
import 'package:sharing_codelab/components/primary_raised_button.dart';
import 'package:sharing_codelab/components/baby_memo_app_bar.dart';
import 'package:sharing_codelab/pages/trip_page.dart';
import 'package:sharing_codelab/photos_library_api/album.dart';
import 'package:sharing_codelab/util/to_be_implemented.dart';
import 'package:kalendar/kalendar.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Kalendar(),
    ));
  }
}

    /*
    extends StatefulWidget {
  @override
  _CustomizedCalendarState createState() => _CustomizedCalendarState();
}

class _CustomizedCalendarState extends State<CalendarPage> {
  var _events = Map<String, List<String>>();
  final _selectedDates = HashSet<String>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Kalendar(
              selectedDates: _selectedDates,
              markedDates: _events,
              dayTileMargin: 1,
              dayTileBuilder: (DayProps props) {
                return CustomDayTile(props);
              },
              onTap: (DateTime dateTime, bool isSelected) {
                debugPrint(dateTime.toIso8601String());
                debugPrint('$isSelected');
                setState(() {
                  _selectedDates.clear();
                  _selectedDates.add(formatDate(dateTime));
                });
              },
            ),
          ),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  _selectedDates.forEach((date) {
                    if (_events[date] == null) {
                      _events[date] = [];
                    }
                    debugPrint('pressed me');
                    _events[date].add('Tennis');
                  });

                  setState(() {});
                },
                child: Text('Tennis'),
              ),
              RaisedButton(
                onPressed: () {
                  _selectedDates.forEach((date) {
                    if (_events[date] == null) {
                      _events[date] = [];
                    }

                    _events[date].add('Wedding');
                  });

                  setState(() {});
                },
                child: Text('Wedding'),
              ),
              RaisedButton(
                onPressed: () {
                  _selectedDates.forEach((date) {
                    if (_events[date] == null) {
                      _events[date] = [];
                    }

                    _events[date].add('Dentist');
                  });

                  setState(() {});
                },
                child: Text('Dentist'),
              ),
              RaisedButton(
                onPressed: () {
                  _selectedDates.forEach((date) {
                    if (_events[date] == null) {
                      _events[date] = [];
                    }

                    _events[date].add('Interview');
                  });

                  setState(() {});
                },
                child: Text('Interview'),
              ),
              RaisedButton(
                onPressed: () {
                  _selectedDates.forEach((date) {
                    if (_events[date] == null) {
                      _events[date] = [];
                    }

                    _events[date].add('Blackday');
                  });

                  setState(() {});
                },
                child: Text('Blackday'),
              ),
              RaisedButton(
                onPressed: () {
                  _selectedDates.forEach((date) {
                    if (_events[date] == null) {
                      _events[date] = [];
                    }

                    _events[date].add('Holiday');
                  });

                  setState(() {});
                },
                child: Text('Holiday'),
              ),
            ],
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Text(_selectedDates.toString()),
            ),
          )
        ],
      ),
    );
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
              style: Theme
                  .of(context)
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
              style: Theme
                  .of(context)
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
              style: Theme
                  .of(context)
                  .textTheme
                  .caption
                  .copyWith(color: Colors.white, fontSize: 11)),
        ),
      );
    }

    return Container();
  }*/



/*@override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Kalendar(),
    );
  }*/
//}



 /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BabyMemoAppBar(),
      body: _buildTripList(),
    );
  }

  Widget _buildTripList() {
    return ScopedModelDescendant<PhotosLibraryApiModel>(
      builder: (BuildContext context, Widget child,
          PhotosLibraryApiModel photosLibraryApi) {
        if (!photosLibraryApi.hasAlbums) {
          return Center(
            child: const CircularProgressIndicator(),
          );
        }

        if (photosLibraryApi.albums.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SvgPicture.asset(
                'assets/ic_fieldTrippa.svg',
                color: Colors.grey[300],
                height: 148,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "You're not currently a member of any trip albums. "
                      'Create a new trip album or join an existing one below.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              _buildButtons(context),
            ],
          );
        }

        return ListView.builder(
          itemCount: photosLibraryApi.albums.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return _buildButtons(context);
            }

            return _buildTripCard(
                context, photosLibraryApi.albums[index - 1], photosLibraryApi);
          },
        );
      },
    );
  }

  Widget _buildTripCard(BuildContext context, Album sharedAlbum,
      PhotosLibraryApiModel photosLibraryApi) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 33,
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => TripPage(
              album: sharedAlbum,
              searchResponse:
              photosLibraryApi.searchMediaItems(sharedAlbum.id),
            ),
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              child: _buildTripThumbnail(sharedAlbum),
            ),
            Container(
              height: 52,
              padding: const EdgeInsets.only(left: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                _buildSharedIcon(sharedAlbum),
                Align(
                  alignment: const FractionalOffset(0, 0.5),
                  child: Text(
                    sharedAlbum.title ?? '[no title]',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripThumbnail(Album sharedAlbum) {
    if (sharedAlbum.coverPhotoBaseUrl == null ||
        sharedAlbum.mediaItemsCount == null) {
      return Container(
        height: 160,
        width: 346,
        color: Colors.grey[200],
        padding: const EdgeInsets.all(5),
        child: SvgPicture.asset(
          'assets/ic_fieldTrippa.svg',
          color: Colors.grey[350],
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: '${sharedAlbum.coverPhotoBaseUrl}=w346-h160-c',
      placeholder: (BuildContext context, String url) =>
      const CircularProgressIndicator(),
      errorWidget: (BuildContext context, String url, Object error) {
        print(error);
        return const Icon(Icons.error);
      },
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          PrimaryRaisedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => CreateTripPage(),
                ),
              );
            },
            label: const Text('CREATE A TRIP ALBUM'),
          ),
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              ' - or - ',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FlatButton(
            textColor: Colors.green[800],
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => JoinTripPage(),
                ),
              );
            },
            child: const Text('JOIN A TRIP ALBUM'),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedIcon(Album album) {
    if (album.shareInfo != null) {
      return const Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(
            Icons.folder_shared,
            color: Colors.black38,
          ));
    } else {
      return Container();
    }
  }
}
*/