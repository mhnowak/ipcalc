import 'dart:math';

class Address {
  int address;
  int prefix;
  int prefixNum;

  // Constructors
  Address(String addressStr) {
    List<String> splitted = addressStr.split('.');
    List<String> splitted2 = splitted[3].split('/');
    address = int.parse(splitted[0]) * 256 * 256 * 256 + int.parse(splitted[1]) * 256 * 256 + int.parse(splitted[2]) * 256 + int.parse(splitted2[0]);
    prefix = 4294967295 - pow(2, 32 - int.parse(splitted2[1])) + 1;
    prefixNum = int.parse(splitted[2]);
  }

  // Adds n to address
  void AddToAddress(int n) {
    address += n;
  }

  String ToString() {
    return _toString(address);
  }

  String _toString(int addressNum) {

    String address = "";

    for(int i = 0; i < 3; i++) {
      address = "." + (addressNum % 256).toString() + address;
      addressNum ~/= 256;
    }
    address = (addressNum % 256).toString() + address;

    return address;
  }

  int _network() {
    return address & prefix;
  }

  int _broadcast() {
    return _network() | 4294967295 - prefix;
  }

  String GetNetwork() {    
    return _toString(_network());
  }

  String GetBroadcast() {
    return _toString(_broadcast());
  }
}