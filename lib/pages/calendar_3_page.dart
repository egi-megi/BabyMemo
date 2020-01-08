import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kalendar/kalendar.dart';
import 'package:sharing_codelab/model/question.dart';

class Calendar3Page extends StatefulWidget {
  @override
  _CustomizedCalendarState createState() => _CustomizedCalendarState();
}

class _CustomizedCalendarState extends State<Calendar3Page> {
  var _events = Map<String, List<String>>();
  final _selectedDates = HashSet<String>();

  /*static String jsonString = '[{"id": "1a", "text": "Pierwszy krok"}]';
  static Map questionMap = jsonDecode(jsonString);
  var question = Question.fromJson(questionMap);*/

  static var jsonData = '{ "id" : "1a", "text" : "Pierwszy krok"  }';
  /*Future<String> loadAsset(BuildContext context) async {
    return await DefaultAssetBundle.of(context).loadString('assets/my_text.txt');
  }
  static var jsonData = loadAsset(context);*/
  static var questionParsedJson = json.decode(jsonData);
  var question = Question(questionParsedJson);

  @override
  Widget build(BuildContext context) {
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
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  _selectedDates.forEach((date) {
                    if (_events[date] == null) {
                      _events[date] = [];
                    }
                    debugPrint('pressed me');
                    _events[date].add(question.text);
                  });

                  setState(() {});
                },
                child: Text(question.text),
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
    ));
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