import 'package:sharing_codelab/model/issue.dart';
import 'dart:convert';
class Issues {

  Map idToIssueMap = Map<String, Issue>();

  Issues.fromJson(String  jsonString) {
    final parsed = json.decode(jsonString).cast<Map<String, dynamic>>();

    List<Issue> issues= parsed.map<Issue>((json) => Issue.fromJson(json)).toList();
    issues.forEach((x) => idToIssueMap[x.id]=x);
  }

}