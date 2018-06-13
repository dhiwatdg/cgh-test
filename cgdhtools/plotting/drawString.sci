// Draws a boxed string in a current figure. 
// For Octave/MATLAB/Scilab compatibility.
//
// Inputs:
// x, y
//  - Scalars, coordinates of the text in the figure.
// str
//  - String to draw.
// stringColor
//  - Color of the string. Not supported in Scilab.
// horizAlign
//  - Horizontal alignment of the string.
//  - Can be 'left', 'center' or 'right'.
// vertAlign
//  - Vertical alignment of the string.
//  - Can be 'top', 'middle' or 'bottom'.
//
// NOTES
// TODO: Support color in Scilab.
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
function drawString(x, y, str, stringColor, horizAlign, vertAlign)
     
  rct = xstringl(x, y, str);
  switch (horizAlign)
case 'left'
    case 'center'
      rct(1) = rct(1) - rct(3) / 2;
    case 'right'
      rct(1) = rct(1) - rct(3);
    else
      error('unknown horizontal align mode');
  end
  switch (vertAlign)
    case 'top'
      rct(2) = rct(2) - 2*rct(4);
    case 'middle'
      rct(2) = rct(2) - 1.5 * rct(4);
    case 'bottom'
      rct(2) = rct(2) - rct(4);
    else
      error('unknown vertical align mode');
  end
  xstring(rct(1), rct(2), str);
  gce().box = 'on';
  gce().fill_mode = 'on';
  gce().clip_state = 'off';     
end
