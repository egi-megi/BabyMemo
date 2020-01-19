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


  @override
  Widget _buildBody(BuildContext context) {
    return ScopedModelDescendant<PhotosLibraryApiModel>(
        builder: (context, child, apiModel)
    {
      _loaded=apiModel.isLoggedInAndLoaded();

      return new


      Scaffold(
      body: Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child:  Column(
        children: <Widget>[
          FutureBuilder(  future: _loaded,
      builder : (BuildContext context, AsyncSnapshot<bool> b) {
            var map1=groupBy(apiModel.mChallanges.getAllHappened(), (Challenge mi)=>formatDate(mi.date));
            var map2=map1.map((k, list)=> MapEntry(k, list.map((Challenge mi)=>mi.getDescription()).toList()));
          _events.clear();
          _events.addAll(map2);

            return
          Expanded(
            child: Kalendar(
              selectedDates: _selectedDates,
              markedDates: _events,
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
            )
          );
    })
      ,
      Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      children:
      _selectedDates.isEmpty?[Container()].toList():apiModel.mChallanges.getHappened(DateTime.parse(_selectedDates.first)).map((x)=>
      RaisedButton ( child: Text(x.text),
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
            }
      )).toList(),
      ),
       Center(
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Text(_selectedDates.toString()),
      ),
      )
      ],
      ),
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: () async {
      try {
      (await apiModel.isLoggedInAndLoaded())
      ? _navigateToChallangeList(context)
          : _showSignInError(context);
      } on Exception catch (error) {
      print(error);
      _showSignInError(context);
      }

      },
      child: Text("+"),
      backgroundColor: Colors.deepPurpleAccent,
      )
      );
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
          color: Colors.purple,
          child: Column (
            children: events.map(
                (desc)=>
                  Text(apiModel.mChallanges.idToChallengesMap[Challenge.findIdFromDescription(desc)].text,
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: Colors.white, fontSize: 11)),

                ).toList()
        ),
      )
    );


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