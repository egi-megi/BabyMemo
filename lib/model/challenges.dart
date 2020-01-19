import 'package:sharing_codelab/model/challenge.dart';
import 'dart:convert';
class Challenges {

  Map<String, Challenge> idToChallengesMap = Map<String, Challenge>();

  Challenges.fromJson(String  jsonString) {
    final parsed = json.decode(jsonString).cast<Map<String, dynamic>>();

    List<Challenge> challenges= parsed.map<Challenge>((json) => Challenge.fromJson(json)).toList();
    challenges.forEach((x) => idToChallengesMap[x.id]=x);
  }

  List<Challenge> getUnHappened() {
    List<Challenge> ret=idToChallengesMap.values.where((it)=> it.date==null).toList();
    ret.sort((x,y)=>x.expectedMonth-y.expectedMonth);
    return ret;
  }

  List<Challenge> getHappened(DateTime d) {
    List<Challenge> ret=idToChallengesMap.values
        .where((it)=> it.date!=null &&  it.date.year==d.year && it.date.month==d.month && it.date.day==d.day ).toList();
    ret.sort((x,y)=>x.date.compareTo(y.date));
    return ret;
  }

  List<Challenge> getAllHappened() {
    List<Challenge> ret=idToChallengesMap.values
        .where((it)=> it.date!=null  ).toList();
    ret.sort((x,y)=>x.date.compareTo(y.date));
    return ret;
  }

}