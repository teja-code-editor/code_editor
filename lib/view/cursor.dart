part of writecode.view;

class Cursor {
  int line = 0;

  int col = 0;

  void advanceLineBeginning() {
    line++;
    col = 0;
  }

  void advanceChar() {
    col++;
  }

  void advanceLine() {
    line++;
  }

  void retreatChar() {
    col--;
  }

  void retreatLine() {
    line--;
  }

  void retreatLinePos(int aCol) {
    line--;
    col = aCol;
  }

  void gotoLine(int aLine) {
    line = aLine;
    col = 0;
  }
}