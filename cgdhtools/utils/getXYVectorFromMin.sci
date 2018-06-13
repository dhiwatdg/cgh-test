// Calculates x,y coordinates of samples inside a rectangle with given corner
//
// Inputs:
// matrixSize
//  - Vector [rows,columns], sizes of output vectors.
// delta
//  - Sampling distance; either a number or [deltaY,deltaX] vector
// positionMin 
//  - 3-D vector (x, y, z) with position of the rectangle center
//
// Outputs:
// x,y
//  - Vectors with x and y coordinates
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
function [x, y] = getXYVectorFromMin(matrixSize, delta, positionMin)
  deltaYX = getDeltaYX(delta);
  x = (0:matrixSize(2)-1)*deltaYX(2) + positionMin(1);
  y = (0:matrixSize(1)-1)*deltaYX(1) + positionMin(2);
end