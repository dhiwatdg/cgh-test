// Draws a boxed string in a current figure. 
// For Octave/MATLAB/Scilab compatibility.
// 
// Inputs:
// titleString
// - Title string.
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
function drawTitle(titleString)
  title(titleString, 'fontsize', 2, 'fontname', 8);
end