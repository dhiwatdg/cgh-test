// Creates a matrix of points making a wireframe cube centered in the origin
//
// Inputs:
// tSize
//  - 'radius' of the cube
// DeltaLine
//  - The points on the edges are separated by approximately DeltaLine.
//
// Outputs:
// points
//  - Matrix of 3-D points, each row makes a (x, y, z) point
//
// ---------------------------------------------
//
//  CGDH TOOLS
//  Petr Lobaz, lobaz@kiv.zcu.cz
//  Faculty of Applied Sciences, University of West Bohemia 
//  Pilsen, Czech Republic
//
//  Check http://holo.zcu.cz for more details and scripts.
//
// ---------------------------------------------
function points = generateCube(tSize, DeltaLine)
  pointA = [ -1, -1, -1 ] * tSize;
  pointB = [  1, -1, -1 ] * tSize;
  pointC = [  1,  1, -1 ] * tSize;
  pointD = [ -1,  1, -1 ] * tSize;
  
  pointE = [ -1, -1,  1 ] * tSize;
  pointF = [  1, -1,  1 ] * tSize;
  pointG = [  1,  1,  1 ] * tSize;
  pointH = [ -1,  1,  1 ] * tSize;
  
  points = generateLine(pointA, pointB, DeltaLine);
  points = [points; generateLine(pointB, pointC, DeltaLine)];
  points = [points; generateLine(pointC, pointD, DeltaLine)];
  points = [points; generateLine(pointD, pointA, DeltaLine)];
  
  points = [points; generateLine(pointE, pointF, DeltaLine)];
  points = [points; generateLine(pointF, pointG, DeltaLine)];
  points = [points; generateLine(pointG, pointH, DeltaLine)];
  points = [points; generateLine(pointH, pointE, DeltaLine)];

  points = [points; generateLine(pointE, pointA, DeltaLine)];
  points = [points; generateLine(pointF, pointB, DeltaLine)];
  points = [points; generateLine(pointG, pointC, DeltaLine)];
  points = [points; generateLine(pointH, pointD, DeltaLine)];
end