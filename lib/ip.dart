import 'dart:math';

class Address {
  int address;
  int prefix;
  int prefixNum;

  // String Constructor
  Address(String addressStr) {
    List<String> splitted = addressStr.split('.');
    List<String> splitted2 = splitted[3].split('/');
    address = int.parse(splitted[0]) * 256 * 256 * 256 + int.parse(splitted[1]) * 256 * 256 + int.parse(splitted[2]) * 256 + int.parse(splitted2[0]);
    prefix = 4294967296 - pow(2, 32 - int.parse(splitted2[1]));
    prefixNum = int.parse(splitted2[1]);
  }

  // Address (number) and prefix (number) constructor
  Address.num(int add, int pre, int preNum) {
    address = add;
    prefix = pre;
    prefixNum = preNum;
  }

  String toString() {
    return _toString(address);
  }

  String getPrefix() {
    return _toString(prefix);
  }

  String _toString(int addressNum) {

    String addressStr = "";

    for(int i = 0; i < 3; i++) {
      addressStr = "." + (addressNum % 256).toString() + addressStr;
      addressNum ~/= 256;
    }
    addressStr = (addressNum % 256).toString() + addressStr;

    return addressStr;
  }
}

class AddressOperations {

  // Produces network address from given address
  Address network(Address address) => Address.num(address.address & address.prefix, address.prefix, address.prefixNum);

  // Produces broadcast address from given network address
  Address broadcast(Address network) => Address.num(network.address | 4294967295 - network.prefix, network.prefix, network.prefixNum);

  // IP Class
  String ipClass(Address ip) {
    if(ip.address >= 4026531840)
      return "E";

    if(ip.address >= 3758096384)
      return "D";

    if(ip.address >= 3221225472)
      return "C";

    if(ip.address >= 2147483648)
      return "B";

    return "A";
  }

  // Is string address legit
  bool canCreate(String address) {
    List<String> splitted = address.split('.');

    // Check how length
    if(splitted.length != 4)
      return false;

    // Get Prefix
    List<String> splitH = splitted[3].split('/');
    splitted[3] = splitH[0];

    // If we have more than one '/' in address
    if(splitH.length != 2)
      return false;

    // try parsing prefix
    int pref;
    try {
      pref = int.parse(splitH[1]);
    } on FormatException {
      pref = -1;
    }

    // if prefix is not valid
    if(pref > 32 || pref < 0)
      return false;

    for(int i = 0; i < 4; i++) {
      // try parsing octet
      int parsed;
      try {
        parsed = int.parse(splitted[i]);
      } on FormatException {
        parsed = -1;
      }

      // if octet is not valid
      if(parsed < 0 || parsed > 255)
        return false;
    }

    // passes every test
    return true;
  }

  // TODO: Optimize it, because it's brute forced rn
  int toUpperPow(int x) {
    int closest = 1;

    while(closest < x) {
      closest *= 2;
    }

    return closest;
  }




}

class SubNetwork {
  String number = "3";
  int hosts = 340;
  int realHosts = 510;
  bool isItem = true;

  // Strings
  String networkStr = "192.168.0.10/24";
  String broadcastStr = "192.168.4.9/24";
  String rangeStr = "192.168.0.11 - 192.168.4.8";
  // String smStr = "Subnetwork mask";
  // String hostsStr = "Hosts";

  SubNetwork(String net, String broad, int hos) {
    this.networkStr = net;
    this.broadcastStr = broad;
    this.hosts = hos;
    number = "";
    realHosts = -1;
  }

  SubNetwork.test();

  SubNetwork.interface() {
    this.isItem = false;
  }
}