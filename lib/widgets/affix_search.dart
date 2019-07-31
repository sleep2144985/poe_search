import 'package:flutter/material.dart';
import 'package:poe_search/affix.dart';
import 'package:search_widget/search_widget.dart';
Widget affix_search(List<affix> datalist, BuildContext context, void selectedevent(affix selectedItem)) {
    return SearchWidget<affix>(
                dataList: datalist,
                hideSearchBoxWhenItemSelected: false,
                listContainerHeight: MediaQuery.of(context).size.height / 4,
                queryBuilder: (String query, List<affix> list) {
                  return list.where((affix item) => item.entries.text.toLowerCase().contains(query.toLowerCase())).toList();
                },
                popupListItemBuilder: (affix item) {
                  return PopupListItemWidget(item);
                },
                selectedItemBuilder: (affix selectedItem, VoidCallback deleteSelectedItem) {
                  print(selectedItem.entries.text);
                  selectedevent(selectedItem);
                  return SizedBox(height: 0.0);
                },
                // widget customization
                noItemsFoundWidget: NoItemsFound(),
                textFieldBuilder: (TextEditingController controller, FocusNode focusNode) {
                  return MyTextField(controller, focusNode);
                },
              );
}

class PopupListItemWidget extends StatelessWidget {
  final affix item;

  PopupListItemWidget(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        item.entries.text,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}

class NoItemsFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.folder_open,
            size: 24,
            color: Colors.grey[900].withOpacity(0.7),
          ),
          SizedBox(width: 10.0),
          Text(
            "找不到該詞墜",
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey[900].withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectedItemWidget extends StatelessWidget {
  final affix selectedItem;
  final VoidCallback deleteSelectedItem;

  SelectedItemWidget(this.selectedItem, this.deleteSelectedItem);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 2.0,
        horizontal: 4.0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 8,
              ),
              child: Text(
                selectedItem.entries.text,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 22),
            color: Colors.grey[700],
            onPressed: deleteSelectedItem,
          ),
        ],
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  MyTextField(this.controller, this.focusNode);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: new TextStyle(fontSize: 16, color: Colors.grey[600]),
        decoration: InputDecoration(
          border: InputBorder.none,
            hintText: "+ 新增數值過濾",
            fillColor: Color(0xffe2e2e2),
            filled: true
        ),
      ),
    );
  }
}