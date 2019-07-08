import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'widgets/main_widgets.dart';
import 'widgets/filter_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

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
int listLength = 1;
String searchText = "";
String searchId;
List<String> itemId;
List<String> displayItemId;
String selectedprice = "混沌石";
String selectedleague = "";
List<String> leagues = [];
String nowcurrency;
List<String> allcurrency = <String>["混沌石", "崇高石", "鏈結石"];
List<String> allcode = <String>["chaos", "exa", "fusing"];
String baseUrl = "https://web.poe.garena.tw/";
String imgUrl = "https://web.poe.garena.tw/image/Art/2DItems/";
String currencyUrl = imgUrl + "Currency/";
Map currencyIcon = {
  "chaos": currencyUrl + "CurrencyRerollRare.png",
  "exa": currencyUrl + "CurrencyAddModToRare.png",
  "fusing": currencyUrl + "CurrencyRerollSocketLinks.png"
};
List<Color> frameType = [
  Color(0xffc8c8c8),
  Color(0xff8888ff),
  Color(0xffffff77),
  Color(0xffaf6025),
  Color(0xff1ba29b),
  Color(0xffaa9e82)
];
Map<String, Object> displayItem = new HashMap();
Dio dio = new Dio();
String submitText = "";
String linksmin;
String linksmax;
bool first;
Alert nullAlert;
bool searchflag;
String filtertext="";
class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _mincontroller;
  TextEditingController _maxcontroller;
  ExpandableController _expandableController = new ExpandableController(initialExpanded: false);
  @override
  void initState() {
    super.initState();
    first = true;
    searchflag = false;
    getleagues();
  }

  @override
  Widget build(BuildContext context) {
    nullAlert = Alert(
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
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: <Widget>[
            searchInput((String value) {
              submitText = value;
            },(){
              if(_expandableController.expanded)
                _expandableController.toggle();
            },(String value) async {
              submitText = value;
              await search();
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
                          child: Row(
                            children: <Widget>[
                              Container(color: Color(0xffe2e2e2),
                                child: 
                            dropDownList(
                              allcurrency,
                              selectedprice,
                              (String newValue) {
                                setState(() {
                                  selectedprice = newValue;
                                });
                              },
                            )),
                            Padding(
                              padding: EdgeInsets.all(5),
                            ),
                             Container(color: Color(0xffe2e2e2),
                                child: 
                            dropDownList(
                              leagues,
                              selectedleague,
                              (String newValue) {
                                setState(() {
                                  selectedleague = newValue;
                                });
                              },
                            ))
                          ])),
                      valueFilter("插槽連結", _mincontroller, _maxcontroller,
                          (String value) {
                        linksmin = value;
                      }, (String value) {
                        linksmax = value;
                      }),
                    ],
                  ),
                  collapsed: null,
                ))]),
            Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: RaisedButton(
                  child:
                      new Text(
                         searchflag ? "搜尋中..." : "搜尋",
                         style: TextStyle(color: Colors.white)),
                  color: Color(0xff0f304d),
                  elevation: 4.0,
                  splashColor: Colors.blueGrey,
                  onPressed: searchflag ? null : () async {
                    if(!searchflag) {
                      searchflag=true;
                      setState(() {
                      });
                    }
                    await search();
                    setState(() {});
                    searchflag=false;
                  },
                )),
            ListView.builder(
              shrinkWrap: true,
              physics:  ClampingScrollPhysics(),
              itemCount: listLength,
              itemBuilder: (BuildContext context, int index) {
                if (first && displayItem.length == 0 && index == 0) {
                  return new Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                          vertical: 1.5, horizontal: 5.0),
                      child: Text(
                        "預設篩選為有價格且升序且玩家在線上\n開始查價ㄅ",
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ));
                } else if(displayItem.length !=0 && displayItemId.length!=0) {
                  Map item = displayItem[displayItemId[index]];
                  int currencyIndex = allcurrency.indexOf(nowcurrency);
                  String url = currencyIcon[allcode[currencyIndex]];
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
                                    baseUrl.substring(0, baseUrl.length - 1) +
                                        item['icon'],
                                    fit: BoxFit.scaleDown,
                                  ),
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(child:ConstrainedBox(
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

  void search() async {
    await searchMarket(submitText);
    if (itemId.length == 0) {
      nullAlert.show();
    } else{
      await fetchAllItem();
    }
  }

  void getleagues() async {
    String url = baseUrl + "/api/trade/data/leagues";
    await dio.get(url).then((response) {
      if (response.statusCode == 200) {
        List<dynamic> result = response.data['result'];
        for (int i = 0; i < result.length; i++) {
          leagues.add(result[i]['text']);
        }
        selectedleague = leagues[0];
      }
    });
    setState(() {});
  }

  void fetchAllItem() async {
    if (itemId.length != 0) {
      listLength = itemId.length;
      displayItemId = itemId;
      for (int i = 0; i < itemId.length; i += 10) {
        int end = i + 10;
        if (end > itemId.length) {
          end = itemId.length;
        }
        await fetchItems(itemId.sublist(i, end), searchId);
      }
    }
  }

  void searchMarket(String value) async {
    first = false;
    String searchUrl = baseUrl + 'api/trade/search/' + selectedleague;
    nowcurrency = selectedprice;
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/searchparam.json");
    Map jsonResult = json.decode(data);
    int linksminval = null;
    int linksmaxval = null;
    if (linksmin != null && linksmin != "") linksminval = int.parse(linksmin);
    if (linksmax != null && linksmax != "") linksmaxval = int.parse(linksmax);
    jsonResult['query']['term'] = value;
    jsonResult['query']['filters']['socket_filters']['filters']['links']
        ['min'] = linksminval;
    jsonResult['query']['filters']['socket_filters']['filters']['links']
        ['max'] = linksmaxval;
    jsonResult['query']['filters']['trade_filters']['filters']['price']
        ['option'] = allcode[allcurrency.indexOf(nowcurrency)];
    Map params = jsonResult;
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': '*/*'
    };
    Options option = Options(method: 'post');
    option.headers.addAll(headers);
    await dio.post(searchUrl, options: option, data: params).then((response) {
      if (response.statusCode == 200) {
        searchId = response.data['id'];
        itemId = new List<String>.from(response.data['result']);
        if(itemId.length!=0)
          displayItem = {};
        for (int i = 0; i < itemId.length; i++) {
          displayItem[itemId[i]] = {};
        }
      }
    });
  }

  String executeMods(dynamic mods) {
    String tmp = "";
    if (mods != null) {
      List<dynamic> modlist = mods;
      tmp = modlist.join("\n");
    }
    return tmp;
  }

  String executeSockets(dynamic sockets) {
    String tmp = "";
    if (sockets != null) {
      Map<int, String> socket = {};
      List<dynamic> socketlist = sockets;
      for (int i = 0; i < socketlist.length; i++) {
        int group = socketlist[i]['group'];
        if (socket[group] == null) socket[group] = "";
        socket[group] += socketlist[i]['sColour'];
      }
      socket.forEach((k, v) {
        tmp += v + "|";
      });
      tmp = tmp.substring(0, tmp.length - 1);
    }
    return tmp;
  }

  void fetchItems(List<String> id, String queryUrl) async {
    if (id.length > 0) {
      String fetchUrl = baseUrl + "api/trade/fetch/" + id.join(",");
      Map<String, String> headers = {
        'query': queryUrl,
      };
      Options option = Options(method: 'get');
      option.headers.addAll(headers);
      await dio.get(fetchUrl, options: option).then((response) {
        if (response.statusCode == 200) {
          for (int i = 0; i < id.length; i++) {
            Map item = displayItem[id[i]];
            dynamic result = response.data['result'][i];
            item['price'] = result['listing']['price']['amount'];
            item['icon'] = result['item']['icon'];
            item['name'] = result['item']['name'];
            item['typeLine'] = result['item']['typeLine'];
            item['indexed'] = result['listing']['indexed'];
            item['account'] = {'name': ""};
            item['account']['name'] =
                result['listing']['account']['lastCharacterName'];
            DateTime dt = DateTime.parse(item['indexed']);
            item['indexed'] = new DateFormat("yyyy-MM-dd").format(dt);
            if (item['typeLine'] != "") {
              item['typeLine'] = "<" + item['typeLine'] + '>';
            }
            item['sockets'] = executeSockets(result['item']['sockets']);
            item['ilvl'] = result['item']['ilvl'];
            item['frameType'] = result['item']['frameType'];
            if (item['frameType'] > 5) item['frameType'] = 5;
            item['implicitMods'] = executeMods(result['item']['implicitMods']);
            item['explicitMods'] = executeMods(result['item']['explicitMods']);
            if (result['item']['identified'] == false)
              item['explicitMods'] = "未鑑定";
            item['corrupted'] = result['item']['corrupted'];
            if (item['corrupted'] == null) item['corrupted'] = false;
            displayItem[id[i]] = item;
          }
        }
      });
    }
  }
}
