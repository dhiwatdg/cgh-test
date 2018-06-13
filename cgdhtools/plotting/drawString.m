% Draws a boxed string in a current figure. 
% For Octave/MATLAB/Scilab compatibility.
%
% Inputs:
% x, y
%  - Scalars, coordinates of the text in the figure.
% str
%  - String to draw.
% stringColor
%  - Color of the string. Not supported in Scilab.
% horizAlign
%  - Horizontal alignment of the string.
%  - Can be 'left', 'center' or 'right'.
% vertAlign
%  - Vertical alignment of the string.
%  - Can be 'top', 'middle' or 'bottom'.
%
% NOTES
% TODO: Support color in Scilab.
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
function drawString(x, y, str, stringColor, horizAlign, vertAlign)
  text(x, y, str, ...                                  %% SCILAB %%   // empty
     'color', stringColor, 'fontweight', 'bold', ...   %% SCILAB %%   // empty
     'horizontalalignment', horizAlign, ...            %% SCILAB %%   // empty
     'verticalalignment', vertAlign, ...               %% SCILAB %%   // empty 
     'backgroundcolor', [1, 1, 1], ...                 %% SCILAB %%   // empty
     'edgecolor', [0,0,0]);                            %% SCILAB %%   // empty
     
%% SCILAB %%   rct = xstringl(x, y, str);
%% SCILAB %%   switch (horizAlign)
%% SCILAB %% case 'left'
%% SCILAB %%       // empty  
%% SCILAB %%     case 'center'
%% SCILAB %%       rct(1) = rct(1) - rct(3) / 2;
%% SCILAB %%     case 'right'
%% SCILAB %%       rct(1) = rct(1) - rct(3);
%% SCILAB %%     else
%% SCILAB %%       error('unknown horizontal align mode');
%% SCILAB %%   end
%% SCILAB %%   switch (vertAlign)
%% SCILAB %%     case 'top'
%% SCILAB %%       rct(2) = rct(2) - 2*rct(4);
%% SCILAB %%     case 'middle'
%% SCILAB %%       rct(2) = rct(2) - 1.5 * rct(4);
%% SCILAB %%     case 'bottom'
%% SCILAB %%       rct(2) = rct(2) - rct(4);
%% SCILAB %%     else
%% SCILAB %%       error('unknown vertical align mode');
%% SCILAB %%   end
%% SCILAB %%   xstring(rct(1), rct(2), str);
%% SCILAB %%   gce().box = 'on';
%% SCILAB %%   gce().fill_mode = 'on';
%% SCILAB %%   gce().clip_state = 'off';     
end
