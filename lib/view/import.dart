library writecode.view;

import 'dart:math';
import 'package:writecode/source/import.dart' as source;
import 'package:writecode/style/import.dart' as style;

part 'line.dart';
part 'cursor.dart';

class View {
  View(this._source);

  int _width = 80;

  int get width => _width;

  set width(int aNew) => _width = aNew;

  int _height = 60;

  int get height => _height;

  set height(int aNew) => _height = aNew;

  bool _wrap = true;

  bool get wrap => _wrap;

  set wrap(bool aNew) => _wrap = aNew;

  bool _commandMode = false;

  bool get commandMode => _commandMode;

  set commandMode(bool aNew) => _commandMode = aNew;

  bool _replaceMode = false;

  bool get replaceMode => _replaceMode;

  set replaceMode(bool aNew) => _replaceMode = aNew;

  final source.Source _source;

  final Cursor _cursor = new Cursor();

  Cursor get cursor => _cursor;

  int _startLine = 0;

  void updateView() {
    if (_cursor.line < _startLine) {
      _startLine = _cursor.line;
    }

    _prepareLines();

    if (_cursor.line >= (_startLine + _lines.length)) {
      _startLine = _cursor.line;
      _prepareLines();
    }
  }

  void _prepareLines() {
    int lVirtualLineCount = 0;

    List<Line> lLines = <Line>[];

    final int lMaxLines = min(height, _source.lineCount);

    for (int cIdx = 0; cIdx < lMaxLines; cIdx++) {
      int bLineNum = _startLine + cIdx;
      final String bLineTxt = _source.getLine(_startLine + cIdx);
      Line bLine = new Line(bLineNum, bLineTxt, [], null);
      lLines.add(bLine);

      lVirtualLineCount += (bLineTxt.length / height).ceil();

      if (lVirtualLineCount >= height) {
        break;
      }
    }

    _lines = lLines;
    _numVirtualLines = lVirtualLineCount;
  }

  int _numVirtualLines = 0;

  List<Line> _lines = <Line>[];

  List<Line> get lines => _lines;

  void moveCursorNextChar() {
    final String lLine = _source.getLine(cursor.line);

    if (_cursor.col >= (lLine.length - 1)) {
      if (_cursor.line < (_source.lineCount - 1)) {
        _cursor.advanceLineBeginning();
      } else {
        _cursor.col = lLine.length - 1;
      }
    } else {
      _cursor.advanceChar();
    }

    updateView();
  }

  void moveCursorPrevChar() {
    if (_cursor.col == 0) {
      if (_cursor.line > 0) {
        _cursor.retreatLinePos(_source.getLine(_cursor.line - 1).length - 1);
      }
    } else {
      _cursor.retreatChar();
    }

    updateView();
  }

  void moveCursorNextWord() {
    final String aLine = _source.getLine(_cursor.line);

    if (_cursor.col >= (aLine.length - 1)) {
      _cursor.advanceLineBeginning();
    } else {
      final int lPos = aLine.indexOf(new RegExp("[^a-zA-Z\d]"), _cursor.col);
      if (!lPos.isNegative) {
        _cursor.col = lPos;
      } else {
        _cursor.col = aLine.length - 1;
      }
    }

    updateView();
  }

  void moveCursorPrevWord() {
    final String aLine = _source.getLine(_cursor.line);

    if (_cursor.col == 0) {
      _cursor.retreatLinePos(_source.getLine(_cursor.line - 1).length - 1);
    } else {
      final int lPos =
          aLine.lastIndexOf(new RegExp("[^a-zA-Z\d]"), _cursor.col);
      if (!lPos.isNegative) {
        _cursor.col = lPos;
      } else {
        _cursor.col = 0;
      }
    }

    updateView();
  }

  void moveCursorNextLine() {
    if (_cursor.line >= (_source.lineCount - 1)) {
      _cursor.line = _source.lineCount - 1;
      _cursor.col = _source.getLine(_source.lineCount - 1).length - 1;
    } else {
      _cursor.advanceLine();
      if (_source.getLine(_cursor.line).length >= _cursor.col) {
        _cursor.col = _source.getLine(_cursor.line).length - 1;
      }
    }

    updateView();
  }

