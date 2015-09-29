/*


parameters:
name: effect name
locationStart: starting location along the string of LEDs
spread: how far the effect will spread
hueStart: starting hue in HSB format, 0 to 360 on the color wheel
hueEnd: end hue
hueDirection: 1 for forward, -1 for reverse 
timeStart: starting time of the effect
duration: effect time length
timeBuild: time it takes for the effect to build, remaining time is the time the effect decays

increase time, sustain time, decay time for brightness and span are determined 
by the effect type
*/


class effect {
  public int locationStart; 
  public int spread;
  public int hueStart; 
  public int hueEnd;
  public int hueDirection; 
  public int timeStart; 
  public int duration;
  public int timeBuild; // remaining time is decay time
  
  public HSBColor[] efAry;
  private int hueRange; // save hue range so we don't recompute
  
  public effect() {
    this.locationStart = 0;
    this.spread = 0;
    this.hueStart = 0;
    this.hueEnd = 0;
    this.hueDirection = 1;
    this.timeStart = 0;
    this.duration = 0;
    this.timeBuild = 0;
    this.efAry = new HSBColor[LEDCnt];
    reset();
  }

  public effect(int locationStart,
                int spread,
                int hueStart,
                int hueEnd,
                int hueDirection,
                int timeStart,
                int duration,
                int timeBuild
                ) {
    this.locationStart = locationStart;
    this.spread = spread;
    this.hueStart = hueStart;
    this.hueEnd = hueEnd;
    if (hueDirection == 0) this.hueDirection = 1;
    else this.hueDirection = hueDirection;
    this.timeStart = timeStart;
    this.duration = duration;
    this.timeBuild = timeBuild;
    this.efAry = new HSBColor[LEDCnt];
    reset();
  }
  
  public effect(effect x) {
    this.locationStart = x.locationStart;
    this.spread = x.spread;
    this.hueStart = x.hueStart;
    this.hueEnd = x.hueEnd;
    if (hueDirection >= 0) 
      this.hueDirection = 1;
    else 
      this.hueDirection = -1;
    this.timeStart = x.timeStart;
    this.duration = x.duration;
    this.timeBuild = x.timeBuild;
    this.efAry = new HSBColor[LEDCnt];
    reset();
  }
  
  void reset() {
    for(int i = 0; i < efAry.length; i++) efAry[i] = new HSBColor();
    hueRange = -1;
  }

  boolean active(int tm) {
    return (tm >= timeStart) && (tm <= (timeStart + duration));
  }
  
  boolean finished(int tm) {
    return (tm > (timeStart + duration));
  }

  public String nameHash() {
    return getClass().getName() + " " + getClass().hashCode();
  }

  public int arrayHash() {
    return efAry.hashCode();
  }  
//
// symetrical effects
//
  boolean dropleteffect2(int tm) {
    int elapsedTime;
    int brightness;
    int hue;
    int halfSpread;
    int halfRange;
    int effRatio;
    int timeRatio;
    HSBColor hsbc = new HSBColor();
    //color c;

    // This method uses fast ratios based on 256. It is just like ratios based upon 100 (%) except
    // you divide by 256 instead of 100. " x >> 8" is quick divide by 256.
    
    // brightness based on time only: brightness = 100 - ((timeRatio256 * 100) >> 8);
    
    if(tm < timeStart) return true;
    elapsedTime = tm - timeStart;    
    if(elapsedTime > duration) return false;
    effRatio = effectRatio(tm);
    timeRatio = elapsedTime * 256 / duration;
    // brightness
    // to convert a number from 0..256 to 0..100 multiply by 100 and divide by 256.
    brightness = (effRatio * 100) >> 8;   
    // hue change
    hue = computeHue(timeRatio); 
    // spread 
    halfSpread = (spread >> 1) + 1;
    halfRange = (halfSpread * effRatio) >> 8;
    
    // clear previous values    
    for(int i = 0; i < efAry.length; i++) efAry[i].set(-1, 100, 0);

    hsbc.set(hue, 100, brightness);
    symmetricalFill(locationStart, halfRange, hsbc);
    return true;
  }
  

  private int computeHue(int ratio) {
    // ratios based on 256
    int hue;
    
    if(hueRange < 0) {  
      hueRange = 360 + (hueEnd - hueStart) * hueDirection;
      if(hueRange >= 360) hueRange = hueRange - 360;
    }
    // current hue
    hue = 360 + hueStart + ((hueRange * ratio) >> 8) * hueDirection;
    while(hue >= 360) hue = hue - 360;
    return hue; 
  }


  private int effectRatio(int tm) {
    // ratios based on 256
    int timeRatio, elapsedTime; 
    //boolean inBuild;
    
    elapsedTime = tm - timeStart;
    if(elapsedTime < timeBuild) {
      // build: go from 0 to max
      timeRatio = elapsedTime * 256 / timeBuild;
    }
    else { 
      elapsedTime = elapsedTime - timeBuild;
      // decay: go from max to 0
      timeRatio = 256 - (elapsedTime * 256 / (duration - timeBuild));  // decay time
    }
    return timeRatio;
  }
  

  void symmetricalFill(int origin, int span, HSBColor clr) {
    int n;
    
    if(origin >= 0 && origin < efAry.length) efAry[origin].set(clr);
    for(int i = 0; i < span; i++) {
      n = origin - i;
      if(n >= 0 && n < efAry.length) efAry[n].set(clr);
      n = origin + i;
      if(n < efAry.length) efAry[n].set(clr);
    }
  }

}


