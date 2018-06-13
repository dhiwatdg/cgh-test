// Propagates the source plane to the parallel target plane
// using convolution kernel defined in the frequency domain (2fft).
// This method currently requires the same sampling distance in both the source
// and the target plane.
//
// The target is given by IFFT( FFT(source) .* kernelFXFY ),
// where FFT/IFFT stands for the fast Fourier transform and its inverse,
// kernelFXFY is a function determined by kernelType.
// 2fft methods are generally useful for shorter propagation distances.
//
// Inputs:
// source
//  - Complex array of the phasors in the source plane.
// sourceDeltaYX
//  - Sampling distance of the source plane.
//  - Must be vector [deltaY, deltaX]
// sourceMin
//  - Location [x, y, z] of the source corner (minimum x, y coordinates)
// targetSize
//  - [rows, columns]
//  - Number of samples of the target matrix
// targetMin
//  - Location [x, y, z] of the target corner (minimum x, y coordinates)
// lambda        
//  - The wavelength.
// kernelType    
//  - Type of the propagation kernel
//  - Implemented types are
//    'AngularSpectrumExact', 'Exact'
//      FT of the exact Rayleigh-Sommerfeld kernel
//      Type 'Exact' is the same as 'AngularSpectrumExact'
//    'AngularSpectrumNoEvanescent'
//      like AngularSpectrumExact without evanescent components
//    'FresnelFXFY', 'Fresnel'
//      Fresnel approximation of 'AngularSpectrumExact'
//      Type 'Fresnel' is the same as 'FresnelFXFY'
//  - Aliases 'Fresnel' and 'Exact' allow easy calling with the function 
//    propagate:
//      propagate(..., '3fft', 'Exact')
//      propagate(..., '2fft', 'Exact')
//    picks approptiate kernel type in 2fft/3fft methods,
//      propagate(..., '3fft', 'Fresnel')
//      propagate(..., '2fft', 'Fresnel')
//      propagate(..., '1fft', 'Fresnel')
//    picks approptiate kernel type in 1fft/2fft/3fft methods,
// filterType    
//  - The kernel function can be aliased. FilterType determines what to do.
//  - In general, local frequency of the kernel is evaluated at each point.
//  - In addition, it is worth checking if the kernel in the frequency domain
//    is zero in areas that do not correspond propagation directions between
//    any two points in source and target ('angular...' types). This is 
//    necessary in case when the source and the target do not have common size.
//  - Angular versions are generally better choice.
//  - Type:
//    'none'
//      Does nothing, i.e. the kernel stays aliased.
//    'angular'
//      Pure angular filtering, no analysis of local frequencies. Worth trying.
//    'localExact' 
//      Makes the kernel 0 at points where the local frequency is too high.
//    'angularLocalExact'
//      Angular filtering + 'localExact'
//    'localRect'
//      Is similar to 'localExact', but the aliasing-free area is estimated by
//      a rectangle. It is computationally cheaper, but less precise. In many
//      practical cases, results of 'localExact' and 'localRect' are virtually 
//      the same.
//    'angularLocalRect'
//      Angular filtering + 'localrect'
// displayKernel
//  - Displays the kernel function in Figure(displayKernel).
//  - 0 switches the kernel display off.
//  - Red lines in the frequency domain plot delimit the kernel filtering
//    range, see kernelFXFY() for details.
// saveKernel
//  - Saves the kernel to image files 'saveKernel????.png', where ???? can be
//    '_native(FxFy)' - the function in its native frequency domain
//    '_other(XY)'    - for convenience, IFFT(kernel) is also saved, i.e. the 
//                      function in the spatial domain
//  - '' (empty string) disables image saving.
//
// Outputs:
// target        
//  - Complex matrix of phasors in the target area.
// x, y          
//  - Coordinates of the target samples. 
//  - Use them e.g. in displayImage(x, y, target)
// kernelFD
//  - Kernel function in the native frequency domain
// kernelFX, kernelFY 
//  - Frequency coordinates of the kernel samples
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
function [target, x, y, kernelFD, kernelFX, kernelFY] = ...
  propagate2fft(source, sourceDeltaYX, sourceMin, ...
                targetSize, targetMin, ...
                lambda, kernelType, filterType, ...
                displayKernel, saveKernel);

  // Resolve kernelType alias names
  if (isequalString(kernelType, 'Fresnel'))
    kernelType = 'FresnelFXFY';
  elseif (isequalString(kernelType, 'Exact'))
    kernelType = 'AngularSpectrumExact';
  end

  // For shorter code  
  [n, m] = size(source);
  q = targetSize(1);
  p = targetSize(2);
  
  // Calculate convolution size
  kn = convolutionSize(n, q);
  km = convolutionSize(m, p);
  kernelSize = [kn, km];
  
  // Source zero padding
  src = zeros(kn, km);
  src(1:n, 1:m) = source;
  
  // Convolution kernel
  [kernelFD, kernelFX, kernelFY, lfxRange, lfyRange] = kernelFXFY(...
    kernelType, filterType, ...
    [n, m], kernelSize, ...
    sourceMin, targetMin, ...
    sourceDeltaYX, lambda);

  // Propagation calculation by convolution in the frequency domain
  target = ifft2(fft2(src) .* ifftshift(kernelFD));

  target = target(1:q, 1:p);

  // Coordinates of the target samples
  [x, y] = getXYVectorFromMin([q, p], sourceDeltaYX, targetMin);

  // Display/save kernel for debugging purposes  
  if (displayKernel > 0 || ~isequalString(saveKernel, ''))
    if (displayKernel > 0)
      displayFlag = 1;
      scf(displayKernel); gcf().background = -2;
      clf();
      subplot(2, 1, 1);
    else
      displayFlag = 0;
    end
    
    if (isequalString(saveKernel, ''))
      fnameA = '';
      fnameB = '';
    else
      fnameA = sprintf('%s_native(FxFy).png', saveKernel);
      fnameB = sprintf('%s_other(XY).png', saveKernel);
    end

    // Display/save the kernel in the spatial domain
    
    // Coordinates of the kernel in the spatial domain 
    // (see kernelXY() for details).
    pKernel = kernelSize(2) - m + 1;
    qKernel = kernelSize(1) - n + 1;  
    px = targetMin(1) - sourceMin(1);
    py = targetMin(2) - sourceMin(2);
    kernelX = (1-m:pKernel-1) * sourceDeltaYX(2) + px;
    kernelY = (1-n:qKernel-1) * sourceDeltaYX(1) + py;
    kernelSD = genfftshiftPost(ifft2(ifftshift(kernelFD)), m, n);
    
    limits = displayImage(kernelX * 1e3, kernelY * 1e3, (kernelSD), ...
         'complex', displayFlag, fnameB);

    // Annotate the graph if necessary
    if (displayKernel > 0)
      title(sprintf('Kernel in 2fft/%s/%s, IFFT (spatial domain)', ...
        kernelType, filterType));
      xlabel('x [mm]');
      ylabel('y [mm]');
      drawColorbar(limits);
      gca().isoview = 'on'; gca().tight_limits = 'on';
      gridOn([1, 1, 0], 0.6);
      subplot(2, 1, 2);
    end

    // Display/save the kernel in the frequency domain
    
    limits = displayImage(kernelFX * 1e-3, kernelFY * 1e-3, (kernelFD), ...
      'complex', displayFlag, fnameA);

    // Annotate the graph if necessary
    if (displayKernel > 0)
      title(...
        sprintf('Kernel in 2fft/%s/%s method, native frequency domain', ...
        kernelType, filterType));
      xlabel('fx [mm^{-1}]');
      ylabel('fy [mm^{-1}]');
      drawColorbar(limits);
      gca().isoview = 'on'; gca().tight_limits = 'on';
      
      // Draw filtering bounds
      if (lfxRange(1) >= kernelFX(1))
        drawLine([lfxRange(1), lfxRange(1)]*1e-3, [kernelFY(1), kernelFY($)]*1e-3, 'red', 2);
      end
      if (lfxRange(2) <= kernelFX($))
        drawLine([lfxRange(2), lfxRange(2)]*1e-3, [kernelFY(1), kernelFY($)]*1e-3, 'red', 2);
      end
      if (lfyRange(1) >= kernelFY(1)) 
        drawLine([kernelFX(1), kernelFX($)]*1e-3, [lfyRange(1), lfyRange(1)]*1e-3, 'red', 2);
      end
      if (lfyRange(2) <= kernelFY($))
        drawLine([kernelFX(1), kernelFX($)]*1e-3, [lfyRange(2), lfyRange(2)]*1e-3, 'red', 2);
      end
      gridOn([1, 1, 0], 0.6);
    end
  end    
end  

