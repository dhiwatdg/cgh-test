% Draws a color bar. It is an Octave/MATLAB/Scilab workaround
% In Octave/MATLAB, limits of the colorbar are calculated automatically.
% In Scilab, they must be provided.
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
function drawColorbar(limits)
  if (limits(1) == 0 && limits(2) == 360)     
    h = colorbar('EastOutside');              %% SCILAB %%     colorbar(limits(1), limits(2), fmt = '%.0f deg');
    set(h, 'ytick', [0, 90, 180, 270, 360]);  %% SCILAB %%   // empty
    set(h, 'yticklabel', ...                  %% SCILAB %%   // empty
      {'0 deg', '90 deg', '180 deg', ...      %% SCILAB %%   // empty
       '270 deg', '360 deg'});                %% SCILAB %%   // empty
  else
    h = colorbar('EastOutside');              %% SCILAB %%     colorbar(limits(1), limits(2));
  end
end