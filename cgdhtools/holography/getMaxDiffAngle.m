% Calculates maximum diffraction angle that is possible with sampling distance
% delta.
%
% Inputs:
% lambda
%  - wavelength of light
% delta
%  - sampling distance
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
function out = getMaxDiffAngle(lambda, delta)
  % Sine of the diffraction angle
  tmp = lambda./(2*delta);
  
  % Clip the maximum value to 1 as the diffraction angle cannot be complex
  % (it is at most 90 degrees)
  tmp = min(tmp, 1);
  out = asin(tmp);
end