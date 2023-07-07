import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

Stream<RTDBData> fetchData() async* {
  while(true) {
    final response = await http
      .get(Uri.parse('https://mikemadedb-default-rtdb.asia-southeast1.firebasedatabase.app/.json'));
    await Future.delayed(const Duration(seconds: 2));
    if(response.statusCode == 200) {
      yield RTDBData.fromJson(jsonDecode(response.body));
    }
    else {
      throw Exception('Failed to load RTDB Data');
    }
  }
}

Future<RTDBData> createData(int temperature, int humidity, String doorLocked) async {
  final response = await http
    .put(Uri.parse('https://mikemadedb-default-rtdb.asia-southeast1.firebasedatabase.app/.json'),
    headers: <String, String> {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
      <String, dynamic> {
        'temperature': temperature,
        'humidity': humidity,
        'doorLocked': doorLocked,
      }
    )
  );
  if(response.statusCode == 201) {
    return RTDBData.fromJson(jsonDecode(response.body));
  }
  else {
    throw Exception("Failed to update data");
  }
}

class RTDBData {
  final int temperature;
  final int humidity;
  final String doorLocked;

  const RTDBData({
    required this.temperature,
    required this.humidity,
    required this.doorLocked,
  });

  factory RTDBData.fromJson(Map<String, dynamic> json) {
    return RTDBData(
      temperature: json['temperature'],
      humidity: json['humidity'],
      doorLocked: json['doorLocked'],
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  late Stream<RTDBData> data;
  @override
  void initState() {
    super.initState();
    data = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mike's Fetch RTDB"),
      ),
      body: StreamBuilder<RTDBData>(
        stream: data,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            print(snapshot.data!.humidity);
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Data from Firebase",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.0,
                      )
                    ),
                    Card(
                      elevation: 1.0,
                      child: Container(
                        width: 500,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            "Temperature: ${snapshot.data!.temperature}"
                          )
                        )
                      )
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      elevation: 1.0,
                      child: Container(
                        width: 500,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            "Humidity: ${snapshot.data!.humidity}"
                          )
                        )
                      )
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      elevation: 1.0,
                      child: Container(
                        width: 500,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            "Door Locked: ${snapshot.data!.doorLocked}"
                          )
                        )
                      )
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => 
                          UpdateDataPage()
                        ));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Text("Update Data"),
                      )
                    )
                  ]
                )
              )
            );
          } 
          else if(snapshot.hasError) {
            print(snapshot.error);
          }
          return Center(child: const CircularProgressIndicator());
        }
      ),
    );
  }
}

class UpdateDataPage extends StatefulWidget {
  const UpdateDataPage({super.key});

  @override
  State<UpdateDataPage> createState() => _UpdateDataPageState();
}



class _UpdateDataPageState extends State<UpdateDataPage> {

  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _humController = TextEditingController();
  final TextEditingController _doorLockedController = TextEditingController();
  Future<RTDBData>? _futureData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Mike's Update Data"),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Update Data to Firebase",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                )
              ),
              TextField(
                controller: _tempController,
                decoration: const InputDecoration(
                  hintText: 'Enter temperature',
                )
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _humController,
                decoration: const InputDecoration(
                  hintText: 'Enter humidity',
                )
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _doorLockedController,
                decoration: const InputDecoration(
                  hintText: 'Enter state of lock (locked / unlocked)',
                )
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _futureData = createData(int.parse(_tempController.text), int.parse(_humController.text), _doorLockedController.text);
                  });
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Text("Submit Data"),
                )
              ),
              FutureBuilder<RTDBData>(
                future: _futureData,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return const Text("Data successfully updated");
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return const SizedBox();
                },
              ),
            ]
          )
        )
      ),
    );
  }
}
