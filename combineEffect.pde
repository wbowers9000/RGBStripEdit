// "final" is the same as c++ "constant"
// processing does not recognize "enum"
final int cBLEND = 0;
final int cAVERAGE = 1;
final int cFIRST = 2;  // first to appear
final int cLAST = 3;   // last to appear

private static HSBColor[] ceAry;

// Arrays must come in time order, first to last.
// The array in this class holds the accumulation of the effects.

class Combineeffect {
  
  HSBColor clrAcc = new HSBColor();  // color accumulator (because we can't return a non primative)
 
  
  Combineeffect() {
    ceAry = new HSBColor[LEDCnt];
    for(int i = 0; i < ceAry.length; i++) ceAry[i] = new HSBColor();
    resetToZero();
  }

  
  void resetToZero() {
    for(int i = 0; i < ceAry.length; i++) ceAry[i].reset();
  }
  
  
  void get(HSBColor[] aa) {
    for(int i = 0; i < ceAry.length; i++) aa[i].set(ceAry[i]);
  }


  void combine(int combineType, effect ef, int tm) {
    if(ef.active(tm)) combine(combineType, ef.efAry);
  }

  void combine(int combineType, HSBColor [] ica) {
    for(int i = 0; i < ica.length; i++) ceAry[i].combine(combineType, ica[i]);
  }
  
}


class render {
  int effLineCount;  // number of effect lines
  int effLineWidth;  // width of visible portion of effect line
  int xPosLine;  // x positon of visible portion of effect line
  int yHeight;  // effect line height
  int yVisible;  // visible portion of effect line height
  
  render() {
  }

  void displaySetup(int pixelCount) {
    effLineCount = 14;  // 12 effects + 1 reference line + 1 combined line
    effLineWidth = width / pixelCount;
    xPosLine = (width - effLineWidth * pixelCount) / 2;
    yHeight = areaOffset / effLineCount;
    yVisible = yHeight * 9 / 10;
  }

  
  void line(HSBColor[] ary, int yPos) {
    color cc;
    int xpos = xPosLine;
    
    if(ary == null) return;
    for(int i = 0; i < ary.length; i++) {
      cc = ary[i].getColor();
      fill(cc);
      xpos += effLineWidth;
      rect(xpos, yPos, effLineWidth, yVisible);
    }
  }
}
