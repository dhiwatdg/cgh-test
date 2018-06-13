// Calculates complex amplitudes of a plane wave in a plane z = const.
//
// Inputs:
// dirVector
//  - 3-D direction vector of the plane wave.
//  - It is assumed that it is normalized (unit length)
// lambda
//  - The wavelength.
// xx, yy
//  - Matrices with X and Y coordinates of the samples
//  - Sizes of xx, yy must be the same.
//  - It is assumed they are calculated using
//      [xx, yy] = meshgrid(xVector, yVector)
//    where xVector, yVector are locations of x, y samples, e.g.
//      xVector = linspace(-1e-3, 1e-3, 100);
//      yVector = -1e-3 : 10e-6 : 1e-3;
// optfieldZ
//  - The plane wave is calculated in z = optfieldZ
//
// Outputs:
// optfield
//  - Matrix of complex amplitudes, the size is the same as size of xx.
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
function optfield = planeWave(dirVector, lambda, xx, yy, optfieldZ)
  // Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = %pi

  optfield = exp(imagUnit * 2*piNumber/lambda * ...
    (xx * dirVector(1) + yy * dirVector(2) + optfieldZ * dirVector(3)));
end  