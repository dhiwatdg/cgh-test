// Simulates a camera taking photograph of the optical field in the lens plane.
// The camera is composed of a single lens and a sensor, both lens and the
// sensor are parallel to z = 0. The camera can be centered or tilt-shift type,
// i.e. the sensor plane and the lens plane are always parallel.
//
// At first, the sensor position is calculated automatically in such a way that
// a point lensFocusedTo is imaged to the sensor center as a sharp point.
// Second, phase of the input optical field is altered to simulate the 
// positive lens of a specified focal length; see [Goodman], Chapter 5.
// It is also possible to limit the field by a specified aperture.
// Third, the optical field is propagated to the sensor.
//
// Inputs:
// lambda
//  - The wavelength.
// lensOptfield
//  - Complex array of the phasors in the lens plane.
// lensDelta
//  - Scalar, sampling distance of the source plane.
//  - Currently, only the same sampling distance in X and Y is supported.
// lensCenter
//  - Location [x, y, z] of the center of the lensOptfield
// lensDiameter
//  - Scalar.
//  - Positive value masks lensOptfield outside the circle with diameter 
//    lensDiameter.
//  - Any negative value masks lensOptfield outside the circle as big as possible
//    (i.e. the aperture is fully open)
// lensFocalLength
//  - Positive scalar, focal length of the lens.
// lensFocusedTo
//  - Location [x, y, z] of a point that is going to be imaged to the sensor
//    center as a perfectly sharp point.
// sensorSamplesYX
//  - [rows, columns]
//  - Number of samples of the sensor matrix, i.e. the resulting image 
//
// Outputs:
// sensorWave
//  - Complex matrix of phasors in the sensor area.
//  - The optical field is rotated 180 degrees in order to show the upright
//    image. (Recall that the image formed by the lens is upside down.)
// sensorX, sensorY
//  - Coordinates of the sensor samples in the global coordinate system. 
//  - The 180 degrees rotation is NOT taken into account.
//    (To be precise, right side of the image shows left side of the sensor,
//    i.e. the coordinates sensorX, sensorY should be descending. This
//    would be, however, confusing at first sight.)
//  - Use them e.g. in displayImage(sensorX, sensorY, abs(sensorWave))
//
//
// NOTES
// Does not check aliasing!
// TODO: Select the best propagation method from the lens to the sensor.
//       (Currently, 'frequency filtered 3fft' is used).
// TODO: Implement different sampling distances in X and Y.
// TODO: Implement aliasing check.
//
//
// REFERENCES:
//
// [Goodman] Goodman, J. W., [Introduction to Fourier Optics (3 ed.)], 
//      Roberts & Company, Englewood (2004).
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
function [sensorWave, sensorX, sensorY] = takePhotograph(...
  lambda, ...
  lensOptfield, lensDelta, lensCenter, ...
  lensDiameter, lensFocalLength, lensFocusedTo, ...
  sensorSamplesYX)

  // Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = %pi

  // Determine sensor (target) location for both lens function and for 
  // the final propagation.

  // Determine the image sensor Z position such that the plane
  // z = focusZ will be in focus
  sensorZ = 1/(1/lensFocalLength + 1/(lensFocusedTo(3) - lensCenter(3))) + ...
            lensCenter(3);

  // Shift the sensor center in such a way that points
  //   [focusX, focusY, focusZ]
  //   [lensCenterX, lensCenterY, hologramZ]
  //   [sensorCenterX, sensorCenterY, sensorZ]
  // lie on a line.
  sensorCenter = lensFocusedTo + ...
    (sensorZ - lensFocusedTo(3)) * ...
    (lensCenter - lensFocusedTo ) / (lensCenter(3) - lensFocusedTo(3));
  sensorCenter(3) = sensorZ;
    
  //
  // Calculate and apply the lens function
  // 
  [lensX, lensY] = ...
    getXYVectorFromCenter(size(lensOptfield), lensDelta, lensCenter);
  [xx, yy] = meshgrid(lensX, lensY);

  // A thin lens changes phase of the incoming light
  // in this way, see e.g. [Goodman], Chapter 5.
  // Please note this simple lens shows many aberrations!
  lensFunct = exp(-imagUnit * (2*piNumber/lambda) / (2*lensFocalLength) * ...
    ((xx - lensCenter(1)).^2 + (yy - lensCenter(2)).^2));

  // Mask areas outside the lens area
  if (lensDiameter > 0)
    // Use provided lens diameter
    lensRadius = lensDiameter / 2;
  else
    // calculate wide open circular lens
    lensRadius = min(calculateDimension(size(lensOptfield), lensDelta)) / 2;
  end
  rho = (xx - lensCenter(1) ).^2 + (yy - lensCenter(2)).^2 - lensRadius^2;
  lensFunct(rho > 0) = 0;

  // Apply the lens
  lensOptfield = lensOptfield .* lensFunct;

  // Free memory
  clear lensFunct;
  clear rho;

  /*
  // For debugging purposes
  //
  if (displayIntermediate)
    scf(2); gcf().background = -2;
    displayImage(lensX * 1e3, lensY * 1e3, real(lensOptfield), 'symmetric');
    title('Optical field behind the lens');
    xlabel('x [mm]');
    ylabel('y [mm]');
    gca().isoview = 'on'; gca().tight_limits = 'on';
  end  
  */
  
  // Propagation to the sensor plane
  [sensorWave, sensorX, sensorY] = propagate(lensOptfield, lensDelta, lensCenter, ...
    sensorSamplesYX, lensDelta, sensorCenter, ...
    lambda, '3fft', 'RayleighSommerfeldExact', 'localExact', 0, '');
  
  // Rotate the image 180 degrees
  // (a lens creates an upside-down image)
  sensorWave = flipud(fliplr(sensorWave));
end