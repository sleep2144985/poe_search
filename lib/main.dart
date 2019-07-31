import 'package:flutter/material.dart';
import 'package:poe_search/affix_controller.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'widgets/result.dart';
import 'widgets/search.dart';
import 'package:expandable/expandable.dart';
import 'api.dart';
import 'widgets/filterpanel.dart';

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
List<affix_controller> affix_selected = new List<affix_controller>();

class _MyHomePageState extends State<MyHomePage> {
  ScrollController _scrollController = new ScrollController();
  ExpandableController _expandableController = new ExpandableController();
  @override
  void initState() {
    super.initState();
    apitool.first = true;
    apitool.searchflag = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
            searchInput((String value) {
              apitool.submitText = value;
            }, () {
              if (_expandableController.expanded)
                _expandableController.toggle();
            }, (String value) async {
              apitool.submitText = value;
              apitool.affix_selected = affix_selected;
              if (_expandableController.expanded)
                _expandableController.toggle();
              if (!apitool.searchflag) {
                apitool.searchflag = true;
                setState(() {});
              }
              await apitool.search(context);
              apitool.searchflag = false;
              setState(() {});
            }),
            new Filterpanel(
              scrollController: _scrollController,
              apitool: apitool,
              expandableController: _expandableController,
              affix_selected: affix_selected,
            ),
            Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 5),
                child: RaisedButton(
                  child: new Text(apitool.searchflag ? "搜尋中..." : "搜尋",
                      style: TextStyle(color: Colors.white)),
                  color: Color(0xff0f304d),
                  elevation: 4.0,
                  splashColor: Colors.blueGrey,
                  onPressed: apitool.searchflag
                      ? null
                      : () async {
                          apitool.affix_selected = affix_selected;
                          if (_expandableController.expanded)
                            _expandableController.toggle();
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
                if (apitool.first &&
                    apitool.displayItem.length == 0 &&
                    index == 0) {
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
                  int currencyIndex =
                      apitool.allcurrency.indexOf(apitool.nowcurrency);
                  String url =
                      apitool.currencyIcon[apitool.allcode[currencyIndex]];
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
                                    apitool.baseUrl.substring(
                                            0, apitool.baseUrl.length - 1) +
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
                                              child: mods(item['incubatedItem'],
                                                  Color(0xffb4b4ff))),
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
