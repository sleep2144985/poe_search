import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

Container searchInput(void onChanged(String value), void onTap(),
    void onSubmitted(String value)) {
  return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(left: 25.0, top: 40.0, right: 20.0),
      child: TextField(
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "搜尋道具...",
            fillColor: Color(0xffe2e2e2),
            filled: true),
        onChanged: onChanged,
        onTap: onTap,
        onSubmitted: onSubmitted,
      ));
}

Container valueFilter(
    String text,
    TextEditingController _mincontroller,
    TextEditingController _maxcontroller,
    void minChanged(String value),
    void maxChanged(String value),
    [void deleteicon()=null]) {
      SizedBox icon = null;
      Padding iconPadding = Padding(
          padding: EdgeInsets.all(0),
        );
      if(deleteicon!=null) {
        iconPadding = Padding(
          padding: EdgeInsets.all(2),
        );
        icon = SizedBox(
            width: 40,
            height: 40,
            child: Container(
                alignment: Alignment.center,
                child: IconButton(icon: Icon(Icons.close),alignment: Alignment.center,iconSize: 17,onPressed: deleteicon,),
                color: Color(0xffe2e2e2),
            )
          );
      }
  return Container(
      padding:
          EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
        Expanded(
            child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 10.0),
                height: 40,
                color: Color(0xffe2e2e2),
                child: Text(
                  text,
                  style: TextStyle(fontSize: 17),
                ))),
        Padding(
          padding: EdgeInsets.all(2),
        ),
        SizedBox(
            width: 40,
            child: Container(
                color: Color(0xffe2e2e2),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: _mincontroller,
                  decoration: InputDecoration(
                      hintText: "min", border: InputBorder.none),
                  keyboardType: TextInputType.number,
                  onChanged: minChanged,
                ))),
        Padding(
          padding: EdgeInsets.all(2),
        ),
        SizedBox(
            width: 40,
            child: Container(
                color: Color(0xffe2e2e2),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: _maxcontroller,
                  decoration: InputDecoration(
                      hintText: "max", border: InputBorder.none),
                  keyboardType: TextInputType.number,
                  onChanged: maxChanged,
                ))),
                iconPadding,
                icon
      ])));
}

