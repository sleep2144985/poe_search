import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
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
int listLength=3;
String searchText="";
String searchId;
List<String> itemId;
String selectedprice="混沌石";
String selectedleague="";
List<String> leagues=[];
String nowcurrency;
List<String> allcurrency=<String>["混沌石", "崇高石", "鏈結石"];
List<String> allcode=<String>["chaos", "exa", "fusing"];
String baseUrl = "https://web.poe.garena.tw/";
String imgUrl = "https://web.poe.garena.tw/image/Art/2DItems/";
String currencyUrl = imgUrl + "Currency/";
Map currencyIcon={"chaos": currencyUrl+"CurrencyRerollRare.png", "exa": currencyUrl+"CurrencyAddModToRare.png", "fusing": currencyUrl+"CurrencyRerollSocketLinks.png"};
List<Color> frameType = [Color(0xffc8c8c8), Color(0xff8888ff), Color(0xffffff77), Color(0xffaf6025), Color(0xff1ba29b), Color(0xffaa9e82)];
Map<String, Object> displayItem = new HashMap();
Dio dio = new Dio();
String submitText="";
String linksmin;
String linksmax;
bool first;
class _MyHomePageState  extends State<MyHomePage> {
  TextEditingController _mincontroller;
  TextEditingController _maxcontroller;
  RichText sockets(String sockets) {
    if(sockets!="") {
      Map colormap = {"B": Colors.blue,"R": Colors.red, "G": Colors.green, "W": Colors.white, "|": Colors.white};
      List<TextSpan> child=[];
      child.add(new TextSpan(text: "插槽連線 : "));
      for(int i=0;i<sockets.length;i++){
        child.add(new TextSpan(text: sockets[i], style: TextStyle(color: colormap[sockets[i]], fontSize: 12)));
      }
      return new RichText(
        text: new TextSpan(
          style: new TextStyle(
            fontSize: 12.0,
            color: Colors.white,
          ),
          children: child,
        )
      );
    }

  }
  Text mods(String mods, Color color) {
    if(mods!="") {
      return Text(
        mods,
        style: new TextStyle(color: color, fontSize: 12),
      );
    } else {
      return null;
    }
  }
  Text corrupted(bool corrupted) {
    if(corrupted) {
      return Text(
       "已汙染",
       style: new TextStyle(color: Color(0xffd20000), fontSize: 12),
      );
    }
    return null;
  } 
  Widget contentdivider(String content) {
    if (content!="") {
      return new Divider(color:Color(0xff534d37),);
    }
    return null;
  }
  Widget dropDownList(List<String> list, String selected,void onChange(String value)) {
    return new DropdownButton<String>(
              value: selected,
              items: list
              .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChange
    );
  }
  @override
    void initState() {
      super.initState();
      first=true;
      getleagues();
    }
  
