library search_widget;

import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:search_widget/widget/no_item_found.dart';

typedef QueryListItemBuilder<T> = Widget Function(T item);
typedef SelectedItemBuilder<T> = Widget Function(
  T item,
  VoidCallback deleteSelectedItem,
);
typedef QueryBuilder<T> = List<T> Function(
  String query,
  List<T> list,
);
typedef TextFieldBuilder = Widget Function(
  TextEditingController controller,
  FocusNode focus,
);

class SearchWidget<T> extends StatefulWidget {
  final List<T> dataList;
  final QueryListItemBuilder<T> popupListItemBuilder;
  final SelectedItemBuilder<T> selectedItemBuilder;
  final hideSearchBoxWhenItemSelected;
  final double listContainerHeight;
  final QueryBuilder<T> queryBuilder;
  final TextFieldBuilder textFieldBuilder;
  final Widget noItemsFoundWidget;

  SearchWidget({
    Key key,
    @required this.dataList,
    @required this.popupListItemBuilder,
    @required this.selectedItemBuilder,
    this.hideSearchBoxWhenItemSelected = false,
    this.listContainerHeight,
    @required this.queryBuilder,
    this.noItemsFoundWidget,
    this.textFieldBuilder,
  }) : super(key: key);

  @override
  MySingleChoiceSearchState<T> createState() => MySingleChoiceSearchState<T>();
}

class MySingleChoiceSearchState<T> extends State<SearchWidget<T>> {
  final _controller = TextEditingController();
  List<T> _list;
  List<T> _tempList;
  bool isFocused;
  FocusNode _focusNode;
  ValueNotifier<T> notifier;
  bool isRequiredCheckFailed;
  Widget textField;
  OverlayEntry overlayEntry;
  bool showTextBox = false;
  double listContainerHeight;
  final LayerLink _layerLink = LayerLink();
  final textBoxHeight = 48.0;
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    _tempList = List<T>();
    notifier = ValueNotifier(null);
    _focusNode = FocusNode();
    isFocused = false;
    _list = List<T>.from(widget.dataList);
    _tempList.addAll(_list);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _controller.clear();
        if (overlayEntry != null) overlayEntry.remove();
        overlayEntry = null;
      } else {
        _tempList.clear();
        _tempList.addAll(_list);
        if (overlayEntry == null)
          onTap();
        else
          overlayEntry.markNeedsBuild();
      }
    });
    _controller.addListener(() {
      var text = _controller.text;
      if (text.trim().length > 0) {
        _tempList.clear();
        var filterList;
        filterList = widget.queryBuilder(text, widget.dataList);
        if (filterList == null) {
          throw Exception(
            "Filtered List cannot be null. Pass empty list instead",
          );
        }
        _tempList.addAll(filterList);
        if (overlayEntry == null)
          onTap();
        else
          overlayEntry.markNeedsBuild();
      } else {
        _tempList.clear();
        _tempList.addAll(_list);
        if (overlayEntry !=null)
          overlayEntry.markNeedsBuild();
      }
    });
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        if (!visible) _focusNode.unfocus();
      },
    );
  }

  @override
  void didUpdateWidget(SearchWidget oldWidget) {
    if (oldWidget.dataList != widget.dataList) init();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    listContainerHeight =
        widget.listContainerHeight ?? MediaQuery
            .of(context)
            .size
            .height / 4;
    textField = widget.textFieldBuilder != null
        ? widget.textFieldBuilder(_controller, _focusNode)
        : Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: new TextStyle(fontSize: 16, color: Colors.grey[600]),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x4437474F)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme
                .of(context)
                .primaryColor),
          ),
          suffixIcon: Icon(Icons.search),
          border: InputBorder.none,
          hintText: "Search here...",
          contentPadding: EdgeInsets.only(
            left: 16,
            right: 20,
            top: 14,
            bottom: 14,
          ),
        ),
      ),
    );

    Column column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        (widget.hideSearchBoxWhenItemSelected && notifier.value != null)
            ? SizedBox(height: 0.0)
            : CompositedTransformTarget(
                link: this._layerLink,
                child: textField,
              ),
              /*
        notifier.value != null
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: widget.selectedItemBuilder(
                  notifier.value,
                  onDeleteSelectedItem,
                ),
              )
            : SizedBox(height: 0.0),
            */
      ],
    );
    return column;
  }

  void onDropDownItemTap(T item) {
    if (overlayEntry != null) overlayEntry.remove();
    overlayEntry = null;
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      notifier.value = item;
      widget.selectedItemBuilder(
                  notifier.value,
                  onDeleteSelectedItem,
                );
      isFocused = false;
      isRequiredCheckFailed = false;
    });
  }

  void onTap() {
    final RenderBox textFieldRenderBox = context.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    final width = textFieldRenderBox.size.width;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        textFieldRenderBox.localToGlobal(
          textFieldRenderBox.size.topLeft(Offset.zero),
          ancestor: overlay,
        ),
        textFieldRenderBox.localToGlobal(
          textFieldRenderBox.size.topRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
    overlayEntry = OverlayEntry(
      builder: (context) {
        var height = (MediaQuery.of(context).size.height);
        return Positioned(
          left: position.left,
          width: width,
          child: CompositedTransformFollower(
            offset: Offset(
              0,
              height - position.bottom < listContainerHeight
                  ? (textBoxHeight + 6.0)
                  : -(listContainerHeight - 8.0),
            ),
            showWhenUnlinked: false,
            link: this._layerLink,
            child: Container(
              height: listContainerHeight,
              margin: EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                child: _tempList.length > 0
                    ? Scrollbar(
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          separatorBuilder: (context, index) => Divider(
                                height: 1,
                              ),
                          itemBuilder: (context, index) => Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  child: widget.popupListItemBuilder(
                                    _tempList.elementAt(index),
                                  ),
                                  onTap: () =>
                                      onDropDownItemTap(_tempList[index]),
                                ),
                              ),
                          itemCount: _tempList.length,
                        ),
                      )
                    : widget.noItemsFoundWidget != null
                        ? Center(
                            child: widget.noItemsFoundWidget,
                          )
                        : NoItemFound(),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(overlayEntry);
  }

  void onDeleteSelectedItem() {
    setState(() => notifier.value = null);
  }
}
