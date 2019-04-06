import 'package:flutter/material.dart';
import 'items.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    title: 'IP Calculator',
    theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.black,
    ),
    home: SomePage(),
    );
  }
}


//Scaffold(
//appBar: AppBar(
//title: Text('IP Calculator'),
//),
//body: Center(
//child: ListView(
//padding: EdgeInsets.all(8.0),
//children: <Widget>[
//_items.inputItem("IP", "Please enter an IP Addres"),
//_items.outputItem("Subnetwork Mask", "255.255.255.0"),
//_items.outputItem("Network Address" , _ip.GetNetwork()),
//_items.outputItem("Broadcast Address", _ip.GetBroadcast()),
//_items.outputItem("Range", "192.255.255.55 - 255.255.255.255"),
//_items.halfOutputItem("Hosts", "4294967295", "Class", "C")
//],
//)
//),
//),
