import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:collection';
import 'dart:convert';

class api {
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
  String currencyUrl;
  Map currencyIcon;
  Map<String, Object> displayItem = new HashMap();
  String submitText = "";
  String linksmin;
  String linksmax;
  bool first;
  Alert nullAlert;
  bool searchflag;
  String filtertext = "";
  Dio dio = new Dio();
  api() {
    currencyUrl = imgUrl + "Currency/";
    currencyIcon = {
      "chaos": currencyUrl + "CurrencyRerollRare.png",
      "exa": currencyUrl + "CurrencyAddModToRare.png",
      "fusing": currencyUrl + "CurrencyRerollSocketLinks.png"
    };
  }
  void search(BuildContext context) async {
    await searchMarket(this.submitText, context);
    if (itemId.length == 0) {
      nullAlert.show();
    } else {
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

  void searchMarket(String value, BuildContext context) async {
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
        if (itemId.length != 0) displayItem = {};
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
