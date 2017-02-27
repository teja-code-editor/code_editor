part of writecode.view;

class Line {
  Line(this.lineNum, this.text, this.classes, this.sign);

  final int lineNum;

  final String text;

  final List<String> classes;

  final style.LineSign sign;
}