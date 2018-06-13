// Calculate a convolution kernel in the spatial domain
//
// Inputs:
// kernelType 
//  - type of the kernel, can be:
//    'RayleighSommerfeldExact'  - Full RS definition 
//    'RayleighSommerfeldSimple' - RS without 1/r term
//    'FresnelXY'                - Fresnel kernel in the spatial domain
//    'SphericalWave'            - Huygens spherical wavelet (just for curiosity)
//  - see cgdhFunct.m for implementation details
// filterType 
//  - Local frequency (lx, ly) filtering, can be:
//    'localExact' - sample is rejected if lx, ly > sampling limit
//    'localRect'  - sample is rejected if x, y is outside estimated safe area
//    'none'       - no filtering
// sourceSize 
//  - Size of the source matrix, i.e. the vector [rows, columns].
// kernelSize 
//  - Desired size of the kernel, i.e. the vector [rows, columns].
// sourceMin  
//  - 3-D vector [x, y, z] of the lower left corner of the source.
// targetMin  
//  - 3-D vector [x, y, z] of the lower left corner of the target.
// deltaYX    
//  - 2-D vector [deltaY, deltaX] with sampling periods in x and y.
// lambda
//  - The wavelength.
//
// Outputs:
// kernel
//  - Complex matrix with the convolution kernel in the spat. domain.
// x, y
//  - Vectors of kernel's x and y coordinates.
//    (useful for drawing - e.g. imagesc(x, y, real(kernel))
//
// NOTES:
// Intended use:
//   kernelFT = fft2(genfftshiftPre(kernel, m, n));
//   target = ifft2(fft2(src) .* kernelFT);
// Note that the sample (1, 1) of the kernel used in fft2 should contain the
// change of complex amplitude when light travels from sample (a, b) of the
// source to the sample (a, b) of the target. The function genfftshiftPre()
// accomplishes this.
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
function [kernel, x, y] = ...
  kernelXY(kernelType, filterType, ...
           sourceSize, kernelSize, sourceMin, targetMin, deltaYX, lambda)
  // Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = %pi

  // Get source and theoretical target dimensions
  m = sourceSize(2);
  n = sourceSize(1);
  p = kernelSize(2) - m + 1;
  q = kernelSize(1) - n + 1;
  
  // Get shift vector between source and target
  px = targetMin(1) - sourceMin(1);
  py = targetMin(2) - sourceMin(2);
  z0 = targetMin(3) - sourceMin(3);
  
  // Prepare coordinates
  k = 2*piNumber/lambda;
  x = (1-m:p-1) * deltaYX(2) + px;
  y = (1-n:q-1) * deltaYX(1) + py;
  [xx, yy] = meshgrid(x, y);

  // Maximum local frequencies according to Nyquist limit
  lfMaxYX = 0.5 ./ deltaYX;
  
  // Calculate the kernel and apply local frequency based filtering.
  switch (filterType)
    case 'localExact'
      [kernel, lfxRange, lfyRange, lfx, lfy] = ...
        cgdhFunct(kernelType, xx, yy, [lambda, z0], lfMaxYX);
      kernel = kernel .* (lfx < lfMaxYX(2)) .* (lfy < lfMaxYX(1));
    //
    case 'localRect'
      [kernel, lfxRange, lfyRange] = ...
        cgdhFunct(kernelType, xx, yy, [lambda, z0], lfMaxYX);
      kernel(xx < lfxRange(1)) = 0;
      kernel(xx > lfxRange(2)) = 0;
      kernel(yy < lfyRange(1)) = 0;
      kernel(yy > lfyRange(2)) = 0;
    //
    case 'none'
      kernel = cgdhFunct(kernelType, xx, yy, [lambda, z0], lfMaxYX);
    otherwise
      error(sprintf('kernelXY: unknown filterType ""%s""', filterType));
  end
end