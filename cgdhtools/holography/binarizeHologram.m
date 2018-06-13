% Binarizes a real matrix (a hologram) by thresholding
%
% Inputs:
% h - a real 2-D matrix
%
% Outputs:
% A binarized matrix, values are 0 or 1.
% The threshold is taken as an average value of the input.
%
% TODO
% Add more thresholding options.
% Add dithering.
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
function out = binarizeHologram(img)
  avg = mean(mean(img));
  out = double((img - avg) > 0);
end
