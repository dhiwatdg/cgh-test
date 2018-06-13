% Creates a matrix of points making a line
%
% Inputs:
% pointA, pointB
%  - Endpoints of the line.
%  - Each endpoint is a 3-D vector (x, y, z)
% DeltaLine
%  - The points on the line are separated by approximately DeltaLine.
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
function points = generateLine(pointA, pointB, DeltaLine)
  lineLength = norm(pointA - pointB);
  pointsCount = ceil(lineLength / DeltaLine);
  points = [linspace(pointA(1), pointB(1), pointsCount); ...
      linspace(pointA(2), pointB(2), pointsCount); ...
      linspace(pointA(3), pointB(3), pointsCount)]';
end