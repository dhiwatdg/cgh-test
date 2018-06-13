// Calculates a convolution kernel in the frequency domain.
//
// Inputs:
// kernelType 
//  - type of the kernel, can be:
//    'AngularSpectrumExact'        - FT of the exact Rayleigh-Sommerfeld kernel
//    'AngularSpectrumNoEvanescent' - like AngularSpectrumExact without evanescent waves
//    'FresnelFXFY'                 - Fresnel kernel in the frequency domain
//  - see cgdhFunct.m for implementation details
// filterType 
//  - Specifies filtering (hard clipping) of values that damage propagation 
//    result.
//  - Start with 'angularLocalRect' or 'angular'.
//  - Local frequency based filtering can be 
//    (lx, ly are local frequencies at a point fx, fy):
//    'localExact' - sample is rejected if lx, ly > sampling limit
//    'localRect'  - sample is rejected if fx, fy is outside estimated safe area
//    'none'       - no samples are rejected if local frequency is too high
//  - In addition, it is worth checking if the kernel in the frequency domain
//    is zero in areas that do not correspond propagation directions between
//    any two points in source and target ('angular...' types). This is 
//    necessary in case when the source and the target do not have common size.
//    'angularLocalExact' - angular filtering + 'localExact'
//    'angularLocalRect'  - angular filtering + 'localRect'
//    'angular'           - pure angular filtering
//  - Angular versions are generally a better choice. 
// sourceSize 
//  - Size of the source matrix, i.e. the vector [rows, columns].
// kernelSize 
//  - Desired size of the kernel, i.e. the vector [rows, columns].
// sourceMin  
//  - 3-D vector [x, y, z] of the lower left corner of the source.
// targetMin  
//  - 3-D vectir [x, y, z] of the lower left corner of the target.
// deltaYX    
//  - 2-D vector [deltaY, deltaX] with sampling periods in x and y.
// lambda
//  - The wavelength.
//
// Outputs:
// kernel
//  - Complex matrix with the convolution kernel in the freq. domain.
// fx, fy
//  - Vectors of kernel's fx and fy coordinates.
//    (useful for drawing - e.g. imagesc(fx, fy, real(kernel))
// lfxRange, lfyRange
//  - Vectors [min, max] of the minimum/maximum frequency that contains
//    nonzero values after the kernel filtering.
//  - The bounds from angular filtering for filterType = 'angular???',
//    the bounds from local frequency filtering for filterType = 'local???',
//    [-inf, inf] for filterType = 'none'.
//  - Intended just for plots of the kernel.
//
// NOTES:
// Intended use: target = ifft2(fft2(src) .* ifftshift(kernelFD));
// Note that zero frequency is in the center of the kernel, ifftshift()
// moves it to sample (1, 1). Fee propagate2fft() for implementation.
//
// Angular filtering is an addition to local frequency filtering. The idea
// is simple. It is assumed that the function that defines the kernel in the
// spatial domain is centered at (0, 0). For the propagation calculation,
// the kernel is sampled from kernelXMin to kernelXMax, the same for y coordinate.
// Local frequencies of the spatial domain kernel at its border are the highest
// frequencies that can be present in the frequency domain.
// Thus, when calculating the kernel in the frequency domain directly (i.e.
// the transfer function), it is necessary to clip samples outside the range
// defined by the kernel in the spatial domain.
// Note this is necessary when the source and the target do not share the same
// size. If they share the size, local frequency clipping (i.e. 'localRect')
// actually does the same thing.
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
function [kernel, fx, fy, lfxRange, lfyRange] = ...
  kernelFXFY(kernelType, filterType, ...
           sourceSize, kernelSize, sourceMin, targetMin, deltaYX, lambda)

  // Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = %pi

  // Get source and theoretical target dimensions
  m = sourceSize(2);
  n = sourceSize(1);
  kn = kernelSize(1);
  km = kernelSize(2);
  p = km - m + 1;
  q = kn - n + 1;
  
  // Get shift vector between source and target
  px = targetMin(1) - sourceMin(1);
  py = targetMin(2) - sourceMin(2);
  z0 = targetMin(3) - sourceMin(3);

  // Prepare coordinates
  k = 2*piNumber/lambda;
  deltaFX = 1/(kernelSize(2) * deltaYX(2));
  deltaFY = 1/(kernelSize(1) * deltaYX(1));
  fx = ((0:km-1) - floor(km/2)) * deltaFX;
  fy = ((0:kn-1) - floor(kn/2)) * deltaFY;
  [fxx, fyy] = meshgrid(fx, fy);

  // Maximum local frequencies according to Nyquist limit
  limitFX = 0.5/deltaFX;
  limitFY = 0.5/deltaFY;
  
  // Calculate the kernel and apply local frequency based filtering.
  // Note:
  // lfxRange, lfyRange are replaced later for filterType == 'angular???'
  if (isequalString(filterType, 'localExact') || ...
      isequalString(filterType, 'angularLocalExact'))
    [kernel, lfxRange, lfyRange, lfx, lfy] = ...
      cgdhFunct(kernelType, fxx, fyy, [lambda, z0, px, py], [limitFY, limitFX]);
    kernel = kernel .* (lfx < limitFX) .* (lfy < limitFY);
    //
    //
  elseif (isequalString(filterType, 'localRect') || ...
          isequalString(filterType, 'angularLocalRect'))
    [kernel, lfxRange, lfyRange] = ...
      cgdhFunct(kernelType, fxx, fyy, [lambda, z0, px, py], [limitFY, limitFX]);
    if (fx(1) < lfxRange(1))
      kernel(fxx < lfxRange(1)) = 0;
    end
    if (fx($) > lfxRange(2))
      kernel(fxx > lfxRange(2)) = 0;
    end
    if (fy(1) < lfyRange(1))
      kernel(fyy < lfyRange(1)) = 0;
    end
    if (fy($) > lfyRange(2))
      kernel(fyy > lfyRange(2)) = 0;
    end
    //
    //
  elseif (isequalString(filterType, 'angular'))
    [kernel, lfxRange, lfyRange] = ...
      cgdhFunct(kernelType, fxx, fyy, [lambda, z0, px, py], [limitFY, limitFX]);
    //
    //
  elseif (isequalString(filterType, 'none'))
    kernel = ...
      cgdhFunct(kernelType, fxx, fyy, [lambda, z0, px, py], [limitFY, limitFX]);
 lfxRange = [-%inf, %inf];
    lfyRange = lfxRange;
  else
    error(sprintf('kernelFXFY: unknown filterType ""%s""', filterType));
  end
  
  
  // Additional frequency clipping based on the kernel in the spatial domain. 
  if (isequalString(filterType, 'angular') || ...
      isequalString(filterType, 'angularLocalRect') || ...
      isequalString(filterType, 'angularLocalExact'))
    // Until now, it was assumed that the convolution kernel in the spatial 
    // domain is defined on a symmetric support.
    // In off-axis cases (or in on-axis propagation between source and target of
    // different sizes), this not the case.
    
    // Determine support of the kernel in the spatial domain. 
    // See kernelXY() for the implementation there.
    kernelXMin = (1-m) * deltaYX(2) + px;  
    kernelXMax = (p-1) * deltaYX(2) + px;
    kernelYMin = (1-n) * deltaYX(1) + py;
    kernelYMax = (q-1) * deltaYX(1) + py;
    
    // Support of the kernel in the spatial domain limits which frequencies
    // are actually used in the kernel. Estimate them by local frequencies
    // of a spherical wave.
    xc = (kernelXMin + kernelXMax) / 2;
    yc = (kernelYMin + kernelYMax) / 2;
    tmpX = [kernelXMin, kernelXMax,         xc,         xc];
    tmpY = [        yc,         yc, kernelYMin, kernelYMax];
    tmpR = sqrt(tmpX.^2 + tmpY.^2 + z0^2);
    lxMin = kernelXMin / (lambda * tmpR(1));
    lxMax = kernelXMax / (lambda * tmpR(2));
    lyMin = kernelYMin / (lambda * tmpR(3));
    lyMax = kernelYMax / (lambda * tmpR(4));
    
    // Clip frequencies if necessary
    if (fx(1) < lxMin)
      kernel(fxx < lxMin) = 0;
    end
    if (fx($) > lxMax)
      kernel(fxx > lxMax) = 0;
    end
    if (fy(1) < lyMin)
      kernel(fyy < lyMin) = 0;
    end
    if (fy($) > lyMax)
      kernel(fyy > lyMax) = 0;
    end
    
    lfxRange = [lxMin, lxMax];
    lfyRange = [lyMin, lyMax];
  end
end