import 'package:flutter/material.dart';

RichText sockets(String sockets) {
  if (sockets != "") {
    Map colormap = {
      "B": Colors.blue,
      "R": Colors.red,
      "G": Colors.green,
      "W": Colors.white,
      "|": Colors.white
    };
    List<TextSpan> child = [];
    child.add(new TextSpan(text: "插槽連線 : "));
    for (int i = 0; i < sockets.length; i++) {
      child.add(new TextSpan(
          text: sockets[i],
          style: TextStyle(color: colormap[sockets[i]], fontSize: 12)));
    }
    return new RichText(
        text: new TextSpan(
      style: new TextStyle(
        fontSize: 12.0,
        color: Colors.white,
      ),
      children: child,
    ));
  }
  return null;
}

Text mods(String mods, Color color) {
  if (mods != "") {
    return Text(
      mods,
      style: new TextStyle(color: color, fontSize: 12),
    );
  } else {
    return null;
  }
}

Text corrupted(bool corrupted) {
  if (corrupted) {
    return Text(
      "已汙染",
      style: new TextStyle(color: Color(0xffd20000), fontSize: 12),
    );
  }
  return null;
}

Widget contentdivider(String content) {
  if (content != "") {
    return new Divider(
      color: Color(0xff534d37),
    );
  }
  return null;
}

Widget dropDownList(
    List<String> list, String selected, void onChanged(String value)) {
  return new DropdownButtonHideUnderline(
      child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
              value: selected,
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                  ),
                );
              }).toList(),
              onChanged: onChanged)));
}
