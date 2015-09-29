effect efEdit = new effect(10, 8, 180, 180, 1, 0, 300, 0); // inital values for default effect

HSBColor[] refDisp;

final int effectMax = 12;
effect[] eff = new effect[effectMax];
effect ef; // generic effect for keystoke

int effDispItemCount;
int effLineCount = 14;  // 12 effects + 1 reference line + 1 combined line
int effLineWidth = width / LEDCnt;
int xPosLine = (width - effLineWidth * LEDCnt) / 2;
int yHeight = areaOffset / effLineCount;
int yVisible = yHeight * 9 / 10;
 
void drawEffDisp() {
  int yPos = YPosEffect;
  stroke(0);
  // display reference LED line
  rnder.line(refDisp, yPos);
  yPos += YPosEffect;
  // display combined effect LED line
  
  yPos += YPosEffect;
  // display individual effects
  for(int i = 0; i < 12; i++) {
    if(eff[i] != null) {
      eff[i].dropleteffect2(player.position());
      rnder.line(eff[i].efAry, yPos);
      yPos += yHeight;
    }
  }
}
