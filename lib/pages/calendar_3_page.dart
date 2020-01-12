import 'dart:collection';
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalendar/kalendar.dart';
import 'package:sharing_codelab/model/chalange.dart';
import 'package:sharing_codelab/model/chalanges.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/pages/trip_list_page.dart';
import 'package:sharing_codelab/pages/list_of_chalanges.dart';

class Calendar3Page extends StatefulWidget {
  @override
  _CustomizedCalendarState createState() => _CustomizedCalendarState();
}

class _CustomizedCalendarState extends State<Calendar3Page> {
  var _events = Map<String, List<String>>();
  final _selectedDates = HashSet<String>();





  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<PhotosLibraryApiModel>(
        builder: (context, child, apiModel) {
    return new Scaffold(
        body: Container(
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
            children:
              apiModel.mChallange.idToChallengesMap.values.map((x)=>
              RaisedButton ( child: Text(x.text), )).toList(),
          /*  <Widget>[RaisedButton(
                onPressed: () {
                  _selectedDates.forEach((date) {
                    if (_events[date] == null) {
                      _events[date] = [];
                    }
                    debugPrint('pressed me');
                    _events[date].add(apiModel.mIssues.idToIssueMap.values.first.text);
                  });

                  setState(() {});
                },
                child: Text(apiModel.mIssues.idToIssueMap.values.first.text),
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
            ],*/
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
                  await apiModel.signIn()
                      ? _navigateToTripList(context)
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

  void _navigateToTripList(BuildContext context) {
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