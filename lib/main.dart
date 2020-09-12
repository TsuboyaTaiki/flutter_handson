import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<GetResults> res;
  @override
  void initState() {
    super.initState();
    res = getUsers();
  }

  void _postUser() {
    postUser();
    setState(() {
      res = getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APIをPOSTで呼び出しJSONパラメータを渡す',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('RailsAPI x Flutter'),
        ),
        body: Center(
          child: FutureBuilder<GetResults>(
            future: getUsers(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                    snapshot.data.message.toString()
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _postUser,
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class GetResults {
  final String message;
  GetResults({
    this.message,
  });
  factory GetResults.fromJson(Map<String, dynamic> json) {
    var datas = '';
    json['data'].forEach((item) => datas += 'id: ' + item['id'].toString() + ', name: ' + item['name'] + ', email: ' + item['email'] + '\n');
    return GetResults(
      message: datas,
    );
  }
}

class PostResults {
  final String message;
  PostResults({
    this.message,
  });
  factory PostResults.fromJson(Map<String, dynamic> json) {
    return PostResults(
      message: json['message'],
    );
  }
}

class SampleRequest {
  final String name;
  final String email;
  SampleRequest({
    this.name,
    this.email,
  });
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
  };
}

Future<GetResults> getUsers() async {
  var url = 'http://127.0.0.1:3000/v1/users';
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return GetResults.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed');
  }
}

Future<PostResults> postUser() async {
  var url = "http://127.0.0.1:3000/v1/users";
  var request = new SampleRequest(name: 'foo', email: 'foo@example.com');
  final response = await http.post(url,
      body: json.encode(request.toJson()),
      headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
    return PostResults.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed');
  }
}
