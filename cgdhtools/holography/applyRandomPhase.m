% Applies random phase to a matrix (image)
%
% Inputs:
% img
%  - a real or complex 2-D matrix
% maxPhase
%  - each matrix value is multiplied by exp(1j * pi * random() * maxPhase), i.e.
%    maxPhase = 0 does not change the matrix,
%    maxPhase = 2*pi makes the phase completely random
%  - defaults to 2*pi
%
% Outputs:
% Modified matrix of the same size.
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
function out = applyRandomPhase(img, maxPhase)
  % Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = pi;
  
  if (nargin < 2)
    maxPhase = 2*piNumber;
  end
  
  out = img .* exp(imagUnit * maxPhase * rand(size(img, 1), size(img, 2)));
end