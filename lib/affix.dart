class affixDetail {
  String id;
  String text;
  String type;
  affixDetail(id, text, type) {
    this.id = id;
    this.text = text;
    this.type = type;
  }
}

class affix {
  String label;
  affixDetail entries;
  affix(label, entries) {
    this.label = label;
    this.entries = entries;
  }
}
