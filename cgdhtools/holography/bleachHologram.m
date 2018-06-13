% Converts a real matrix with transmittance values to a complex matrix with
% phase change values. Intended for hologram bleaching.
%
% Inputs:
% hologram 
%  - a real matrix
%  - It should be normalized (values in range [0,1]). Otherwise, maxPhaseChange 
%    does not mean 'maximum phase change'.
% maxPhaseChange
%  - phase change [radians] for a value 1 in the hologram
%  - maxPhaseChange = 2*pi leads to full phase modulation if the hologram is
%    normalized.
%  - defaults to 2*pi
%
% Outputs:
% Complex matrix of the same size as hologram.
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
function bleached = bleachHologram(hologram, maxPhaseChange)
  % Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = pi;

  if (nargin < 2)
    maxPhaseChange = 2*piNumber;
  end

  bleached = exp(imagUnit * maxPhaseChange * hologram);
end