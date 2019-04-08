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
  // TODO: Clean up the code
  void updateEven(val) {
    int subNetsNum;
    // Checks if it's valid
    try {
      subNetsNum = int.parse(val);
    } on FormatException {
      return;
    }

    subNetsNum = _operations.toUpperPow(subNetsNum);
    int subHosts = (int.parse(_hostsStr) + 2) ~/ subNetsNum;
    // When there are not enough hosts
    if(subHosts < 2)
      return;


    Address helperAddress = new Address(_ip.toString() + "/" + _ip.prefixNum.toString());
    setState(() {
      // Resets subNets (so there is no repetition)
      subNets = new List<SubNetwork>();
      subNets.add(new SubNetwork.interface());
      
      for(int i = 0; i < subNetsNum; i++) {
        String out1 = helperAddress.toString() + "/" + helperAddress.prefixNum.toString();
        helperAddress.address += 1;
        String range = helperAddress.toString();
        helperAddress.address += subHosts - 2;
        String out2 = helperAddress.toString() + "/" + helperAddress.prefixNum.toString();
        helperAddress.address -= 1;
        range = range + " - " + helperAddress.toString();
        subNets.add(new SubNetwork(out1, out2, subHosts - 2, range));
        helperAddress.address += 2;
      }
    });
  }

  // UnEven subnetworks
  void updateUnEven(val) {
    List<String> hostsInSubnetwork = val.split(',');
    List<int> hostsInSubnetworksNum = new List<int>();

    // checks if numbers are numbers
    for(int i = 0; i < hostsInSubnetwork.length; i++) {
      try {
        int h = int.parse(hostsInSubnetwork[i]);
        hostsInSubnetworksNum.add(h);
      } on FormatException {
        return;
      }
    }

    Address helperAddress = new Address(_ip.toString() + "/" + _ip.prefixNum.toString());
    setState(() {
      // Resets subNets (so there is no repetition)
      subNets = new List<SubNetwork>();
      subNets.add(new SubNetwork.interface());

      for(int i = 1; i <= hostsInSubnetwork.length; i++) {
        subNets.add(new SubNetwork.unEven(hostsInSubnetworksNum[i - 1],
            _operations.toUpperPow(hostsInSubnetworksNum[i - 1] + 2) - 2, i));
      }

      subNets.sort((SubNetwork b, SubNetwork a) => a.realHosts.compareTo(b.realHosts));
      //  subNets = subNets.reversed;
      for(int i = 1; i < subNets.length; i++) {
        String persPref = (32 - _operations.whatPrefix(subNets[i].realHosts + 2)).toString();
        subNets[i].networkStr = helperAddress.toString() + "/" + persPref;
        helperAddress.address += 1;
        String range = helperAddress.toString();
        helperAddress.address += subNets[i].realHosts;
        subNets[i].broadcastStr = helperAddress.toString() + "/" + persPref;
        helperAddress.address -= 1;
        range = range + " - " + helperAddress.toString();
        subNets[i].rangeStr = range;
        helperAddress.address += 2;
      }
    });
  }

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
                width: 150,
                child: _item.inputItem("", "Subnetworks", _subsCountCon, _isEven),
              )
            ],
          ),
        ),
      ],
    );
  }

  Column subCol() {
    return Column(
      children: <Widget>[
        _item.inputItem("IP", "Please enter an IP Address", _ipCon, true),
        row(),
        _item.inputItem("", 'Use comma to separate subnetworks', _subsCon, !_isEven),
      ],
    );
  }

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
                _item.inputItem("IP", "Please enter an IP Address", _ipCon, true),
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

  Container inputItem(String name, String hintText,
      TextEditingController con, bool isEnabled) { // Function onUpdateFunc,
    return new Container(
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        child: TextField(
          style: style(),
          enabled: isEnabled,
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