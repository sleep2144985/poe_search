import 'package:flutter/material.dart';
class Filterpanel {
  /*
  List<Widget> widgets=<Widget>[searchInput((String value) {
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
                          ];*/
}