  @override
  Widget build(BuildContext context) {
    Alert nullAlert = Alert(
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
        body: 
      Container(
        decoration: new BoxDecoration(color: Colors.red),
        child: FloatingSearchBar.builder(
        itemCount: listLength,
        itemBuilder: (BuildContext context, int index) {
          String output = "";
          if(linksmin!=null)
           _mincontroller = new TextEditingController(text: linksmin);
          if(linksmax!=null)
            _maxcontroller = new TextEditingController(text: linksmax);
          if(index==0)
            return Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left: 20.0, top: 20.0),
              child: Row(
                children: <Widget>[
                  dropDownList(
                    allcurrency, 
                    selectedprice,
                    (String newValue) {
                      setState(() {
                        selectedprice = newValue;
                      });
                    },  
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  dropDownList(
                      leagues, 
                      selectedleague,
                      (String newValue) {
                        setState(() {
                            selectedleague = newValue;
                        });
                    },        
                  )
                ]      
              )
            );
          if(index==1)
            return Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left: 20.0, bottom: 20.0, right: 20.0),
              child: Row(
                children: <Widget>[
                  Text("插槽連結", style: TextStyle(fontSize: 15,),),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  Flexible(
                    child: TextField(
                      controller: _mincontroller,
                      decoration: InputDecoration(hintText: "min"),
                      keyboardType: TextInputType.number,
                      onChanged: (String value){linksmin=value;},
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  Flexible(
                    child: TextField(
                    controller: _maxcontroller,
                    decoration: InputDecoration(hintText: "max"),
                    keyboardType: TextInputType.number,
                    onChanged: (String value){linksmax=value;},
                  )
                )
                ]
              )
            );
          if(first && displayItem.length==0 && index==2){
            return new Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 5.0),
                child: Text("預設篩選為有價格且升序且玩家在線上\n開始查價ㄅ", style: TextStyle(fontSize: 20,color: Colors.grey),textAlign: TextAlign.center,)
            );
          } else {
            Map item = displayItem[itemId[index-2]];
            int currencyIndex = allcurrency.indexOf(nowcurrency);
            String url = currencyIcon[allcode[currencyIndex]];
            return new SingleChildScrollView(
              child: Container(
              margin: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 5.0),
              color: Colors.grey,
              child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 80,
                        height: 240,
                        child: Container(
                          child: Image.network(
                            baseUrl.substring(0,baseUrl.length-1) + item['icon'],
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
                            child: Column(
                              children: <Widget>[
                                Text(
                                  item['name'] + item['typeLine'],
                                  style: new TextStyle(color: frameType[item['frameType']]),
                                ),
                                Padding(
                                    padding: EdgeInsets.all(0.0), 
                                    child: contentdivider(item['name'] + item['typeLine'])
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: mods(item['implicitMods'], Color(0xff8888FF))
                                ),
                                Padding(
                                    padding: EdgeInsets.all(0.0), 
                                    child: contentdivider(item['implicitMods'])
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: mods(item['explicitMods'], Color(0xff8888FF))
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: corrupted(item['corrupted'])
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: sockets(item['sockets'])
                                ),
                                new Padding(
                                    padding: EdgeInsets.all(0.0), 
                                    child: contentdivider(item['explicitMods'])
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                       " "+item['indexed'],
                                       style: new TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                     Text(
                                      " IGN : "+item['account']['name']+" ",
                                      style: new TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                     new Image.network(url, width: 22,),
                                     Text(
                                       "\u3000X "+item["price"].toString(),
                                        style: new TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                 )
                              ] 
                             ),
                            decoration: new BoxDecoration(
                              border: new Border(
                                left: new BorderSide(color: Colors.white),
                                right: new BorderSide(color: Colors.white), 
                              ),
                              color: Color(0xff333333),
                            ),
                          )
                        )
                      ),
                    ],
                  )
            ));
          }
        },
        trailing: GestureDetector (
          onTap: () async {
            displayItem={};
            await searchMarket(submitText);
            await fetchAllItem();
            if(itemId.length==0) {
              nullAlert.show();
            }
          },
          child: CircleAvatar(
            child: Icon(IconData(59574, fontFamily: 'MaterialIcons'))
           ),
        ),
        drawer: Drawer(
          child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
              DrawerHeader(
                child: Text('伺服器選擇'),
                decoration: BoxDecoration(
                  color: Colors.black38,
                ),
              ),
              ListTile(
                title: Text('台服'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
        ),
        onChanged: (String value) {
          submitText=value;
        },
        onTap: () {
        },
        onSubmitted: (String value) async {
          displayItem={};
          await searchMarket(value);
          await fetchAllItem();
          if(itemId.length==0) {
            nullAlert.show();
          }
        },
        decoration: InputDecoration.collapsed(
          hintText: "查找販賣中的裝備或物品 ...",
        ),
      ),
      )
  ));
}
  void getleagues() async {
    String url = baseUrl + "/api/trade/data/leagues";
    await dio.get(url).then((response) {
      if(response.statusCode==200){
        List<dynamic> result = response.data['result'];
        for(int i=0;i<result.length;i++) {
          leagues.add(result[i]['text']);
        }
        selectedleague = leagues[0];
      }
    }).whenComplete(
        ()=>setState(() {}));
  }
  void fetchAllItem() async {
    if(itemId.length!=0){
          for(int i=0;i<itemId.length;i+=10) {
            int end = i+10;
          if(end>itemId.length){
            end = itemId.length;
          }
        await fetchItems(itemId.sublist(i,end), searchId);
      }
    }
  }
  void searchMarket(String value) async {
            first=false;
            String searchUrl = baseUrl + 'api/trade/search/' + selectedleague;
            nowcurrency = selectedprice;
            String data = await DefaultAssetBundle.of(context).loadString("assets/searchparam.json");
            Map jsonResult = json.decode(data);
            int linksminval=null;
            int linksmaxval=null;
            if(linksmin!=null&&linksmin!="")
              linksminval = int.parse(linksmin);
            if(linksmax!=null&&linksmax!="")
              linksmaxval = int.parse(linksmax);
            jsonResult['query']['term']=value;
            jsonResult['query']['filters']['socket_filters']['filters']['links']['min']=linksminval;
            jsonResult['query']['filters']['socket_filters']['filters']['links']['max']=linksmaxval;
            jsonResult['query']['filters']['trade_filters']['filters']['price']['option']=allcode[allcurrency.indexOf(nowcurrency)];
            Map params = jsonResult;
            Map<String, String> headers = {
                'Content-type' : 'application/json', 
                'Accept': '*/*'
            };
            Options option = Options(method: 'post');
            option.headers.addAll(headers);
            await dio.post(searchUrl, options: option, data:params).then((response) {
                if(response.statusCode==200){
                  searchId=response.data['id'];
                  itemId = new List<String>.from(response.data['result']);
                  for(int i=0;i<itemId.length;i++){
                    displayItem[itemId[i]]={};
                  }
                  listLength = itemId.length+2;
                }
            });
  }
  String executeMods(dynamic mods) {
    String tmp = "";
    if(mods!=null) {
      List<dynamic> modlist = mods;
      tmp = modlist.join("\n");
    } 
    return tmp;
  }
  String executeSockets(dynamic sockets) {
    String tmp = "";
    if(sockets!=null){
      Map<int,String> socket={};
      List<dynamic> socketlist = sockets;
      for(int i=0;i<socketlist.length;i++) {
        int group = socketlist[i]['group'];
        if(socket[group]==null)
          socket[group]="";
        socket[group] += socketlist[i]['sColour'];
      }
      socket.forEach((k, v) {
        tmp += v+"|";
      });
      tmp = tmp.substring(0,tmp.length-1);
    }
    return tmp;
  }
  void fetchItems(List<String> id, String queryUrl) async {
    if(id.length > 0) {
      String fetchUrl = baseUrl + "api/trade/fetch/" + id.join(",");
      Map<String, String> headers = {
                  'query' : queryUrl, 
              };
      Options option = Options(method: 'get');
      option.headers.addAll(headers);
      await dio.get(fetchUrl, options: option).then((response) {
        if(response.statusCode==200){
          for(int i=0;i<id.length;i++){
            Map item = displayItem[id[i]]; 
            dynamic result = response.data['result'][i];      
            item['price'] = result['listing']['price']['amount'];
            item['icon'] = result['item']['icon'];
            item['name'] = result['item']['name'];
            item['typeLine'] = result['item']['typeLine'];
            item['indexed'] = result['listing']['indexed'];
            item['account'] = {'name':""};
            item['account']['name'] = result['listing']['account']['lastCharacterName'];
            DateTime dt = DateTime.parse(item['indexed']);
            item['indexed'] = new DateFormat("yyyy-MM-dd").format(dt);
            if(item['typeLine']!="") {
              item['typeLine']="<"+item['typeLine']+'>';
            }
            item['sockets'] = executeSockets(result['item']['sockets']);
            item['ilvl'] = result['item']['ilvl'];
            item['frameType'] = result['item']['frameType'];
            if(item['frameType'] > 5)
              item['frameType'] = 5;
            item['implicitMods'] = executeMods(result['item']['implicitMods']);
            item['explicitMods'] = executeMods(result['item']['explicitMods']);
            if(result['item']['identified']==false)
              item['explicitMods'] = "未鑑定";
            item['corrupted'] = result['item']['corrupted'];
            if(item['corrupted']==null)
              item['corrupted'] = false;
            displayItem[id[i]]=item;
          }
        }
      }).whenComplete(
        ()=>setState(() {}));
    }
  }
  
}
