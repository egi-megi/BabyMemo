import 'package:sharing_codelab/model/chalange.dart';
import 'dart:convert';
class Challenges {

  Map idToChallengesMap = Map<String, Challenge>();

  Challenges.fromJson(String  jsonString) {
    final parsed = json.decode(jsonString).cast<Map<String, dynamic>>();

    List<Challenge> challenges= parsed.map<Challenge>((json) => Challenge.fromJson(json)).toList();
    challenges.forEach((x) => idToChallengesMap[x.id]=x);
  }

}