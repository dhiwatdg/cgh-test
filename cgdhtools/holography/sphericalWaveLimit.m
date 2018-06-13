% Auxiliary function for determination of aliasing-free zone of a spherical wave
%
% Works in single coordinate (X or Y) only.
% See sphericalWave for example of usage.
%
% Inputs:
% centre
%  - Scalar, centre of the spherical wave (X or Y coordinate)
% lambda
%  - The wavelength
% coordMin, coordDelta, indexMax
%  - Scalars (real, positive real, positive integer)
%  - Samples of the spherical wave are being calculated at 
%      coordMin + (index-1)*coordDelta
%    where index is in range 1:indexMax
% lfMax
%  - Scalar, maximal allowed local frequency, usually 1/(2*coordDelta)
% zDistance
%  - If the spherical wave is located at (0, 0, 0), then the calculated samples
%    are located in z = zDistance
%
% Outputs:
% indexStart, indexEnd
%  - Indices of the first and the last samples of aliasing-free zone
%
% NOTES
%  - If the aliasing-free zone is outside range 1:indexMax,
%    then indexStart > indexEnd
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
function [indexStart, indexEnd] = sphericalWaveLimit(centre, lambda, ...
  coordMin, coordDelta, indexMax, lfMax, zDistance)
  
  % sqrt(tmp) will be used for aliasing-free zone determination
  tmp = 1 - lambda^2 * lfMax^2;
  
  if (tmp <= 0)
    % Sampling distance is so fine that no aliasing occurs
    indexStart = 1;
    indexEnd = indexMax;
  else
    % Aliasing might occur.
    % Determine half-width of the aliasing free zone.
    coordLimit = lambda * lfMax * abs(zDistance) / sqrt(tmp);
    
    % Shift it around centre coordinate and determine indices
    indexStart =  ceil((centre - coordLimit - coordMin) / coordDelta) + 1;
    indexEnd   = floor((centre + coordLimit - coordMin) / coordDelta) + 1;
    
    % Clip indices to range [1, indexMax]
    if (indexStart < 1)
      indexStart = 1;
    end
    if (indexEnd > indexMax)
      indexEnd = indexMax;
    end
    
    % Note that if original indexStart:indexEnd (before clipping)
    % falls completely outside the range [1, indexMax],
    % then indexStart > indexEnd after clipping
  end
end