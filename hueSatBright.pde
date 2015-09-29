/*

Color can always convert from RGB to HSB, but they can't
always convert from HSB to RGB. When saturation or brightness
get close to zero hue information is lost or irrelavant.
This class will always hold a value for hue or -1 for 
undefined hue. So as color values are being calculated
the hue value will remain even when saturation or brightness
go to zero.

*/

class HSBColor {
  int hue;
  int sat;  // saturation
  int brt;  // brightness
  
  HSBColor() {
    // set object to black of indefined hue
    hue = -1;  // undefined
    sat = 100; // 100% saturation
    brt = 0; // 0% brightness
  }
  
  HSBColor(int hue, int sat, int brt) {this.hue = hue; this.sat = sat; this.brt = brt;}

  HSBColor(HSBColor another) {
    this.hue = another.hue;
    this.sat = another.sat;
    this.brt = another.brt;
  }


  void combine(int combine, HSBColor clrB) {
    if(hue == -1 && clrB.hue != -1) combine = cLAST;
    switch(combine) {
    case cBLEND:
      blend(clrB);      
      break;
    case cAVERAGE:
      avg(clrB);
      break;
    case cLAST:
      if(clrB.hue == -1) return;
      set(clrB);
      break;
    case cFIRST:
    default:
      break;
    }    
  }

  
  void blend(HSBColor x) {
    //int clrA, clrB;
    int swp, hueBB, hueRange, hueResult;
    // Calculate the hue in between two hues by the shortest distance 
    // along the 360 degree model. 
    swp = 1;
    hueBB = x.hue;    
    // Range can never be more than 180.
    if(hue > hueBB) hueBB += 360;
    hueRange = hueBB - hue;
    
    if(hueRange > 180) {
      swp = -1;
      hueRange = 360 - hueRange;
    }
    
    hueResult = hue + swp * (x.brt * hueRange / 100);
    if(hueResult < 0) hueResult += 360;
    if(hueResult > 360) hueResult -= 360;
    
    // Calculate saturation.
    sat = min(sat, x.sat);

    // Calculate brightness.
    brt = max(brt, x.brt);
  }

  
  void avg(HSBColor x) {
    if(x.hue == -1) return;
    if(hue == -1) {
      hue = x.hue;
      sat = x.sat;
      brt = x.brt; 
      return;
    }
    // average the hue
    hue += 360;
    x.hue += 360;
    if(hue > x.hue) {
      hue = x.hue + ((hue - x.hue) / 2);
    }
    else {
      hue = hue + ((x.hue - hue) / 2);
    }
    hue -= 360;
    sat = (sat + x.sat) / 2;
    brt = (brt + x.brt) / 2;
  }
  

  void reset() {hue = -1; sat = 100; brt = 0;}
  
  void set(int hue, int sat, int brt) {this.hue = hue; this.sat = sat; this.brt = brt;}
  
  void set(HSBColor x) {this.hue = x.hue; this.sat = x.sat; this.brt = x.brt;}
  
  color getColor() {
    int h = hue;
    if(h < 0) h = 0;
    return color(h, sat, brt);
  }
}
