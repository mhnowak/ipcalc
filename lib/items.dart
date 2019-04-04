import 'package:flutter/material.dart';

class Items{

  // private helpers

  Expanded _outputBox(String name, String output) {
    return new Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
            )
          ),
          Text(
            output,
            style: TextStyle(
              fontSize: 21,
            ),
          ),
        ],
      ),
    );
  }

  Container _copyButton() {
    return new Container(
      child: IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.content_copy,
        ),
      ),
    );
  }
  // public widgets

  Container outputItem(String name, String output) {
    return new Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _outputBox(name, output),
          _copyButton(),
        ],
      ),
    );
  }

  Container inputItem(String name, String hintText) {
    return new Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      child: TextField(
        style: TextStyle(
          fontSize: 21,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          suffixText: name,
        ),
      )
    );
  }

  Container halfOutputItem(String name1, String output1, String name2, String output2) {
    return new Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _outputBox(name1, output1),
          _copyButton(),
          _outputBox(name2, output2),
          _copyButton(),
        ],
      ),
    );
  }
}