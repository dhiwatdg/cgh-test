% Loads a greyscale image in a way suitable in further use in CGDH Tools
%
% Inputs:
% fileName
%  - String, a file name.
%
% Outputs:
% Matrix of doubles normalized to range (0, 1).
% The matrix is flipped upside down. This means that the image is compatible
% with 2-D functions sampled to a matrix - both have axis X pointing to the 
% right, axis Y pointing upwards.
% (Common images have the axis Y pointing downwards.)
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
function out = loadImage(fileName)
  out = imread(fileName);
  out = double(out);
  out = out ./ max(max(out));
  out = flipud(out);
end