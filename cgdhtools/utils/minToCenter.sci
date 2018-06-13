// Converts position of the optical field corner to the position of its center
//
// Inputs:
// minPosition
//  - Vector [x, y, z] with coordinates of the "lower left" sample
//    (minimum x, y coordinates)
// matrixSize
//  - [rows, columns] of the optical field
// delta
//  - Sampling distance of the optical field.
//  - Scalar or [deltaY, deltaX]
//
// Outputs:
// centerPosition
//  - Vector [x, y, z] with coordinates of the optical field center
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
function centerPosition = minToCenter(minPosition, matrixSize, delta)
  dimensions = calculateDimension(matrixSize, delta) / 2;
  centerPosition = minPosition + [dimensions(2), dimensions(1), 0];
end