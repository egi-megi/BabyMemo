import 'package:sharing_codelab/photos_library_api/media_item.dart';

class Challenge {
  final String id;
  final String text;
  final int expectedMonth;
  final String longerDescription;
  DateTime _date=null;
  MediaItem mi=null;
  Challenge(this.id, this.text, this.expectedMonth, this.longerDescription);

  Challenge.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'],
        expectedMonth=json['expected_month'],
        longerDescription = json['longer_description'];


  Map<String, dynamic> toJson() =>
    {
      'id': id,
      'text': text,
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


