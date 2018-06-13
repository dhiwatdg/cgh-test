// Converts dimension and sampling distance delta to the number of samples.
// Can be used in a vector form, e.g.
//   rowsColumns = calculateSamples([height, width], [deltaY, deltaX])
//
// Inputs:
// dimension
//  - Physical dimension.
//  - Scalar or a vector of the same length as 'delta'
// delta
//  - Sampling distance.
//  - Scalar or a vector of the same length as 'dimension'
// adjust
//  - String, either 'delta' or 'dimension'
//  - As the number of samples must be integer, it might be necessary to 
//    recalculate either physical dimension or sampling distance delta.
//    Use second output to get the adjusted value.
//  - Optional, defaults to 'dimension'
//
// Outputs:
// samples
//  - Number of samples.
//  - Scalar or vector according to input parameters.
// adjustedValue
//  - Adjusted physical dimension or sampling distance, according to
//    parameter 'adjust'.
//
// NOTES
// Physical dimension taken as the distance between the first and the
// last sample, i.e. dimension = (samples - 1) * samplingDistance
//
// ---------------------------------------------
//
//  CGDH TOOLS
//  Petr Lobaz, lobaz@kiv.zcu.cz
//  Faculty of Applied Sciences, University of West Bohemia 
//  Pilsen, Czech Republic
//
//  Check http://holo.zcu.cz for more details and scripts.
//
// ---------------------------------------------
function [samples, adjustedValue] = calculateSamples(dimension, delta, adjust)
  samples = ceil(dimension ./ delta) + 1;
  if (nargout == 2)
    if (nargin < 3 || isequalString(adjust, 'dimension'))
      adjustedValue = calculateDimension(samples, delta);
    elseif (isequalString(adjust, 'delta'))
      adjustedValue = calculateDelta(samples, dimension);
    else
      error(sprintf('Unknown adjusting mode %s', adjust));
    end
  end
end