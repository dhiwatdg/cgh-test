// Draws a line in current figure.
//
// Inputs:
// x         
//  - x coordinates of the line
// y         
//  - y coordinates of the line
// lineColor 
//  - line color (color map index or a string with a named color or a RGB triplet)
// lineWidth 
//  - line width
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
function drawLine(x, y, lineColor, lineWidth)
  if (nargin < 3)
    lineColor = 'black';
  end
  if (nargin < 4)
    lineWidth = 1;
  end
  plot(x, y, 'Foreground', lineColor, 'thickness', lineWidth);
end