/*
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/pages/home_page.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:sharing_codelab/model/challenges.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  String jsonString  =  await rootBundle.loadString("assets/chalanges.json");
  var issues=Challenges.fromJson(jsonString);
  final apiModel = PhotosLibraryApiModel(issues);
  apiModel.signInSilently();


  runApp(
    ScopedModel<PhotosLibraryApiModel>(
      model: apiModel,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeData _theme = _buildTheme();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Memo',
      theme: _theme,
      home: HomePage(),
    );
  }
}


ThemeData _buildTheme() {
  final ThemeData base = ThemeData.dark();
  return base.copyWith(
    primaryColor: Colors.purpleAccent[700],
    primaryColorBrightness: Brightness.dark,
    primaryTextTheme: Typography.blackMountainView,
    primaryIconTheme: const IconThemeData(
      color: Colors.grey,
    ),
    accentColor: Colors.white,
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: Colors.white,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    scaffoldBackgroundColor: Colors.indigoAccent,
  );
}