  void moveCursorPrevLine() {
    if (_cursor.line <= 0) {
      _cursor.line = 0;
      _cursor.col = 0;
    } else {
      _cursor.retreatLine();
      if (_source.getLine(_cursor.line).length >= _cursor.col) {
        _cursor.col = _source.getLine(_cursor.line).length - 1;
      }
    }

    updateView();
  }

  void moveCursorNextPage() {
    int lNewLineNum = _cursor.line + height;

    if (lNewLineNum >= _source.lineCount) {
      lNewLineNum = _source.lineCount;
    }

    _cursor.gotoLine(lNewLineNum);

    updateView();
  }

  void moveCursorPrevPage() {
    int lNewLineNum = _cursor.line - height;

    if (lNewLineNum < 0) {
      lNewLineNum = 0;
    }

    _cursor.gotoLine(lNewLineNum);

    updateView();
  }

  void setCursorPos(int aLine, int aCol) {
    //TODO validate

    _cursor.line = aLine;
    _cursor.col = aCol;

    updateView();
  }

  /// Removes current char
  void removeChar() {
    String lCurLine = _source.getLine(_cursor.line);
    if (lCurLine.length == 0) {
      return;
    }

    if (_cursor.col >= (lCurLine.length - 1)) {
      lCurLine = lCurLine.substring(0, lCurLine.length - 1);
    } else {
      lCurLine = lCurLine.substring(0, _cursor.col) +
          lCurLine.substring(_cursor.col + 1);
    }

    _source.changeLine(_cursor.line, lCurLine);

    updateView();
  }

  /// Removes current word
  void removeWord() {
    String lCurLine = _source.getLine(_cursor.line);
    if (lCurLine.length == 0) {
      return;
    }

    if (lCurLine[_cursor.col] == ' ') {
      //TODO
    } else {
      //TODO
    }
    //TODO

    _source.changeLine(_cursor.line, lCurLine);

    updateView();
  }

  void insertChar(int aCharCode) {
    String lCurLine = _source.getLine(_cursor.line);
    if (lCurLine.length == 0) {
      lCurLine = new String.fromCharCode(aCharCode);
    } else if (_cursor.col >= (lCurLine.length - 1)) {
      lCurLine = lCurLine + new String.fromCharCode(aCharCode);
    } else {
      lCurLine = lCurLine.substring(0, _cursor.col) + new String.fromCharCode(aCharCode) +
          lCurLine.substring(_cursor.col);
    }

    _source.changeLine(_cursor.line, lCurLine);

    moveCursorNextChar();
  }

  /// Removed remaining word
  void removeWordRemaining() {
    String lCurLine = _source.getLine(_cursor.line);
    if (lCurLine.length == 0) {
      return;
    }

    //TODO

    _source.changeLine(_cursor.line, lCurLine);

    updateView();
  }

  void removeLine() {
    _source.removeLine(_cursor.line);

    if (_cursor.line >= _source.lineCount) {
      _cursor.line = _source.lineCount - 1;
    }

    _cursor.col = 0;

    updateView();
  }

  void processKeyInput(int aKeyCode, int aCharCode, bool aShift, bool aCtrl, bool aAlt, bool aMeta) {
    if(commandMode) {
      if (aCtrl) {
        //Commands

        //TODO
      } else {
        if(kKeyCodeI == 73) {
          commandMode = false;
        }
        //TODO
      }
    } else {
      if (aCtrl) {
        //Commands

        //TODO
      } else {
        if(aKeyCode == kKeyCodeEsc) {
          commandMode = true;
        } else if(aKeyCode == kKeyLeft) {
          moveCursorPrevChar();
        } else if(aKeyCode == kKeyRight) {
          moveCursorNextChar();
        } else if(aKeyCode == kKeyUp) {
          moveCursorPrevLine();
        } else if(aKeyCode == kKeyDown) {
          moveCursorNextLine();
        } else {
          insertChar(aCharCode);
        }
      }
    }
  }
}
const int kKeyLeft = 37;
const int kKeyUp = 38;
const int kKeyRight = 39;
const int kKeyDown = 40;
const int kKeyCodeEsc = 27;
const int kKeyCodeI = 73;