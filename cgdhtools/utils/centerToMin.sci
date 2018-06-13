// Converts position of the optical field center to the position of its corner
//
// Inputs:
// centerPosition
//  - Vector [x, y, z] with coordinates of the optical field center
// matrixSize
//  - [rows, columns] of the optical field
// delta
//  - Sampling distance of the optical field.
//  - Scalar or [deltaY, deltaX]
//
// Outputs:
// minPosition
//  - Vector [x, y, z] with coordinates of the "lower left" sample
//    (minimum x, y coordinates)
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
function minPosition = centerToMin(centerPosition, matrixSize, delta)
  dimensions = calculateDimension(matrixSize, delta) / 2;
  minPosition = centerPosition - [dimensions(2), dimensions(1), 0];
end