library writecode.source;

import 'dart:async';

class LineRange {
  LineRange(this.start, this.end) {
    if (end < start) {
      throw new Exception("Invalid line range!");
    }
  }

  final int start;

  final int end;
}

class SourceChange {
  SourceChange(this.lineRange);

  final LineRange lineRange;
}

class Line {
  Line(this._line);

  String _line;

  String get line => _line;
}

class Source {
  Source(List<String> aLines) {
    for(String cLine in aLines) {
      _lines.add(new Line(cLine));
    }
  }

  List<Line> _lines = new List<Line>();

  int get lineCount => _lines.length;

  String getLine(int aIndex) {
    if(aIndex >= _lines.length) {
      throw new Exception("Line $aIndex not in source!");
    }

    return _lines[aIndex].line;
  }

  void changeLine(int aIndex, String aLine) {
    if (aIndex >= _lines.length) {
      throw new Exception("Line not in source!");
    }

    _lines[aIndex] = new Line(aLine);

    _changeStreamCon.add(new SourceChange(new LineRange(aIndex, aIndex)));
  }

  void addLine(int aIndex, String aLine) {
    if (aIndex > _lines.length) {
      throw new Exception("Line not in source!");
    }

    _lines.insert(aIndex, new Line(aLine));

    _changeStreamCon.add(new SourceChange(new LineRange(aIndex, aIndex)));
  }

  void splitLine(int aIndex, int aCol) {
    if (aIndex >= _lines.length) {
      throw new Exception("Line not in source!");
    }

    final Line lOld = _lines[aIndex];

    if (aCol > lOld.line.length) {
      throw new Exception("Column not in line!");
    }

    _lines[aIndex] = new Line(lOld.line.substring(0, aCol));

    addLine(aIndex + 1, lOld.line.substring(aCol));
  }

  void removeLine(int aIndex) {
    if (aIndex >= _lines.length) {
      throw new Exception("Line not in source!");
    }

    _lines.removeAt(aIndex);

    _changeStreamCon.add(new SourceChange(new LineRange(aIndex, aIndex)));
  }

  StreamController<SourceChange> _changeStreamCon =
      new StreamController<SourceChange>();

  Stream<SourceChange> get onChange => _changeStreamCon.stream;
}
