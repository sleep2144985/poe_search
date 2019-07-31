import 'affix.dart';
import 'package:flutter/material.dart';

class affix_controller {
  affix affixitem;
  TextEditingController mincontroller = new TextEditingController();
  TextEditingController maxcontroller = new TextEditingController();
  affix_controller(affix) {
    this.affixitem = affix;
  }
}
