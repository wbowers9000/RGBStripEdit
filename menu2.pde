class menuItem {
  String iText;
  int xPos;
  int yPos;
  int tWidth;
  
  menuItem() {
    iText = "";
    xPos = 0;
    yPos = 0;
    tWidth = 0;
  }
  
  menuItem(String iText, int xPos, int yPos) {
    this.iText = iText;
    this.xPos = xPos;
    this.yPos = yPos;
    this.tWidth = int(textWidth(iText));
  }
  
  void itemDraw() {text(iText, xPos, yPos);}

  boolean itemClicked() {return false;}
}
