import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ip.dart';

class SomePage extends StatefulWidget {
  @override
  _SomePageState createState() => _SomePageState();
}

class _SomePageState extends State<SomePage>{
  // Class instances
  Items _item = new Items();
  AddressOperations _operations = new AddressOperations();

  // Addresses
  Address _ip;
  Address _network = new Address("192.168.0.0/24");
  Address _broadcast = new Address("192.168.0.255/24");

  // Controllers
  TextEditingController _ipCon = TextEditingController();

  // Strings
  String _ipStr = "IPs";
  String _smStr = "Subnetwork mask";
  String _networkStr = "Network Address";
  String _broadcastStr = "Broadcast Address";
  String _rangeStr = "Network Address - Broadcast Address";
  String _hostsStr = "Hosts";
  String _classStr = "Class";

  // Updates everything
  void updateEveryIP(val) {
    setState(() {
      // Get ip Input String
      _ipStr = val;

      // Update all Addresses
      _ip = Address(_ipStr);
      _network = _operations.network(_ip);
      _broadcast = _operations.broadcast(_network);

      // Update all Strings
      _networkStr = _network.toString() + "/" + _network.prefixNum.toString();
      _broadcastStr = _broadcast.toString() + "/" + _broadcast.prefixNum.toString();
      _smStr = _ip.getPrefix();
      _classStr = _operations.ipClass(_ip);

      // Add 1 to network and broadcast (needed to produce range)
      _network.address += 1;
      _broadcast.address -= 1;

      // Cast network and broadcast addresses to range string and get hosts
      _rangeStr =  _network.toString() + " - " + _broadcast.toString();
      _hostsStr = ((_broadcast.address + 1)- _network.address).toString();

      // Minus 1 from network and broadcast addresses (undo produced range)
      _network.address -= 1;
      _broadcast.address += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    _ipCon.addListener(() {
      // Checks if we can convert string to an address
      if(_operations.canCreate(_ipCon.text))
        updateEveryIP(_ipCon.text);
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("IP Calculator"),
        ),
        bottomNavigationBar: TabBar(
          tabs: <Widget>[
            Tab(text: "IP Calc"),
            Tab(text: "Subnetworks"),
          ]
        ),
        body: TabBarView(
          children: <Widget>[
            ListView(
              padding: EdgeInsets.all(8.0),
              children: <Widget>[
                _item.inputItem("IP", "Please enter an IP Address", _ipCon),
                _item.outputItem("Subnetwork Mask", _smStr),
                _item.outputItem("Network Address", _networkStr),
                _item.outputItem("Broadcast Address", _broadcastStr),
                _item.outputItem("Range", _rangeStr),
                _item.doubleOutputItem("Hosts Available", _hostsStr, "Class", _classStr),
  //          _item.outputItem("Checker", _ipStr),
  //          Text('$_ipStr'),
              ],
            ),
            ListView(
              padding: EdgeInsets.all(8.0),
              children: <Widget>[
                _item.inputItem("IP", "Please enter an IP Address", _ipCon),
                _item.inputItem("", "Number of subnetworks", _ipCon),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Items {

  Container inputItem(String name, String hintText,TextEditingController con) { // Function onUpdateFunc,
    return new Container(
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        child: TextField(
          style: TextStyle(
            fontSize: 21,
          ),
          controller: con,
          //onChanged: (val) => onUpdateFunc(val),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            suffixText: name,
          ),
        )
    );
  }

  Container outputItem(String name, String output) {
    return new Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _outputBox(name, output),
          _copyButton(output),
        ],
      ),
    );
  }

  Container doubleOutputItem(String name1, String output1, String name2, String output2) {
    return new Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _outputBox(name1, output1),
          _copyButton(output1),
          _outputBox(name2, output2),
          _copyButton(output2),
        ],
      ),
    );
  }

  Expanded _outputBox(String name, String output) {
    return new Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              '$name',
              style: TextStyle(
                fontSize: 14,
              )
          ),
          Text(
            '$output',
            style: TextStyle(
              fontSize: 21,
            ),
          ),
        ],
      ),
    );
  }

  Container _copyButton(String copyContent) {
    return new Container(
      child: IconButton(
        onPressed: () => _copy(copyContent),
        icon: Icon(
          Icons.content_copy,
        ),
      ),
    );
  } // public widgets

  void _copy(String toCopy) {
    Clipboard.setData(new ClipboardData(text: toCopy));
    // ScaffoldKey.of(context).showSnackBar(SnackBar(content: Text('Copied')));
    // TODO: Show a snackbar while copying (Inherited Widget)
  }
}