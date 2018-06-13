// Converts number of samples and sampling distance to physical dimension.
// Can be used in vector form, e.g.
//   heightWidth = calculateDimension(size(matrix), [deltaY, deltaX])
//
// Inputs:
// samples
//  - Number of samples.
//  - Scalar or a vector of the same length as 'delta'
// delta
//  - Sampling distance.
//  - Scalar or a vector of the same length as 'samples'
//
// Outputs:
// dimension
//  - Physical dimension.
//  - Scalar or vector according to input parameters.
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
function dimension = calculateDimension(samples, delta)
  dimension = (samples - 1) .* delta;
end