% Draws grid on a plot. 
% For Octave/MATLAB/Scilab compatibility.
%
% Inputs:
% gridColor
%  - Optional, grid color, e.g. a RGB triplet.
%  - Currently ignored in Scilab.
% gridAlpha
%  - Optional, scalar, grid alpha value.
%  - Currently ignored in Scilab.
%
% NOTES
% TODO: Support color and alpha in Scilab.
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
function gridOn(gridColor, gridAlpha)
  grid on;                                %% SCILAB %%  xgrid();
  if (nargin >= 1)                        %% SCILAB %%  // empty
    set(gca(), 'gridcolor', gridColor);   %% SCILAB %%  // empty
  end                                     %% SCILAB %%  // empty
  if (nargin >= 2)                        %% SCILAB %%  // empty
    set(gca(), 'gridalpha', gridAlpha);   %% SCILAB %%  // empty    
  end                                     %% SCILAB %%  // empty
end