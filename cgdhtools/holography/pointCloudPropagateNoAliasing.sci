// Propagation of a point cloud to a plane z = optfieldZ with aliasing check.
//
// Inputs:
// pointCloudPosition
//  - Matrix of 3-D points, each row makes a (x, y, z) point
// pointCloudAmplitude
//  - Vector of complex amplitudes of the points.
//  - It is assumed that the length of 'amplitudes' equals to number of points.
// lambda
//  - The wavelength.
// xx, yy
//  - X and Y coordinates of the samples.
//  - It is assumed they are formed from
//    [xx, yy] = meshgrid(xVector, yVector)
// optfieldZ
//  - The wave is calculated in z = optfieldZ
// frequencyLimit
//  - Float. Phasor local frequency is limited to 
//    samplingFrequency * frequencyLimit,
//    i.e. set frequencyLimit = 0.5 for the Nyquist-Shannon limit
//  - Setting to Inf disables aliasing check.
//  - If not given, defaults to 0.5
//
// Outputs:
// optfield
//  - Matrix of complex amplitudes, the size is the same as size of xx.
//  - Parts of the optfield that were not illuminated (due to aliasing)
//    are set to zero.
//
// NOTES:
//  - It is assumed that no point lies in z = optfieldZ.
//  - Assumes z coordinates of points < optfieldZ.
//    Calculates "backpropagation" when 'point Z coordinate' > optfieldZ.
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
function optfield = pointCloudPropagateNoAliasing(pointCloudPosition, ...
  pointCloudAmplitude, lambda, xx, yy, optfieldZ, frequencyLimit)
  
  if (nargin < 7)
    // Frequency limit according to Shannon-Nyquist condition
    frequencyLimit = 0.5;
  end

  // Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = %pi

  // Initialize
  optfield = zeros(size(xx, 1), size(xx, 2));
  k = 2*piNumber/lambda;
  nPoints = size(pointCloudPosition, 1);
  
  // Loop point by point
  for i=1:nPoints
    // Calculate an aliasing-free part of a spherical wave
    [u, rowRange, colRange] = ...
      sphericalWave(pointCloudPosition(i,:), lambda, ...
                    xx, yy, optfieldZ, %T, frequencyLimit);

    // If some part of the spherical wave is OK, add it to the optical field
    if (~isMatrixEmpty(u))
      optfield(rowRange,colRange) = optfield(rowRange,colRange) + ...
                                    pointCloudAmplitude(i) .* u;
    end  
  end
end