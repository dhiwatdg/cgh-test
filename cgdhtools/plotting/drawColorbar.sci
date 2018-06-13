// Draws a color bar. It is an Octave/MATLAB/Scilab workaround
// In Octave/MATLAB, limits of the colorbar are calculated automatically.
// In Scilab, they must be provided.
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
function drawColorbar(limits)
  if (limits(1) == 0 && limits(2) == 360)     
    colorbar(limits(1), limits(2), fmt = '%.0f deg');
  else
    colorbar(limits(1), limits(2));
  end
end