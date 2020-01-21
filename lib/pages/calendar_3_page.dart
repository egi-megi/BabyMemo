import 'dart:collection';

import 'package:collection/collection.dart';
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalendar/kalendar.dart';
import 'package:sharing_codelab/model/challenge.dart';
import 'package:sharing_codelab/model/challenges.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/pages/single_challange_page.dart';
import 'package:sharing_codelab/pages/trip_list_page.dart';
import 'package:sharing_codelab/pages/list_of_chalanges.dart';
import 'package:sharing_codelab/components/baby_memo_app_bar.dart';
import 'package:date_utils/date_utils.dart';

class Calendar3Page extends StatefulWidget {
  @override
  _CustomizedCalendarState createState() => _CustomizedCalendarState();
}

class _CustomizedCalendarState extends State<Calendar3Page> {
  var _events = Map<String, List<String>>();
  final _selectedDates = HashSet<String>();
  Future<bool> _loaded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BabyMemoAppBar(),
      body: _buildBody(context),
    );
  }

  Widget weekBuilder(List<String> weeks) {
    return Container(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: weeks.map((dayOfWeek) {
          return Expanded(
            child: Text(
              dayOfWeek,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.amber),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget _buildBody(BuildContext context) {
    return ScopedModelDescendant<PhotosLibraryApiModel>(
        builder: (context, child, apiModel) {
      _loaded = apiModel.isLoggedInAndLoaded();

      return new Scaffold(
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: <Widget>[
                FutureBuilder(
                    future: _loaded,
                    builder: (BuildContext context, AsyncSnapshot<bool> b) {
                      var map1 = groupBy(apiModel.mChallanges.getAllHappened(),
                          (Challenge mi) => formatDate(mi.date));
                      var map2 = map1.map((k, list) => MapEntry(
                          k,
                          list
                              .map((Challenge mi) => mi.getDescription())
                              .toList()));
                      _events.clear();
                      _events.addAll(map2);

                      return Expanded(
                          child: Kalendar(
                        selectedDates: _selectedDates,
                        markedDates: _events,
                        headerBuilder: (visibleMonth, changeMonth) {
                          return CustomHeader(visibleMonth, onChange: (date) {
                            changeMonth(date);
                          });
                        },
                        weekBuilder: weekBuilder,
                        dayTileMargin: 1,
                        dayTileBuilder: (DayProps props) {
                          return CustomDayTile(props, apiModel);
                        },
                        onTap: (DateTime dateTime, bool isSelected) {
                          debugPrint(dateTime.toIso8601String());
                          debugPrint('$isSelected');
                          setState(() {
                            _selectedDates.clear();
                            _selectedDates.add(formatDate(dateTime));
                          });
                        },
                      ));
                    }),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  children: _selectedDates.isEmpty
                      ? [Container()].toList()
                      : apiModel.mChallanges
                          .getHappened(DateTime.parse(_selectedDates.first))
                          .map((x) => RaisedButton(
                              child: new Text(
                                x.text,
                                style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.indigo,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        SingleChallengePage(
                                      challenge: x,
                                      searchResponse:
                                          apiModel.searchMediaItems(),
                                    ),
                                  ),
                                );
                              }))
                          .toList(),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Text(_selectedDates.toString()),
                  ),
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ChalangesListPage(),
              ),
            ),
            child: new Text(
              "+",
              style: new TextStyle(
                fontSize: 25.0,
                color: Colors.indigo,
              ),
            ),
            backgroundColor: Colors.white,
          ));
    });
  }

  void _showSignInError(BuildContext context) {
    final SnackBar snackBar = SnackBar(
      duration: Duration(seconds: 3),
      content: const Text('Could not sign in.\n'
          'Is the Google Services file missing?'),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _navigateToChallangeList(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ChalangesListPage(),
      ),
    );
  }
}

class CustomDayTile extends StatelessWidget {
  final DayProps props;
  final PhotosLibraryApiModel apiModel;

  CustomDayTile(this.props, this.apiModel);

  @override
  Widget build(BuildContext context) {

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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                '${props.dateTime.day}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: props.isDayOfCurrentMonth
                      ? Colors.white
                      : props.isSelected ? Colors.white54 : Colors.grey,
                ),
              ),
            ],
          ),
          _EventMark(props.events, apiModel),
        ],
      ),
    );
  }
}

class _EventMark extends StatelessWidget {
  final List<String> events;
  final PhotosLibraryApiModel apiModel;

  _EventMark(this.events, this.apiModel);

  @override
  Widget build(BuildContext context) {
    if (events == null) {
      return Container();
    }
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(2),
          padding: EdgeInsets.all(2),
          color: Colors.amber,
          child: Column(
              children: events
                  .map(
                    (desc) => Text(
                        apiModel
                            .mChallanges
                            .idToChallengesMap[
                                Challenge.findIdFromDescription(desc)]
                            .text,
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            .copyWith(color: Colors.white, fontSize: 11)),
                  )
                  .toList()),
        ));

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

class CustomHeader extends StatelessWidget {
  final DateTime visibleMonth;
  final Function onChange;

  CustomHeader(this.visibleMonth, {this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              onChange(Utils.previousMonth(visibleMonth));
            },
          ),
          Text(
            '${Utils.formatMonth(visibleMonth)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              onChange(Utils.nextMonth(visibleMonth));
            },
          ),
        ],
      ),
    );
  }
}
