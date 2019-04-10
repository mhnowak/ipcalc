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
  Warnings _war =  new Warnings();

  // Addresses
  Address _ip;
  Address _network = new Address("192.168.0.0/24");
  Address _broadcast = new Address("192.168.0.255/24");

  // Controllers
  TextEditingController _ipCon = TextEditingController();
  TextEditingController _subsCon = TextEditingController();
  TextEditingController _subsCountCon = TextEditingController();
  bool _isEven = false;
  bool _initial = true;

  // Strings
  String _ipStr = "IPs";
  String _smStr = "Subnetwork mask";
  String _networkStr = "Network Address";
  String _broadcastStr = "Broadcast Address";
  String _rangeStr = "Network Address - Broadcast Address";
  String _hostsStr = "254";
  String _classStr = "Class";

  List<SubNetwork> subNets = new List<SubNetwork>();

  // Warnings
  bool _ipWar = false;
  bool _subWar = false;
  bool _subCountWar = false;
  Color _ipWarCol = Colors.transparent;
  Color _subWarCol = Colors.transparent;
  Color _subCountWarCol = Colors.transparent;

  void enableIPWarning(Color col, bool qm) {
    _ipWar = qm;
    _ipWarCol = col;
  }

  void enableSubWarning(Color col, bool qm) {
    _subWar = qm;
    _subWarCol = col;
  }

  void enableSubCountWarning(Color col, bool qm) {
    _subCountWar = qm;
    _subCountWarCol = col;
  }
  // creates dummy subNetworks
  void dummySubNets() {
    // Resets subNets (so there is no repetition)
    subNets = new List<SubNetwork>();
    subNets.add(new SubNetwork.interface());
    subNets.add(new SubNetwork.test());
    subNets.add(new SubNetwork.test());
    subNets.add(new SubNetwork.test());
    subNets.add(new SubNetwork.test());
    subNets.add(new SubNetwork.test());
    subNets.add(new SubNetwork.test());
  }

  // Updates IP
  void updateEveryIP(val) {
    setState(() {
      // Get ip Input String
      _ipStr = val;

      // Update all Addresses
      _ip = Address(_ipStr);
      _network = _operations.network(_ip);
      _broadcast = _operations.broadcast(_network);

      if(_ip.prefixNum == 32)
        enableIPWarning(Colors.red, false);
      else if(_ip.prefixNum == 31)
        enableIPWarning(Colors.orangeAccent, true);
      else
        enableIPWarning(Colors.transparent, false);


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

  // Even subnetworks
  void updateEven(val) {
    if(_ipStr == "IPs")
      return;

    // Checks if it's valid
    int subNetsNum;
    try {
      subNetsNum = int.parse(val);
    } on FormatException {
      return;
    }

    subNetsNum = _operations.toUpperPow(subNetsNum);
    int subHosts = (int.parse(_hostsStr) + 2) ~/ subNetsNum;

    setState(() {
      if(subNetsNum < 0) {
        enableSubCountWarning(Colors.red, false);
      }
      else if(subHosts < 2) {
        enableSubCountWarning(Colors.red, false);
        return;
      }
      else
        enableSubCountWarning(Colors.transparent, false);

      Address helperAddress = new Address(_ip.toString() + "/" + _ip.prefixNum.toString());
      // Resets subNets (so there is no repetition)
      subNets = new List<SubNetwork>();
      subNets.add(new SubNetwork.interface());
      
      for(int i = 0; i < subNetsNum; i++) {
        // network
        String network = helperAddress.toString() + "/" + helperAddress.prefixNum.toString();

        // range
        helperAddress.address += 1;
        String range = helperAddress.toString();

        // broadcast
        helperAddress.address += subHosts - 2;
        String broadcast = helperAddress.toString() + "/" + helperAddress.prefixNum.toString();

        // range
        helperAddress.address -= 1;
        range = range + " - " + helperAddress.toString();

        // actually merge everything to SubNetwork
        subNets.add(new SubNetwork(network, broadcast, subHosts - 2, range));

        // next network address
        helperAddress.address += 2;
      }
    });
  }

  // UnEven subnetworks
  void updateUnEven(val) {
    List<String> hostsInSubnetwork = val.split(',');
    List<int> hostsInSubnetworksNum = new List<int>();

    bool negative = false;
    // checks if numbers are numbers
    for(int i = 0; i < hostsInSubnetwork.length; i++) {
      try {
        int h = int.parse(hostsInSubnetwork[i]);
        hostsInSubnetworksNum.add(h);
      } on FormatException {
        return;
      }

      if(hostsInSubnetworksNum[i] < 0)
        negative = true;
    }

    Address helperAddress = new Address(_ip.toString() + "/" + _ip.prefixNum.toString());
    setState(() {
      // Resets subNets (so there is no repetition)
      subNets = new List<SubNetwork>();
      subNets.add(new SubNetwork.interface());

      int sum = 0;
      for(int i = 1; i <= hostsInSubnetwork.length; i++) {
        subNets.add(new SubNetwork.unEven(hostsInSubnetworksNum[i - 1],
            _operations.toUpperPow(hostsInSubnetworksNum[i - 1] + 2) - 2, i));
        sum += hostsInSubnetworksNum[i - 1];
      }

      if(negative || _war.notEnoughHosts(32 - _ip.prefixNum, sum + 2))
        enableSubWarning(Colors.red, false);
      else
        enableSubWarning(Colors.transparent, false);

      // sorting from highest to lowest
      subNets.sort((SubNetwork b, SubNetwork a) => a.realHosts.compareTo(b.realHosts));

      // Produce
      for(int i = 1; i < subNets.length; i++) {
        // sets prefix
        String persPref = (32 - _operations.whatPrefix(subNets[i].realHosts + 2)).toString();

        // network
        subNets[i].networkStr = helperAddress.toString() + "/" + persPref;

        // range 1st-part
        helperAddress.address += 1;
        String range = helperAddress.toString();

        // broadcast
        helperAddress.address += subNets[i].realHosts;
        subNets[i].broadcastStr = helperAddress.toString() + "/" + persPref;

        // range last-part
        helperAddress.address -= 1;
        range = range + " - " + helperAddress.toString();
        subNets[i].rangeStr = range;

        // next network address
        helperAddress.address += 2;
      }
    });
  }

  // Switch and subnetworks count
  Row row() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                  "Are subnetworks even?",
                  style: TextStyle(
                    fontSize: 14,
                  )
              ),
              Switch(
                value: _isEven,
                onChanged: (val) {
                  setState(() {
                    _isEven = val;
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                  "How many even subnetworks?",
                  style: TextStyle(
                    fontSize: 14,
                  )
              ),
              SizedBox(
                width: 190,
                child: _item.inputItem("Subnetworks", _subsCountCon, _isEven, 
                _subCountWarCol, _subCountWar, 3),
              )
            ],
          ),
        ),
      ],
    );
  }

  // Interface widget as a whole
  Column subCol() {
    return Column(
      children: <Widget>[
        _item.inputItem("Please enter an IP Address", _ipCon, true, _ipWarCol, _ipWar, 18),
        row(),
        _item.inputItem('Use comma to separate subnetworks', _subsCon, !_isEven, _subWarCol, _subWar, 100),
      ],
    );
  }

  // List item
  Column itemCol(int index) {
    return Column(
      children: <Widget>[
        _item.outputItem((index).toString() + ". " +
          (subNets[index].number == "" ? "" : "(" +
            subNets[index].number + ")") + " Hosts: " +
            subNets[index].hosts.toString() +
            (subNets[index].realHosts != -1 ? ". Real number of hosts: " +
            subNets[index].realHosts.toString() : "") + ".",
            subNets[index].rangeStr),
        _item.outputItem("Network Address", subNets[index].networkStr),
        _item.outputItem("Broadcast Address", subNets[index].broadcastStr),
        //_item.outputItem("Range", subNets[index].rangeStr),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    //dummySubNets();
    //subNets = new List<SubNetwork>();

    if(_initial) {
      _initial = false;
      subNets.add(new SubNetwork.interface());
    }

    _subsCon.addListener(() {
        updateUnEven(_subsCon.text);
    });

    _subsCountCon.addListener(() {
      updateEven(_subsCountCon.text);
    });

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
                _item.inputItem("Please enter an IP Address", _ipCon, true, _ipWarCol, _ipWar, 18),
                _item.outputItem("Subnetwork Mask", _smStr),
                _item.outputItem("Network Address", _networkStr),
                _item.outputItem("Broadcast Address", _broadcastStr),
                _item.outputItem("Range", _rangeStr),
                _item.doubleOutputItem("Hosts Available", _hostsStr, "Class", _classStr),
  //          _item.outputItem("Checker", _ipStr),
  //          Text('$_ipStr'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
               children: <Widget>[
                 Expanded(
                   child: new ListView.separated(
                     itemCount: subNets.length,
                     separatorBuilder: (BuildContext context, int index) {
                       return Divider(height: 3, color: Colors.black38);
                     },
                     itemBuilder: (BuildContext context, int index) {
                       if(!subNets[index].isItem)
                         return subCol();

                       return itemCol(index);
                     },
                   ),
                 ),
               ],
             ),
            ),
          ],
        ),
      ),
    );
  }
}

class Items {

  TextStyle style() {
    return TextStyle(
      fontSize: 21,
    );
  }

  Container inputItem(String hintText, TextEditingController con, 
  bool isEnabled, Color col, bool qm, int max) {
    return new Container(
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        child: TextField(
          maxLength: max,
          style: TextStyle(
            fontSize: 21,
            color: col != Colors.transparent ? col : null,
          ),
          enabled: isEnabled,
          controller: con,
          //onChanged: (val) => onUpdateFunc(val),
          decoration: InputDecoration(
            border: InputBorder.none,
            suffixIcon: Text(qm ? "?" : "!", style: TextStyle(color: col, fontSize: 36,),),
            hintText: hintText,
            counterText: '',
          ),
        )
    );
  }

  Padding outputItem(String name, String output) {
    return new Padding(
      padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
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
            style: style(),
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