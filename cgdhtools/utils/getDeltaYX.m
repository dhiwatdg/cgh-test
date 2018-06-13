% Helper function used to get delta for X and Y out of delta
%
% Inputs:
% delta, defaultDelta
%  - The function checks delta and returns
%    * [defalutDelta, defaultDelta]       iff delta == null and defaultDelta is scalar
%    * [defaultDelta(1), defaultDelta(2)] iff delta == null and defaultDelta is vector
%    * [delta, delta]                     iff delta is scalar
%    * [delta(1), delta(2)]               iff delta is vector of two numbers
%
% Outputs:
% deltaYX
%  - The vector [deltaY, deltaX]
%
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
function deltaYX = getDeltaYX(delta, defaultDelta)
  if (nargin < 2)
    defaultDelta = 1e-6;
  end
  if (isempty(delta))
    deltaYX = defaultDelta .* [1, 1];
  elseif (isscalar(delta))
    deltaYX = [delta, delta];
  elseif (size(delta) == [1, 2])
    deltaYX = delta;
  else
    error('getDeltaYX: wrong input argument delta');
  end
end