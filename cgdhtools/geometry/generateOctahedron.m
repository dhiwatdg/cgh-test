% Creates a matrix of points making a wireframe octahedron centered in the origin
%
% Inputs:
% tSize
%  - 'radius' of the octahedron
% DeltaLine
%  - The points on the edges are separated by approximately DeltaLine.
%
% Outputs:
% points
%  - Matrix of 3-D points, each row makes a (x, y, z) point
%
% ---------------------------------------------
%
%  CGDH TOOLS
%  Petr Lobaz, lobaz@kiv.zcu.cz
%  Faculty of Applied Sciences, University of West Bohemia 
%  Pilsen, Czech Republic
%
%  Check http://holo.zcu.cz for more details and scripts.
%
% ---------------------------------------------
function points = generateOctahedron(tSize, DeltaLine)
  pointA = [  1,  0,  0 ] * tSize;
  pointB = [  0,  1,  0 ] * tSize;
  pointC = [ -1,  0,  0 ] * tSize;
  pointD = [  0, -1,  0 ] * tSize;
  
  pointE = [  0,  0, -1 ] * tSize;
  pointF = [  0,  0,  1 ] * tSize;
  
  points = generateLine(pointA, pointB, DeltaLine);
  points = [points; generateLine(pointB, pointC, DeltaLine)];
  points = [points; generateLine(pointC, pointD, DeltaLine)];
  points = [points; generateLine(pointD, pointA, DeltaLine)];
  
  points = [points; generateLine(pointA, pointE, DeltaLine)];
  points = [points; generateLine(pointB, pointE, DeltaLine)];
  points = [points; generateLine(pointC, pointE, DeltaLine)];
  points = [points; generateLine(pointD, pointE, DeltaLine)];

  points = [points; generateLine(pointA, pointF, DeltaLine)];
  points = [points; generateLine(pointB, pointF, DeltaLine)];
  points = [points; generateLine(pointC, pointF, DeltaLine)];
  points = [points; generateLine(pointD, pointF, DeltaLine)];
end