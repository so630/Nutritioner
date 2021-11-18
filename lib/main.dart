// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  State createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  late bool connectivityResult;

  @override
  void initState() {
    setState(() {
      connectivityResult = false;
    });
    _check();
  }

  void _check() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          connectivityResult = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        connectivityResult = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomePage(connectivityResult, _check);
  }
}

class HomePage extends StatelessWidget {
  var connectivityResult;
  var _check;

  HomePage(this.connectivityResult, this._check);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Nutritioner'),
          backgroundColor: Colors.green,
        ),
        body: connectivityResult ? Home() : NoInternet(_check),
      ),
    );
  }
}

class RecipeApp extends StatelessWidget {
  var _title;

  RecipeApp(this._title);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
                '${_title['recipe']['label'].toString().substring(0, _title['recipe']['label'].toString().length > 25 ? 25 : _title['recipe']['label'].toString().length)}${_title['recipe']['label'].toString().length > 25 ? '...' : ''}'),
          ),
          backgroundColor: Colors.green,
        ),
        body: Recipe(_title),
      ),
    );
  }
}

class Recipe extends StatefulWidget {
  var _title;

  Recipe(this._title);

  @override
  State createState() {
    return _RecipePageState(this._title);
  }
}

class _RecipePageState extends State<Recipe> {
  var _title;
  var _json;

  _RecipePageState(this._title);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image.network(
                        _title['recipe']['image'],
                        fit: BoxFit.cover,
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Positioned(
                        top: 150,
                        child: FlatButton(
                          child: Container(
                            child: Center(
                                child: Text(
                                  '${_title['recipe']['label'].substring(0, _title['recipe']['label'].length > 15 ? 15 : _title['recipe']['label'].length)}${_title['recipe']['label'].length > 15 ? '...' : ''}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                )),
                            height: 120,
                            width: MediaQuery.of(context).size.width * 0.7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueGrey.withOpacity(0.5),
                                  spreadRadius: 2.5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                )
                              ],
                              color: Color.fromRGBO(255, 196, 57, 1),
                            ),
                          ),
                          onPressed: () async {
                            final url = _title['recipe']['url'];
                            await launch(url);
                          },
                        )
                        )
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
                      child: Column(
                        children: [
                          Padding(
                              child: Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40)),
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                          ),
                          ..._title['recipe']['ingredientLines'].map((line) {
                            return Padding(
                              padding: EdgeInsets.fromLTRB(0, 1, 0, 1),
                              child: IngredientCard(line),
                            );
                          })
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    child: MaterialButton(
                      child: Center(child: Text('Know More')),
                      onPressed: () async {
                        final url = _title['recipe']['url'];
                        await launch(url);
                      }
                    ),
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  var _response;
  var _json = [];
  var _json2 = [];
  var search;

  void _respond(str) async {
    if (str == '') {
      return;
    }
    var keys = {
      'q': str,
      'app_id': '1324d9dc',
      'app_key': '8e8277b93a0af1e2aed865fcf62139c8',
    };
    var response = await http.get(Uri.parse(
        'https://api.edamam.com/api/recipes/v2?q=${keys['q']}&app_id=${keys['app_id']}&app_key=${keys['app_key']}&type=public'));
    setState(() {
      if ((jsonDecode(response.body))['hits'].runtimeType == Null) {
        _json = [];
      } else {
        _json = [...(jsonDecode(response.body))['hits']];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Row(
                  children: [
                    SizedBox(
                      child: TextField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Enter a search term',
                        ),
                        onChanged: (str) {
                          setState(() {
                            search = str;
                          });
                        },
                      ),
                      width: 200,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(60, 0, 0, 0),
                      child: MaterialButton(
                        child: Text('Search'),
                        onPressed: () {
                          _respond(search);
                        },
                        color: Colors.green,
                        focusColor: Colors.greenAccent,
                      ),
                    )
                  ],
                ),
              ),
              ...(_json.map((name) => FoodCard(name['recipe']['label'])).isEmpty
                  ? [NoResult()]
                  : _json.map((name) => FoodCard(name)))
            ],
          ),
        ),
      ),
    );
  }
}

class NoResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 30, 5, 0),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0.4, 20, 20),
        child: Text(
          'No Results',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white.withOpacity(0.3),
      ),
    );
  }
}

class IngredientCard extends StatelessWidget {

  final _info;

  IngredientCard(this._info);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 5, 0),
      child: Padding(
          padding: EdgeInsets.all(0),
          child: Text(
            '✔   ${_info}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      width: double.infinity
    );
  }
}

class FoodCard extends StatelessWidget {
  final _info;

  FoodCard(this._info);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 30, 5, 0),
      child: FlatButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => RecipeApp(_info)));
        },
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            _info['recipe']['label'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.green,
      ),
    );
  }
}

class NoInternet extends StatefulWidget {
  var _check;

  NoInternet(this._check);

  @override
  State createState() {
    return _NoInternetState(_check);
  }
}

class _NoInternetState extends State<NoInternet> {
  var _check;

  _NoInternetState(this._check);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 250, 0, 0),
      child: Center(
          child: Column(
        children: [
          Text(
            'No Internet',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          OutlinedButton(
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.green),
            ),
            onPressed: () {
              _check();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(width: 2, color: Colors.green),
            ),
          )
        ],
      )),
    );
  }
}
