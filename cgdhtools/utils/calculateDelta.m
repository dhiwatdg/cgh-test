% Converts number of samples and physical dimension to sampling distance.
% Can be used in vector form, e.g.
%   deltaYX = calculateDelta(size(matrix), [height, width])
%
% Inputs:
% samples
%  - Number of samples.
%  - Scalar or a vector of the same length as 'dimension'
% dimension
%  - Physical dimension.
%  - Scalar or a vector of the same length as 'samples'
%
% Outputs:
% delta
%  - Sampling distance.
%  - Scalar or vector according to input parameters.
%
% NOTES
% Physical dimension taken as the distance between the first and the
% last sample, i.e. dimension = (samples - 1) * samplingDistance
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
function delta = calculateDelta(samples, dimension)
  delta = dimension ./ (samples - 1);
end