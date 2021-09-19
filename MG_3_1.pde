// right-hand side of heart
float[] HeartX = { 0,  0,  0,  0,  0, 10, 20, 30, 18, 13,  8,  3, 0 };
float[] HeartY = { 0, 12, 26, 34, 42, 54, 46, 38, 30, 25, 20, 14, 0 };
float[] PathX, PathY;        // the path followed by a point
int NumDrops = 35;           // must be even
int TrailSteps = 13;         // number of circles drawn to make a trail
float TrailLength = 20;      // the length of the trail
boolean ShowStroke = false;  // draw strokes around circles?
    
void setup() {
  size(600, 600);
  smooth();
  PathX = new float[HeartX.length];  // We only need to store a single
  PathY = new float[HeartY.length];  // copy of the path
}

// Determine the size of the path followed by this point.  The
// width and height come from the path number.  If leftSide is
// true, then we flip the path in X to get the left-hand side.
// The numbers here are tuned by hand for a graphics window that
// is 600 by 600 pixels (see the call to size() in setup()).
void makePath(int pathNumber, boolean leftSide) {  
  float w = map(pathNumber, 0, NumDrops,  30,  300); 
  float h = map(pathNumber, 0, NumDrops, -54, -540);
  if (leftSide) w = -w;
  fillPath(300, 500, w, h);
}

// Fill in the Path arrays with the Heart X and Y, but move and
// scale them for the given origin, width, and height.
void fillPath(float originX, float originY, float wid, float hgt) {
  for (int i=0; i<HeartX.length; i++) {
      PathX[i] = map(HeartX[i], 0, 30, originX, originX+wid);
      PathY[i] = map(HeartY[i], 0, 54, originY, originY+hgt);
    }
}

// Find a point on the curve held in Path.  The variable
// fullPathT holds a value from 0 to 1 over the entire curve.
// The array p is 2 elements long, and holds the x and y we find.
void pointOnPath(float fullPathT, float[] p) {
  // standard stuff for finding the right segment and t in that segment
  int numSegments = int((PathX.length-1)/3.0);
  float tInSegments = fullPathT * numSegments;
  int firstIndex = 3 * int(tInSegments);
  float localT = tInSegments - int(tInSegments);
  // find the point on this segment
  if (firstIndex > PathX.length-4) {  // boundary case for fullPathT=1
    pointOnSegment(PathX.length-4, 1, p);
    } else {
    pointOnSegment(firstIndex, localT, p);
  }
}
  
// Using the Path array, get the segment starting at index i and
// a value of t from 0 to 1 over the segment to fill in the float
// array p with the x and y values of the curve at this point.
void pointOnSegment(int i, float t, float[] p) {  
  p[0] = bezierPoint(PathX[i], PathX[i+1], PathX[i+2], PathX[i+3], t);
  p[1] = bezierPoint(PathY[i], PathY[i+1], PathY[i+2], PathY[i+3], t);  
}
    
// Draw the point with this path number, using this color.  We
// draw a bunch of points to create the "trail" it leaves behind.
void drawMovingPoint(int pathNumber, color clr) {
  float speed = pathNumber*1.4/10000.0;  // numbers tuned by eye 
  float trailDistance = TrailLength*speed;
  float position = speed * frameCount;
  while (position > 1) position -= 1;    // wrap around the curve
  float[] p = { 0, 0 };                  // this will be our point
  for (int i=0; i<TrailSteps; i++) {
    // we find "oldt", which is the t value i steps ago
    float oldt = position - map(i, 0, TrailSteps-1, 0, trailDistance);
    if (oldt >= 0) {
      float opacity = map(i, 0, TrailSteps-1, 255, 0);  // fade out 
      fill(red(clr), green(clr), blue(clr), opacity);
      pointOnPath(oldt, p);
      ellipse(p[0], p[1], 30, 30);
    }
  } 
}

void draw() {
  background(210, 225, 230);
  color bottomColor = color(253, 231, 76);
  color topColor = color(91, 192, 235);
  if (ShowStroke) stroke(0);
             else noStroke();
  for (int i=0; i<NumDrops; i+=2) {
     colorMode(HSB);
     color pointColor = lerpColor(bottomColor, 
                                  topColor, map(i, 0, NumDrops, 0, 1));
     colorMode(RGB);
     // for every point, create the left and right sides and draw the trail
     makePath(i, false);
     drawMovingPoint(i, pointColor);
     makePath(i+1, true);
     drawMovingPoint(i+1, pointColor);
  }
}

void keyPressed() {
  if (key == 'n') NumDrops = max(2, NumDrops-2); 
  if (key == 'N') NumDrops += 2;
  if (key == 's') TrailSteps = max(0, TrailSteps-1);
  if (key == 'S') TrailSteps++;
  if (key == 'l') TrailLength = max(1, TrailLength-1);
  if (key == 'L') TrailLength++;
  if (key == 'h') ShowStroke = !ShowStroke;
}
