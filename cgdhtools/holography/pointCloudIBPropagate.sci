// Image based propagation of a point cloud to a plane z = const used mainly in
// making a computer generated holographic stereogram. See description of the
// input parameter calculationType for details on image based propagation.
//
// The function supports production ready versions that use FFT
// as well as educational simulations that add plane waves one by one.
// More details can be found in description of calculationType.
//
// Inputs:
// pointCloudPosition
//  - Matrix of 3-D points, each row makes a (x, y, z) point
// pointCloudAmplitude
//  - Vector of complex amplitudes of the points.
//  - It is assumed that the length of 'amplitudes' equals to number of points.
// lambda
//  - The wavelength.
// targetPosition
//  - Coordinates of the corner of the calculated optical field with
//    minimum X and Y coordinates.
// targetDeltaYX
//  - Vector of the sampling distances in [Y, X] directions.
// targetSamplesYX
//  - Size od the calculated optical field.
// calculationType
//  - Type of calculation, affects quantization of the point cloud
//    and its compensation.
//  - Image based propagation first calculates a perspective image
//    of the point cloud from the center of the target optical field.
//    Instead of using spherical waves, each point emits a plane wave
//    towards the target center.
//    Summation of plane waves can be efficiently calculated using FFT
//    of the perspective image. However, FFT requires the perspective image
//    to be sampled, which means that point locations are quantized somehow.
//    Various calculation types fight with the quantization errors in 
//    different ways.
//  - When using FFT, quantization is inevitable. For educational purposes,
//    plane waves can be summed one by one. In this case, quantization can
//    be turned off to watch its consequencs.
//  - Supported types of calculation are:
//    'plane'
//      - Basic algorithm. Plane wave direction is set as 
//        targetCenter - pointPosition
//        where pointPosition can be quantized. Phase of the plane wave is 0.
//    'planePAS'
//      - Phase of the basic plane wave is set in such a way that its 
//        phase in the center of the target is the same as phase of the
//        exact spherical wave. See [Yamaguchi93] for details.
//    'planeCPAS'
//      - Almost the same as 'planePAS'. Moreover, additional phase shift
//        tries to fix error of quantization of pointPosition.
//        See [Kang07] for details.
//    'planeA'
//      - The same as 'plane' but quantization is finer, i.e. sampling
//        distance of the image is smalled (image has higher resolution).
//        Upsampling factor is hardcoded in the constant accurateFactor,
//        which defaults to 2. This means that the image has 2*2+1 = 5-times
//        more pixels (sampling distance is 5-times smaller).
//        If FFT is in use, only central part of the transformed data is
//        used as the final optical field, the rest is discarded.
//        See [Kang08] and [Kang09] for details on 'accurate' stereogram methods.
//    'planeAPAS'
//      - The same as 'planePAS' with finer image resolution as in 'planeA'.
//    'planeACPAS'
//      - The same as 'planeCPAS' with finer image resolution as in 'planeA'.
//    'exact'
//      - For testing purposes only. No plane wave approximation, points
//        are sources of normal spherical wave. In fact, this calculationType
//        calls pointCloudPropagate function. Cannot be used with FFT.
//    'planeExact';
//      - For testing purposes only. Almost the same as 'plane', but it uses
//        the same sample coordinate system as 'exact'. Cannot be used with FFT.
// useFFT
//  - Boolesn. If %T, perform the calculation using FFT.
// quantize
//  - Boolean. If %T, points in the perspective image are quantized.
//    Note that when FFT is empled, quantization is inevitable.
//    Quantization errors can be minimized by using 'planeA...' calculation
//    types.
//
// Outputs:
// target
//  - Matrix of complex amplitudes, the size given by targetSamplesYX.
//
// NOTES:
//  - Does not check aliasing
//
//
// REFERENCES:
//
// [Yamaguchi93] Yamaguchi, M., Hoshino, H., Honda, T., Ohyama, N., 
//      "Phase-added stereogram: calculation of hologram using computer graphics 
//      technique", Proc. SPIE 1914, 25-31 (1993).
// [Kang07] Kang, H., Fujii, T., Yamaguchi, T., Yoshikawa, H., 
//      "Compensated phase-added stereogram for real-time holographic display", 
//      Opt. Eng. 46(9), 095802-095802-11 (2007).
// [Kang08] Kang, H., Yamaguchi, T., Yoshikawa, H., "Accurate phase-added 
//      stereogram to improve the coherent stereogram", Appl. Opt. 47(19), 
//      D44-D54 (2008).
// [Kang09] Kang, H., Yaras, F., Onural, L., Yoshikawa, H., "Real-Time Fringe 
//      Pattern Generation with High Quality", Proc. Digital Holography and 
//      Three-Dimensional Imaging, paper DTuB7 (2009). 
//%
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
function target = pointCloudIBPropagate(...
  pointCloudPosition, pointCloudAmplitude, ...
  lambda, ...
  targetPosition, targetDeltaYX, targetSamplesYX, ...
  calculationType, useFFT, quantize)

  // Fire a warning if user wants FFT calculation with
  // 'exact' or 'planeExact' calculation types.
  if (useFFT && ( ...
        isequalString(calculationType, 'exact') || ...
        isequalString(calculationType, 'planeExact')))
    warning(sprintf(...
      ['pointCloudIBPropagate: calculation type ""%s"" cannot be used with FFT.\n' ...
      'Setting useFFT to %F.'], calculationType));
    useFFT = %F;
  end
  
  // "Accurate" calculation types (planeA, planeAPAS, ...)
  // quantize point positions accurateResolution-times better
  // than standard types.
  // If FFT versions, this is accomplished by rendering
  // accurateResolution-times larger images.
  if (isequalString(calculationType, 'planeA') || ...
      isequalString(calculationType, 'planeAPAS') || ...
      isequalString(calculationType, 'planeACPAS'))
    accurateFactor = 2;
  else
    accurateFactor = 0;
  end
  accurateResolution = 2*accurateFactor + 1;
  
  // Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = %pi

  // Useful constants
  k = 2*piNumber/lambda;
  deltaX = targetDeltaYX(2);
  deltaY = targetDeltaYX(1);
  targetSamplesX = targetSamplesYX(2);
  targetSamplesY = targetSamplesYX(1);
  targetCenter = minToCenter(targetPosition, targetSamplesYX, targetDeltaYX);

  // Parameters of the perspective image.
  // Note that for 'plane', 'planePAS', 'planeCPAS',
  // accurateResolution == 1
  imageSamplesYX = accurateResolution*targetSamplesYX;
  imageDeltaYX = lambda./(accurateResolution*targetSamplesYX.*targetDeltaYX);
  
  if (useFFT)
    // Calculate the object wave by making a perspective picture
    // taken from center of the target and its FFT
    cameraPosition = targetCenter;

    // Make the perspective image
    image = pointCloudImage(pointCloudPosition, pointCloudAmplitude, ...
      lambda, ...
      imageSamplesYX, imageDeltaYX, ...
      cameraPosition + [0, 0, 1], ...
      cameraPosition, calculationType);
  
    if (isequalString(calculationType, 'plane') || ...
        isequalString(calculationType, 'planePAS') || ...
        isequalString(calculationType, 'planeCPAS'))
      // Calculate FFT of the perspective image.
      // pointCloudImage() is designed as follows:
      // Camera direction cameraPosition-imageCenter makes pixel
      // in the image center. If pixel count is odd, center pixel is unique,
      // for 5 pixels it is here: [ . . x . .]
      // If number of pixels is even, the center pixel is shifted to the right,
      // for 6 pixels it is hereL [ . . . x . . ]
      // Thus, ifftshift(image) shifts the center pixel to the first row,
      // first column. After performing FFT, it is necessary to revert ifftshift
      // by calling fftshift.
      // Note that for even pixel count, fftshift is the same as ifftshift.
      target = fftshift(ifft2(ifftshift(image)));
      
      // Following command is useful for debugging - it allows to 
      // see the actual perspective image instead of the result.
      // target = image;
    elseif (isequalString(calculationType, 'planeA') || ...
            isequalString(calculationType, 'planeAPAS') || ...
            isequalString(calculationType, 'planeACPAS'))
      // Calculate FFT of the high resolution image
      tmp = fftshift(ifft2(ifftshift(image)));
      // Crop the central part (around zero frequency).
      sr = targetSamplesYX(1)*accurateFactor + 1;
      sc = targetSamplesYX(2)*accurateFactor + 1;
      target = tmp(sr:sr+targetSamplesYX(1)-1,sc:sc+targetSamplesYX(2)-1);
      // target = image;
    else
      error(sprintf('pointCloudIBPropagate: wrong calculation type ""%s""', ...
        calculationType));
    end
    //
    // end of (useFFT)
    //
  else 
  //    
  // do not use FFT, process point by point
  // (just for educational purposes)
  //     
    origPointCloudPosition = pointCloudPosition;

    if (quantize)
      pointCloudPosition = pointCloudDiscretize(...
        pointCloudPosition, targetCenter, targetCenter - [0, 0, 1], ...
        imageDeltaYX);
    end
    
    if (isequalString(calculationType, 'exact') || ...
        isequalString(calculationType, 'planeExact'))
      // For exact calculations, use exact x, y coordinates of the samples
      targetX = (0:targetSamplesX-1)*deltaX + targetPosition(1);
      targetY = (0:targetSamplesY-1)*deltaY + targetPosition(2);
      targetZ = targetPosition(3);
    elseif (isequalString(calculationType, 'plane') || ...
            isequalString(calculationType, 'planePAS') || ...
            isequalString(calculationType, 'planeCPAS') || ...
            isequalString(calculationType, 'planeA') || ...
            isequalString(calculationType, 'planeAPAS') || ...
            isequalString(calculationType, 'planeACPAS'))
      // Calculations that can use FFT naturally use different sample coordinates.
      // They are centered around origin.
      targetX = ((0:targetSamplesX-1)-targetSamplesX/2)*deltaX;
      targetY = ((0:targetSamplesY-1)-targetSamplesY/2)*deltaY;
      targetZ = targetPosition(3);
    else
      error(sprintf('pointCloudIBPropagate: wrong calculation type ""%s""', ...
        calculationType));
    end
      
    [targetXX, targetYY] = meshgrid(targetX, targetY);

    if (isequalString(calculationType, 'exact'))
      target = pointCloudPropagate(pointCloudPosition, pointCloudAmplitude, ...
                                   lambda, targetXX, targetYY, targetZ);
    else
      target = zeros(targetSamplesYX(1), targetSamplesYX(2));
        
      for idx = 1:size(pointCloudPosition, 1)
        if (isequalString(calculationType, 'planeExact') || ...
            isequalString(calculationType, 'plane') || ...
            isequalString(calculationType, 'planeA'))
          dir = targetCenter - pointCloudPosition(idx,:);
          dir = vNormalize(dir);
          target = target + exp(imagUnit*k*(targetXX*dir(1) + targetYY*dir(2)));
        elseif (isequalString(calculationType, 'planePAS') || ...
                isequalString(calculationType, 'planeAPAS'))
          dir = targetCenter - pointCloudPosition(idx,:);
          dir = vNormalize(dir);
          distance = vLength(targetCenter - origPointCloudPosition(idx,:));
          target = target + exp(imagUnit*k*(targetXX*dir(1) + targetYY*dir(2) + distance));
        elseif (isequalString(calculationType, 'planeCPAS') || ...
                isequalString(calculationType, 'planeACPAS'))
          dir = targetCenter - pointCloudPosition(idx,:);
          dir = vNormalize(dir);
          cdir = targetCenter - origPointCloudPosition(idx,:);
          cdistance = vLength(cdir);
          target = target + exp(imagUnit*k*(targetXX*dir(1) + targetYY*dir(2) + cdistance));
        else
          error('pointCloudIBPropagate: strange, this branch should not be accessible...');
        end // if (calculationType)
      end // for
    end // if calculationType ~= exact
  end
end