class dropletSustain {
  private int tStart;  // start time
  private int tBuild;  // build time
  private int tSustain;  // sustain time
  private int tDecay;  // decay time
  private int locationStart; 
  private int spread;
  private int hueStart; 
  private int hueEnd;
  private int hueDirection;
  private int duration;
  
  public HSBColor[] efAry;
  private int hueRange; // save hue range so we don't recompute
  
  public dropletSustain() {
    this.tStart = 0;
    this.tBuild = 0;
    this.tSustain = 0;
    this.tDecay = 0;
    this.locationStart = 0;
    this.spread = 0;
    this.hueStart = 0;
    this.hueEnd = 0;
    this.hueDirection = 1;
    this.duration = 0;
    this.efAry = new HSBColor[LEDCnt];
    reset();
  }

  public dropletSustain(
    int tStart,  // start time
    int tBuild,  // build time
    int tSustain,  // sustain time
    int tDecay,  // decay time
    int locationStart,
    int spread,
    int hueStart,
    int hueEnd,
    int hueDirection
    ) {
    this.tStart = tStart;
    this.tBuild = tBuild;
    this.tSustain = tSustain;
    this.tDecay = tDecay;
    this.locationStart = locationStart;
    this.spread = spread;
    this.hueStart = hueStart;
    this.hueEnd = hueEnd;
    if (hueDirection == 0) this.hueDirection = 1;
    else this.hueDirection = hueDirection;
    this.duration = tStart + tBuild + tSustain + tDecay;
    this.efAry = new HSBColor[LEDCnt];
    reset();
  }
  
  void reset() {
    for(int i = 0; i < efAry.length; i++) efAry[i] = new HSBColor();
    hueRange = -1;
  }

  boolean active(int tm) {
    return (tm >= tStart) && (tm < duration);
  }
  
  boolean finished(int tm) {
    return (tm >= (tStart + duration));
  }

  public String nameHash() {
    return getClass().getName() + " " + getClass().hashCode();
  }

  public int arrayHash() {
    return efAry.hashCode();
  }  
//
// symetrical effects
//
// return true if this effect has not yet expired
//
  boolean build(int tm) {
    int elapsedTime;
    int brightness;
    int hue;
    int halfSpread;
    int halfRange;
    int timeRatio;
    HSBColor hsbc = new HSBColor();
    
    if(tm < tStart) return true;  // not yet started 
    elapsedTime = tm - tStart;    
    if(elapsedTime >= (tStart + duration)) return false;
    
    halfSpread = (spread >> 1) + 1;
    if(elapsedTime < (tStart + tBuild)) {
      // compute brightness during build
      brightness = iMapQuick(tm, tStart, (tStart + tBuild), 0, 256);
      halfRange = iMapQuick(tm, tStart, (tStart + tBuild), 0, halfSpread);
    } else if(elapsedTime < (tStart + tBuild + tSustain)) {
      // sustained brightness
      brightness = 255;
      halfRange = halfSpread;
    } else {
      // decay brightness
      brightness = iMap(tm, (tStart + tBuild + tSustain), duration, 256, 0);
      halfRange = iMap(tm, (tStart + tBuild + tSustain), duration, halfSpread, 0); 
    }
    
    timeRatio = elapsedTime * 256 / duration;
    hue = computeHue(timeRatio); 

    // clear previous values    
    for(int i = 0; i < efAry.length; i++) efAry[i].set(-1, 100, 0);

    hsbc.set(hue, 100, brightness);
    symmetricalFill(locationStart, halfRange, hsbc);
    return true;
  }
  

  private int computeHue(int ratio) {
    // ratios based on 256
    int hue;
    
    if(hueRange < 0) {  
      hueRange = 360 + (hueEnd - hueStart) * hueDirection;
      if(hueRange >= 360) hueRange = hueRange - 360;
    }
    // current hue
    hue = 360 + hueStart + ((hueRange * ratio) >> 8) * hueDirection;
    while(hue >= 360) hue = hue - 360;
    return hue; 
  }


  private int effectRatio(int tm) {
    // ratios based on 256
    int timeRatio, elapsedTime; 
    //boolean inBuild;
    
    elapsedTime = tm - tStart;
    if(elapsedTime < tBuild) {
      // build: go from 0 to max
      timeRatio = elapsedTime * 256 / tBuild;
    }
    else { 
      elapsedTime = elapsedTime - tBuild;
      // decay: go from max to 0
      timeRatio = 256 - (elapsedTime * 256 / (duration - tBuild));  // decay time
    }
    return timeRatio;
  }
  

  void symmetricalFill(int origin, int span, HSBColor clr) {
    int n;
    
    if(origin >= 0 && origin < efAry.length) efAry[origin].set(clr);
    for(int i = 0; i < span; i++) {
      n = origin - i;
      if(n >= 0 && n < efAry.length) efAry[n].set(clr);
      n = origin + i;
      if(n < efAry.length) efAry[n].set(clr);
    }
  }
    
  // use only if a1 < a2 and b1 < b2
  int iMapQuick(int v, int a1, int a2, int b1, int b2) {
    int c = a2 - a1;
    int d = b2 - b1;
    
    v = v * d / c;
    v += b1;
    return v;
  }
  
  int iMap(int v, int a1, int a2, int b1, int b2) {
    int m;
    
    if(a1 < a2) {
      a2 = a2 - a1;
      v = v - a1;
      m = a2;
    }
    else {
      a1 = a1 - a2;
      v = v - a2;
      v = a1 - v;
      m = a1;
    }
    if(b1 < b2) {
      b2 = b2 - b1;
      v = v * b2 / m + b1; 
    }
    else {
      b1 = b1 - b2;
      v = v * b1 / m;
      v = b1 - v + b2;
    }
    return v;
  }
}
