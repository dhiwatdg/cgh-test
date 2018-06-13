// Calculates a spherical wave in z = const, checks for aliasing
//
// Inputs:
// centre
//  - 3-D vector [x0, y0, z0] with the spherical wave centre.
// lambda
//  - The wavelength.
// xx, yy
//  - X and Y coordinates of the samples.
//  - It is assumed they are formed from
//    [xx, yy] = meshgrid(xVector, yVector)
// optfieldZ
//  - The wave is calculated in z = optfieldZ
// backPropagation
//  - Boolean. If set, it uses exp(-1j * k * r)./r when z0 > optfieldZ.
// frequencyLimit
//  - Float. Phasor local frequency is limited to 
//    samplingFrequency * frequencyLimit,
//    i.e. set frequencyLimit = 0.5 for the Nyquist-Shannon limit
//
// Outputs:
// phasor
//  - Matrix of complex amplitudes.
//  - The matrix size is determined by aliasing, it is at most as big as xx.
//  - Can be [] if there is no sample free of aliasing.
// rowIndex, colIndex
//  - Ranges of indices in the xx, yy matrices where the 'phasor' 
//    should be located.
//  - Can be [] if there is no sample free of aliasing.
//
// NOTES:
//  - It is assumed that xx, yy describe uniform sampling.
//  - Aliasing-free zone is determined by local frequency analysis,
//    i.e. the local frequency of the spherical wave cannot be higher
//    than frequencyLimit times the sampling frequency.
//  - Aliasing-free zone is approximated by a rectangle.
//    (It should be limited by hyperbolas, but the difference is negligible.)
//    (See DEMO_local_frequency for actual shape of the aliasing-free zone.)
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
function [phasor, rowIndex, colIndex] = sphericalWave(centre, lambda, ...
  xx, yy, optfieldZ, backPropagation, frequencyLimit)
  
  // Set defaults
  if (nargin < 7)
    // Frequency limit according to Shannon-Nyquist condition
    frequencyLimit = 0.5;
  end
  
  // Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = %pi

  // For better readability
  x0 = centre(1);
  y0 = centre(2);
  z0 = centre(3);
  
  cornerX = xx(1, 1);
  cornerY = yy(1, 1);

  // Determine backpropagation
  zDistance = optfieldZ - z0;
  if (zDistance < 0 && backPropagation)
    jj = -imagUnit;
  else  
    jj = imagUnit;
  end
  
  // Determine sampling distances
  [rows, columns] = size(xx);
  DeltaX = calculateDelta(columns, xx(1, columns) - xx(1, 1));
  DeltaY = calculateDelta(rows, yy(rows, 1) - yy(1, 1));
 
  // Actual sampling frequencies
  fsX = 1/DeltaX;
  fsY = 1/DeltaY;

  // Limiting frequencies for the aliasing-free zone
  lfxMax = fsX * frequencyLimit;
  lfyMax = fsY * frequencyLimit;
 
  // Get limit indices of the aliasing-free zone
  [colIndexStart, colIndexEnd] = ...
    sphericalWaveLimit(x0, lambda, cornerX, DeltaX, columns, lfxMax, zDistance);
  [rowIndexStart, rowIndexEnd] = ...
    sphericalWaveLimit(y0, lambda, cornerY, DeltaY, rows, lfyMax, zDistance);

  if (colIndexStart > colIndexEnd || rowIndexStart > rowIndexEnd)
    // The aliasing-free zone may lie outide calculated samples
    phasor = [];
    rowIndex = [];
    colIndex = [];
  else
    // Calculate the spherical wave in the aliasing-free zone
    colIndex = colIndexStart : colIndexEnd;
    rowIndex = rowIndexStart : rowIndexEnd;
    
    rr = sqrt((xx(rowIndex, colIndex) - x0).^2 + ...
              (yy(rowIndex, colIndex) - y0).^2 + ...
              zDistance.^2);
    phasor = exp(jj * 2*piNumber/lambda * rr) ./ rr;
  end
end