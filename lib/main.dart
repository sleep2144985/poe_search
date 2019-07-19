import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'widgets/result.dart';
import 'widgets/search.dart';
import 'package:expandable/expandable.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'api.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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


List<Color> frameType = [
  Color(0xffc8c8c8),
  Color(0xff8888ff),
  Color(0xffffff77),
  Color(0xffaf6025),
  Color(0xff1ba29b),
  Color(0xffaa9e82)
];
api apitool = new api();
class _MyHomePageState extends State<MyHomePage> {
  ScrollController _scrollController = new ScrollController();
  TextEditingController _mincontroller;
  TextEditingController _maxcontroller;
  ExpandableController _expandableController =
      new ExpandableController(initialExpanded: false);
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  List<String> suggestions = [
    "火焰抗性",
    "冰冷抗性",
    "閃電抗性",
  ];
  @override
  void initState() {
    super.initState();
    apitool.first = true;
    apitool.searchflag = false;
    apitool.getleagues();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> filterpanel;
    apitool.nullAlert = Alert(
      context: context,
      type: AlertType.warning,
      title: "查詢結果為空 QQ",
      buttons: [
        DialogButton(
          child: Text(
            "好",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
      ],
    );
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: ListView(
          shrinkWrap: true,
          controller: _scrollController,
          children: <Widget>[
            ListView(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: <Widget>[
                  searchInput((String value) {
                    apitool.submitText = value;
                  }, () {
                    if (_expandableController.expanded)
                      _expandableController.toggle();
                  }, (String value) async {
                    apitool.submitText = value;
                    await apitool.search(context);
                  }),
                  Container(
                      padding: EdgeInsets.only(left: 20.0, top: 10.0),
                      child: ExpandablePanel(
                        controller: _expandableController,
                        tapHeaderToExpand: true,
                        tapBodyToCollapse: true,
                        headerAlignment: ExpandablePanelHeaderAlignment.center,
                        header: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "顯示篩選",
                              style: Theme.of(context).textTheme.body2,
                            )),
                        expanded: Column(
                          children: <Widget>[
                            Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 10.0, top: 10.0),
                                child: Row(children: <Widget>[
                                  Container(
                                      color: Color(0xffe2e2e2),
                                      child: dropDownList(
                                        apitool.allcurrency,
                                        apitool.selectedprice,
                                        (String newValue) {
                                          setState(() {
                                            apitool.selectedprice = newValue;
                                          });
                                        },
                                      )),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Container(
                                      color: Color(0xffe2e2e2),
                                      child: dropDownList(
                                        apitool.leagues,
                                        apitool.selectedleague,
                                        (String newValue) {
                                          setState(() {
                                            apitool.selectedleague = newValue;
                                          });
                                        },
                                      ))
                                ])),
                            valueFilter("插槽連結", _mincontroller, _maxcontroller,
                                (String value) {
                              apitool.linksmin = value;
                            }, (String value) {
                              apitool.linksmax = value;
                            },(){print("K");}),
                            Container(
                                padding: EdgeInsets.all(10),
                                child: AutoCompleteTextField<String>(
                                  itemSubmitted: (item) => (print(item)),
                                  itemBuilder: (context, suggestion) =>
                                      new ListTile(title: new Text(suggestion)),
                                  onTap: () async { 
                                    await new Future.delayed(new Duration(milliseconds: 1000));
                                    _scrollController.animateTo(
                                         _scrollController.position.maxScrollExtent,
                                         duration: Duration(milliseconds: 300),
                                         curve: Curves.ease);
                                  },
                                  onFocusChanged: (bool changed) {
                                    if (changed)
                                      _scrollController.jumpTo(_scrollController
                                          .position.maxScrollExtent);
                                  },
                                  itemSorter: (a, b) =>
                                      a == b ? 0 : a.length > b.length ? -1 : 1,
                                  itemFilter: (suggestion, input) => suggestion
                                      .toLowerCase()
                                      .startsWith(input.toLowerCase()),
                                  key: key,
                                  decoration: new InputDecoration(
                                      hintText: "+新增數值過濾",
                                      border: InputBorder.none,
                                      fillColor: Color(0xffe2e2e2),
                                      filled: true),
                                  controller: TextEditingController(),
                                  suggestions: suggestions,
                                  textChanged: (text) => apitool.filtertext = text,
                                  submitOnSuggestionTap: true,
                                ))
                          ],
                        ),
                        collapsed: null,
                      ))
                ]),
            Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: RaisedButton(
                  child: new Text(apitool.searchflag ? "搜尋中..." : "搜尋",
                      style: TextStyle(color: Colors.white)),
                  color: Color(0xff0f304d),
                  elevation: 4.0,
                  splashColor: Colors.blueGrey,
                  onPressed: apitool.searchflag
                      ? null
                      : () async {
                          if (!apitool.searchflag) {
                            apitool.searchflag = true;
                            setState(() {});
                          }
                          await apitool.search(context);
                          setState(() {});
                          apitool.searchflag = false;
                        },
                )),
            ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: apitool.listLength,
              itemBuilder: (BuildContext context, int index) {
                if (apitool.first && apitool.displayItem.length == 0 && index == 0) {
                  return new Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                          vertical: 1.5, horizontal: 5.0),
                      child: Text(
                        "預設篩選為有價格且升序且玩家在線上\n開始查價ㄅ",
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ));
                } else if (apitool.displayItem.length != 0 &&
                    apitool.displayItemId.length != 0) {
                  Map item = apitool.displayItem[apitool.displayItemId[index]];
                  int currencyIndex = apitool.allcurrency.indexOf(apitool.nowcurrency);
                  String url = apitool.currencyIcon[apitool.allcode[currencyIndex]];
                  return new SingleChildScrollView(
                      child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 1.5, horizontal: 10.0),
                          color: Colors.grey,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: 80,
                                height: 240,
                                child: Container(
                                  child: Image.network(
                                    apitool.baseUrl.substring(0, apitool.baseUrl.length - 1) +
                                        item['icon'],
                                    fit: BoxFit.scaleDown,
                                  ),
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                  child: ConstrainedBox(
                                      constraints: new BoxConstraints(
                                        minHeight: 240,
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.all(0),
                                        padding: EdgeInsets.all(5),
                                        child: Column(children: <Widget>[
                                          Text(
                                            item['name'] + item['typeLine'],
                                            style: new TextStyle(
                                                color: frameType[
                                                    item['frameType']]),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.all(0.0),
                                              child: contentdivider(
                                                  item['name'] +
                                                      item['typeLine'])),
                                          Container(
                                              alignment: Alignment.centerLeft,
                                              child: mods(item['implicitMods'],
                                                  Color(0xff8888FF))),
                                          Padding(
                                              padding: EdgeInsets.all(0.0),
                                              child: contentdivider(
                                                  item['implicitMods'])),
                                          Container(
                                              alignment: Alignment.centerLeft,
                                              child: mods(item['explicitMods'],
                                                  Color(0xff8888FF))),
                                          Container(
                                              alignment: Alignment.centerLeft,
                                              child:
                                                  corrupted(item['corrupted'])),
                                          Container(
                                              alignment: Alignment.centerLeft,
                                              child: sockets(item['sockets'])),
                                          new Padding(
                                              padding: EdgeInsets.all(0.0),
                                              child: contentdivider(
                                                  item['explicitMods'])),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              " " + item['indexed'],
                                              style: new TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                " IGN : " +
                                                    item['account']['name'] +
                                                    " ",
                                                style: new TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                              new Image.network(
                                                url,
                                                width: 22,
                                              ),
                                              Text(
                                                "\u3000X " +
                                                    item["price"].toString(),
                                                style: new TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          )
                                        ]),
                                        decoration: new BoxDecoration(
                                          border: new Border(
                                            left: new BorderSide(
                                                color: Colors.white),
                                            right: new BorderSide(
                                                color: Colors.white),
                                          ),
                                          color: Color(0xff333333),
                                        ),
                                      ))),
                            ],
                          )));
                }
              },
            ),
          ],
        )));
  }

 
}
