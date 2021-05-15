import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    Api.instance.init(apiUrl: 'https://itsuda50.com/index.php');
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String version = '';
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    try {
      version = (await Api.instance.version())['version'];
      setState(() {});
    } catch (e) {
      print('Api error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text('Firelamp: version: $version'),
        ),
      ),
    );
  }
}
