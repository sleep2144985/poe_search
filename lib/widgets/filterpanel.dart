import 'package:flutter/material.dart';
import 'package:poe_search/value_controller.dart';
import 'package:poe_search/widgets/affix_search.dart';
import 'search.dart';
import '../api.dart';
import '../affix.dart';
import 'result.dart';
import 'package:expandable/expandable.dart';
import '../affix_controller.dart';

class Filterpanel extends StatefulWidget {
  Filterpanel({
    Key key,
    this.scrollController,
    this.apitool,
    this.expandableController,
    this.affix_selected,
  }) : super(key: key);
  final ScrollController scrollController;
  final ExpandableController expandableController;
  final api apitool;
  final List<affix_controller> affix_selected;
  @override
  _FilterpanelState createState() => new _FilterpanelState();
}

List<affix> suggestions = new List<affix>();

class _FilterpanelState extends State<Filterpanel> {
  List<Widget> widgets;
  List<Widget> expandedpanel;
  @override
  void initState() {
    widget.apitool.getleagues().then((x) {
      this.setState(() {});
    });
    widget.apitool.getStat().then((affix) {
      suggestions = affix;
      this.setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    api apitool = widget.apitool;
    widgets = <Widget>[
      Container(
          padding: EdgeInsets.only(left: 20.0, top: 10.0),
          child: ExpandablePanel(
              controller: widget.expandableController,
              tapHeaderToExpand: true,
              tapBodyToCollapse: true,
              headerAlignment: ExpandablePanelHeaderAlignment.center,
              header: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "顯示篩選",
                    style: Theme.of(context).textTheme.body2,
                  )),
              expanded: _createItem()))
    ];
    return ListView(
        shrinkWrap: true, physics: ClampingScrollPhysics(), children: widgets);
  }

  ListView _createItem() {
    api apitool = widget.apitool;
    return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: 4 + widget.affix_selected.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                child: Container(
                  width: double.infinity,
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
                );
          }
          if (index == 1) {
            ValueController valueController = new ValueController();
            valueController.mincontroller.text = "1"; 
            return dropDownFilter(apitool.allcurrency, apitool.selectedprice, (String newValue) {
                          apitool.selectedprice = newValue;
                          this.setState(() {});
                        }, valueController.mincontroller, valueController.maxcontroller, (String item) {
              apitool.paymin = valueController.mincontroller.text;
              apitool.paymax = valueController.maxcontroller.text;
            });
          }
          else if (index == 2) {
            ValueController valueController = new ValueController();
            return valueFilter("插槽連結", valueController.mincontroller, valueController.maxcontroller,
                (String item) {
              apitool.linksmin = valueController.mincontroller.text;
              apitool.linksmax = valueController.maxcontroller.text;
            });
          }
          else if (index == 3) {
            print(suggestions.length);
            return Container(
                padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                child: suggestions.length != 0
                    ? affix_search(suggestions, context, (affix selecteditem) {
                        affix_controller controller =
                            affix_controller(selecteditem);
                        if (widget.affix_selected.indexOf(controller) == -1)
                          widget.affix_selected.add(controller);
                        setState(() {});
                      })
                    : null);
          } else {
            affix_controller controller = widget.affix_selected[index - 4];
            return valueFilter(controller.affixitem.entries.text,
                controller.mincontroller, controller.maxcontroller, null, () {
              int index = widget.affix_selected.indexOf(controller);
              widget.affix_selected.removeAt(index);
              setState(() {});
            }, 14);
          }
        });
  }
}
