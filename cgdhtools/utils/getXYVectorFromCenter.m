% Calculates x,y coordinates of samples inside a rectangle with given center
%
% Inputs:
% matrixSize
%  - Vector [rows, columns], sizes of output vectors
% delta
%  - Sampling distance; either a number or [deltaY,deltaX] vector
% positionCenter 
%  - 3-D vector (x, y, z) with position of the rectangle center
%
% Outputs:
% x,y
%  - Vectors with x and y coordinates
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
function [x, y] = getXYVectorFromCenter(matrixSize, delta, positionCenter)
  deltaYX = getDeltaYX(delta);
  positionMin = centerToMin(positionCenter, matrixSize, deltaYX);
  [x, y] = getXYVectorFromMin(matrixSize, deltaYX, positionMin);
end