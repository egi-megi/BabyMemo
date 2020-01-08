import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:kalendar/kalendar.dart';

class Calendar1Page extends StatefulWidget {
  @override
  _CalendarWithMultiSelectState createState() =>
      _CalendarWithMultiSelectState();
}

class _CalendarWithMultiSelectState extends State<Calendar1Page> {
  final _selectedDates = HashSet<String>();
  Map<String, List<String>> _markedDates;

  @override
  void initState() {
    super.initState();
    _markedDates = {
      '2019-04-10': [
        'event1'
      ]
    };
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Kalendar(
              showBorder: true,
              borderRadius: 12,
              onTap: (DateTime dateTime, bool isSelected) {
                debugPrint(dateTime.toIso8601String());
                debugPrint('$isSelected');
                setState(() {
                  if (isSelected) {
                    _selectedDates.add(formatDate(dateTime));
                  } else {
                    _selectedDates.remove(formatDate(dateTime));
                  }
                });
              },
              selectedDates: _selectedDates,
              markedDates: _markedDates,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  _selectedDates.forEach((date) {
                    if (_markedDates[date] == null) {
                      _markedDates[date] = [];
                    }

                    _markedDates[date].add('event1');
                  });

                  setState(() {});
                },
                child: Text('Mark selected dates'),
              ),
              RaisedButton(
                onPressed: () {
                  _selectedDates.forEach((date) {
                    if (_markedDates[date] == null) {
                      _markedDates[date] = [];
                    }

                    _markedDates[date].remove('event1');
                  });

                  setState(() {});
                },
                child: Text('Unmark selected dates'),
              ),
            ],
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Text(_selectedDates.toString()),
            ),
          )
          // Text('Hello')
        ],
      ),
    ));
  }
}