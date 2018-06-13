// Makes a perspective image of a point cloud. 
// Useful for debugging and for making computer generated holographic stereograms.
//
// Inputs:
// pointCloudPosition
//  - Matrix of 3-D points, each row makes a (x, y, z) point
// pointCloudAmplitude
//  - Vector of complex amplitudes of the points.
//  - It is assumed that the length of 'amplitudes' equals to number of points.
// lambda
//  - The wavelength.
// imageSamplesYX
//  - Size (number of pixels) od the calculated image.
//  - [rows, columns]
// imageDelta
//  - Sampling distance of the calculated image.
// imageCenter
//  - Location [x, y, z] of the image center.
// cameraPosition
//  - Location [x, y, z] of the camera.
//  - The distance |cameraPosition - imageCenter| defines the camera focal length.
//  - Physical size (imageSamples * imageDelta) further determines the viewing 
//    angle.
// imageType
//  - Affects phase of the rendered point. The types are compatible with the 
//    types used in the holographic stereogram calculation 
//    (see pointCloudIBPropagate)
//  - Implemented types are:
//    'plane', 'planeA'
//      Do not affect the phase, the pixel value of the rendered point is exactly
//      given by its pointCloudAmplitude
//    'planePAS', 'planeAPAS'
//      For the phase added stereogram: adjust the phase according to the 
//      distance between cameraCenter and the point being rendered.
//    'planeCPAS', 'planeACPAS'
//      For the compensated phase added stereogram. The same like 'PAS' types 
//      above, but it takes into account that a rendered pixel position is
//      quantized (aligned to the pixel grid).
//
// Outputs:
// image
//  - The matrix with a rendered perspective image.
//
// NOTES
// Check tests below the code to see how it works.
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
function image = pointCloudImage(pointCloudPosition, pointCloudAmplitude, lambda, ...
  imageSamplesYX, imageDelta, imageCenter, cameraPosition, imageType)
  
  // Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = %pi

  if (nargin < 8)
    imageType = 'plane';
  end
  
  image = zeros(imageSamplesYX(1), imageSamplesYX(2));
  
  deltaYX = getDeltaYX(imageDelta, 1);
  deltaY = deltaYX(1);
  deltaX = deltaYX(2);

  // Assume the image plane center is located at 
  // [cameraPosition(1), cameraPosition(2), imageZ]
  imageZtoCameraZ = cameraPosition(3) - imageCenter(3);
  
  indexCenterX = ceil((imageSamplesYX(2) - 1) / 2) + 1;
  indexCenterY = ceil((imageSamplesYX(1) - 1) / 2) + 1;
  
  /*
  // Debug output: useful when rendering series of images for the stereogram
  mprintf('FFT: cameraPos [%.3f %.3f %.3f] imageCenter [%.3f %.3f %.3f]\n', ...
    cameraPosition(1)*1e3, ...
    cameraPosition(2)*1e3, ...
    cameraPosition(3)*1e3, ...
    imageCenter(1)*1e3, ...
    imageCenter(2)*1e3, ...
    imageCenter(3)*1e3);
  */
  
  xShift = cameraPosition(1) - imageCenter(1);
  yShift = cameraPosition(2) - imageCenter(2);

  for idx = 1:size(pointCloudPosition, 1)
    // Position of a point being rendered
    x = pointCloudPosition(idx, 1);
    y = pointCloudPosition(idx, 2);
    z = pointCloudPosition(idx, 3);

    // Apply a perspective transform
    perspFactor = (cameraPosition(3) - imageCenter(3)) / ...
                  (cameraPosition(3) - z);
    
    x = (x - cameraPosition(1))*perspFactor + xShift;
    y = (y - cameraPosition(2))*perspFactor + yShift;

    // Useful for debugging pixel quantization (aligning to pixel grid)
    // mprintf('XY before quantization: %.3f %.3f\n', x*1e3, y*1e3);

    // float index of the rendered pixel, 0 = image center    
    x = x / deltaX;   
    y = y / deltaY;

    // convert to integer pixel index
    ix = floor(x + 0.5) + indexCenterX;
    iy = floor(y + 0.5) + indexCenterY ;
    
    // mprintf('   After quantization: %d %d\n', ix, iy);
    
    // Check if the pixel position is inside the image
    if (ix > 1 && ix <= imageSamplesYX(2) && iy > 1 && iy <= imageSamplesYX(1))
      //
      // Set image(iy, ix) to a point complex amplitude
      //
      if     (isequalString(imageType, 'plane') || ...
              isequalString(imageType, 'planeA'))
        image(iy, ix) = pointCloudAmplitude(idx);
      elseif (isequalString(imageType, 'planePAS') || ...
              isequalString(imageType, 'planeAPAS'))
        dir = cameraPosition - pointCloudPosition(idx,:);
        distance = vLength(dir);        
        image(iy, ix) = pointCloudAmplitude(idx) * ...
                        exp(imagUnit * 2*piNumber/lambda * distance);
      elseif (isequalString(imageType, 'planeCPAS') || ...
              isequalString(imageType, 'planeACPAS'))
        dir = cameraPosition - pointCloudPosition(idx,:);
        distance = vLength(dir);
        // Derivation of the compensation factor:
        // compX = positionDifference * DeltaFX
        //       = positionDifference * 1/(M DeltaX)
        //       = positionDifference / imageSamplesX
        compX = (x - floor(x + 0.5))/imageSamplesYX(2);
        compY = (y - floor(y + 0.5))/imageSamplesYX(1);
        comp = compX + compY;
        image(iy, ix) = pointCloudAmplitude(idx) * ...
                        exp(imagUnit * 2*piNumber/lambda * distance) * ...
                        exp(-imagUnit * 2*piNumber * comp);
      else
        error(sprintf('pointCloudImage: wrong imageType ""%s""', imageType));
      end
    end
  end
end

//// TEST
/*
flipud(pointCloudImage([0, 0, 0], 1, 1, [5, 5], 1, [0, 0, 0], [0, 0, 1]))
flipud(pointCloudImage([1, 0, 0], 1, 1, [5, 5], 1, [0, 0, 0], [0, 0, 1]))
flipud(pointCloudImage([0, 1, 0], 1, 1, [5, 5], 1, [0, 0, 0], [0, 0, 1]))
flipud(pointCloudImage([1, 1, 0], 1, 1, [5, 5], 1, [1, 1, 0], [0, 0, 1]))
flipud(pointCloudImage([2, 0, 0], 1, 1, [5, 5], 1, [0, 0, 0], [0, 0, 1]))
flipud(pointCloudImage([2, 0, -1], 1, 1, [5, 5], 1, [0, 0, 0], [0, 0, 1]))
flipud(pointCloudImage([0, 0, 0], 1, 1, [4, 4], 1, [0, 0, 0], [0, 0, 1]))
*/