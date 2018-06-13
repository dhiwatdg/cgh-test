// Creates a matrix of points making a wireframe tetrahedron centered in the origin
// Inputs:
// tSize
//  - 'radius' of the tetrahedron
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
function points = generateTetrahedron(tSize, DeltaLine)
  pointA = [ 1,  0, -1/sqrt(2)] * tSize;
  pointB = [-1,  0, -1/sqrt(2)] * tSize;
  pointC = [ 0, -1,  1/sqrt(2)] * tSize;
  pointD = [ 0,  1,  1/sqrt(2)] * tSize;
  points = generateLine(pointA, pointB, DeltaLine);
  points = [points; generateLine(pointB, pointC, DeltaLine)];
  points = [points; generateLine(pointC, pointA, DeltaLine)];
  points = [points; generateLine(pointA, pointD, DeltaLine)];
  points = [points; generateLine(pointB, pointD, DeltaLine)];
  points = [points; generateLine(pointC, pointD, DeltaLine)];
end