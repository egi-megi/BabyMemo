import 'package:sharing_codelab/photos_library_api/media_item.dart';

class Challenge {
  final String id;
  final String title;
  final int expectedMonth;
  final String longerDescription;
  final String shortTitle;
  DateTime _date=null;
  MediaItem mi=null;
  Challenge(this.id, this.title, this.expectedMonth, this.longerDescription, this.shortTitle);

  Challenge.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['text'],
        expectedMonth=json['expected_month'],
        longerDescription = json['longer_description'],
        shortTitle = json['short_title'];


  Map<String, dynamic> toJson() =>
    {
      'id': id,
      'text': title,
    };


  bool hasHappened() => _date!=null;

  DateTime get date => _date;

  set date(DateTime value) {
    _date = value;
  }

  String getDescription() {
    if (_date==null) {
      _date=DateTime.now();
    }
    String dateString=_date.toIso8601String();

    return   "#${id} ${dateString}"; //dodac date
    //return   "#${id}";
}
  static String findIdFromDescription(String description) {
    if (description[0]!='#') {
      return null;
    }
    return description.split(" ")[0].substring(1);
  }

  static DateTime findDateFromDescription(String description) {
    if (description[0]!='#') {
      return null;
    }
    return DateTime.parse(description.split(" ")[1]);
  }

}


