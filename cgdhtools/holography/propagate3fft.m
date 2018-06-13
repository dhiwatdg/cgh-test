% Propagates the source plane to the parallel target plane
% using convolution kernel defined in the spatial domain (3fft).
% This method currently requires the same sampling distance in both the source
% and the target plane.
%
% The target is given by IFFT( FFT(source) .* FFT(kernelXY) ),
% where FFT/IFFT stands for the fast Fourier transform and its inverse,
% kernelXY is a function determined by kernelType.
% 3fft methods are generally useful for longer propagation distances.
%
% Inputs:
% source
%  - Complex array of the phasors in the source plane.
% sourceDeltaYX
%  - Sampling distance of the source plane.
%  - Must be vector [deltaY, deltaX]
% sourceMin
%  - Location [x, y, z] of the source corner (minimum x, y coordinates)
% targetSize
%  - [rows, columns]
%  - Number of samples of the target matrix
% targetMin
%  - Location [x, y, z] of the target corner (minimum x, y coordinates)
% lambda        
%  - The wavelength.
% kernelType    
%  - Type of the propagation kernel
%  - Implemented types are
%    'RayleighSommerfeldExact', 'Exact'
%      The Rayleigh-Sommerfeld kernel of the first kind
%      Type 'Exact' is the same as 'RayleighSommerfeldExact'
%    'RayleighSommerfeldSimple'
%      Like RayleighSommerfeldExact without the 1/r term.
%      This modification is often used instead of the full definition,
%      but there is hardly any reason to do so. Analysis of the approximation
%      can be found in [Marathay04].
%    'FresnelXY', 'Fresnel'
%      Fresnel approximation of 'RayleighSommerfeldExact'
%      Type 'Fresnel' is the same as 'FresnelXY'
%    'SphericalWave'
%      Huygens spherical wavelet (just for curiosity, it has no practical use)
%  - Aliases 'Fresnel' and 'Exact' allow easy calling with the function 
%    propagate:
%      propagate(..., '3fft', 'Exact')
%      propagate(..., '2fft', 'Exact')
%    picks approptiate kernel type in 2fft/3fft methods,
%      propagate(..., '3fft', 'Fresnel')
%      propagate(..., '2fft', 'Fresnel')
%      propagate(..., '1fft', 'Fresnel')
%    picks approptiate kernel type in 1fft/2fft/3fft methods,
% filterType    
%  - The kernel function can be aliased. FilterType determines what to do.
%  - In general, local frequency of the kernel is evaluated at each point.
%  - Type:
%    'none'
%      Does nothing, i.e. the kernel stays aliased.
%    'localExact' 
%      Makes the kernel 0 at points where the local frequency is too high.
%    'localRect'
%      Is similar to 'localExact', but the aliasing-free area is estimated by
%      a rectangle. It is computationally cheaper, but less precise. In many
%      practical cases, results of 'localExact' and 'localRect' are virtually 
%      the same.
% displayKernel
%  - Displays the kernel function in Figure(displayKernel).
%  - 0 switches the kernel display off.
%  - Crossing of the red lines in the spatial domain plot show the sample (1, 1)
%    after proper fftshift() just before fft2 of the kernel.
%  - Red lines in the frequency domain plot show maximum local frequencies 
%    of a spherical wave present in the spatial domain. This is used for
%    evaluation of 'angular???' filtering types in 2fft method, see kernelFXFY()
%    for details.
% saveKernel
%  - Saves the kernel to image files 'saveKernel????.png', where ???? can be
%    '_native(XY)'  - the function in its native spatial domain
%    '_other(FxFy)' - for convenience, FFT(kernel) is also saved, i.e. the 
%                     function in the frequency domain
%  - '' (empty string) disables image saving.
%
% Outputs:
% target        
%  - Complex matrix of phasors in the target area.
% x, y          
%  - Coordinates of the target samples. 
%  - Use them e.g. in displayImage(x, y, target)
% kernel
%  - Kernel function in the native spatial domain
% kernelFX, kernelFY 
%  - Spatial coordinates of the kernel samples
%
%
% REFERENCES:
%
% [Marathay04] Marathay, A. S., McCalmont, J. F., "On the usual approximation 
%      used in the Rayleigh-Sommerfeld diffraction theory", JOSA A, 21(4),
%      510-516 (2004).
%
% ---------------------------------------------
%
%  CGDH TOOLS
%  Petr Lobaz, lobaz@kiv.zcu.cz
%  Faculty of Applied Sciences, University of West Bohemia 
%  Pilsen, Czech Republic
%
%  Check http://holo.zcu.cz for more details and scripts.
%
% ---------------------------------------------
function [target, x, y, kernel, kernelX, kernelY] = ...
  propagate3fft(source, sourceDeltaYX, sourceMin, ...
                targetSize, targetMin, ...
                lambda, kernelType, filterType, ...
                displayKernel, saveKernel);

  % Resolve kernelType alias names
  if (isequalString(kernelType, 'Fresnel'))
    kernelType = 'FresnelXY';
  elseif (isequalString(kernelType, 'Exact'))
    kernelType = 'RayleighSommerfeldExact';
  end

  % For shorter code  
  [n, m] = size(source);
  q = targetSize(1);
  p = targetSize(2);
  
  % Calculate convolution size
  kn = convolutionSize(n, q);
  km = convolutionSize(m, p);
  
  % Source zero padding
  src = zeros(kn, km);
  src(1:n, 1:m) = source;

  % Convolution kernel
  [kernel, kernelX, kernelY] = kernelXY(kernelType, filterType, ...
    [n, m], [kn, km], sourceMin, targetMin, sourceDeltaYX, lambda);
    
  % Propagation calculation by convolution in the spatial domain
  kernelFT = fft2(genfftshiftPre(kernel, m, n));
  target = ifft2(fft2(src) .* kernelFT);
  target = target(1:q, 1:p);
  
  % Multiply the result by the sample area to get physically meaningful
  % numbers. This step is not necessary if we are going to normalize
  % the result anyway.
  target = target * (sourceDeltaYX(1) * sourceDeltaYX(2));

  % Coordinates of the target samples
  [x, y] = getXYVectorFromMin([q, p], sourceDeltaYX, targetMin);

  % Display and/or save kernel images for debugging purposes  
  if (displayKernel > 0 || ~isequalString(saveKernel, ''))
    if (displayKernel > 0)
      displayFlag = 1;
      figure(displayKernel);
      clf();
      subplot(2, 1, 1);
    else
      displayFlag = 0;
    end
    
    if (isequalString(saveKernel, ''))
      fnameA = '';
      fnameB = '';
    else
      fnameA = sprintf('%s_native(XY).png', saveKernel);
      fnameB = sprintf('%s_other(FxFy).png', saveKernel);
    end

    % Display/save the kernel in the spatial domain
    
    limits = displayImage(kernelX * 1e3, kernelY * 1e3, kernel, ...
      'complex', displayFlag, fnameA);

    % Annotate the graph if necessary
    if (displayKernel > 0)
      title(sprintf('Kernel in 3fft/%s/%s method, native spatial domain', ...
        kernelType, filterType));
      xlabel('x [mm]');
      ylabel('y [mm]');
      drawColorbar(limits);
      axis('image');
      % Draw lines showing kernel 'splitting'.
      % Their crossing shows position of cyclicKernelXY(0, 0), where
      % cyclicKernel is the kernel actually used in cyclic convolution.
      % Thus, cyclicKernelXY(0, 0) is the complex amplitude modification
      % from source[1, 1] to target[1, 1].
      drawLine([kernelX(m), kernelX(m)]*1e3, [kernelY(1), kernelY(end)]*1e3, 'red', 2);
      drawLine([kernelX(1), kernelX(end)]*1e3, [kernelY(n), kernelY(n)]*1e3, 'red', 2);
      gridOn([1, 1, 0], 0.6);
      subplot(2, 1, 2);
    end

    % Display/save the kernel in the frequency domain

    % Coordinates of the kernel in the frequency domain 
    % (see kernelFXFY() for details).
    kernelFX = ((0:km-1) - floor(km/2))/ (km * sourceDeltaYX(2));
    kernelFY = ((0:kn-1) - floor(kn/2))/ (kn * sourceDeltaYX(1));
    
    limits = displayImage(kernelFX * 1e-3, kernelFY * 1e-3, fftshift(kernelFT), ...
      'complex', displayFlag, fnameB);

    % Annotate the graph if necessary
    if (displayKernel > 0)
      title(sprintf('Kernel in 3fft/%s/%s method, FFT (frequency domain)', ...
        kernelType, filterType));
      xlabel('fx [mm^{-1}]');
      ylabel('fy [mm^{-1}]');
      drawColorbar(limits);
      axis('image');

      % Evaluate bounds of the kernel in the frequency domain.
      % Support of the kernel in the spatial domain limits which frequencies
      % are actually used in the kernel. Estimate them by local frequencies
      % of a spherical wave.
      % This is equivalent to 'angular???' filtering types used in '2fft' 
      % methods. See kernelFXFY() for details.
      
      % Propagation distance and the kernel center
      z0 = abs(targetMin(3) - sourceMin(3));
      xc = (kernelX(1) + kernelX(end)) / 2;
      yc = (kernelY(1) + kernelY(end)) / 2;
      
      % Local frequency estimate
      tmpX = [kernelX(1), kernelX(end),         xc,           xc];
      tmpY = [        yc,           yc, kernelY(1), kernelY(end)];
      tmpR = sqrt(tmpX.^2 + tmpY.^2 + z0^2);
      lxMin = kernelX(1) / (lambda * tmpR(1));
      lxMax = kernelX(end) / (lambda * tmpR(2));
      lyMin = kernelY(1) / (lambda * tmpR(3));
      lyMax = kernelY(end) / (lambda * tmpR(4));
      
      % Draw bounds
      if (lxMin >= kernelFX(1))
        drawLine([lxMin, lxMin]*1e-3, [kernelFY(1), kernelFY(end)]*1e-3, 'red', 2);
      end
      if (lxMax <= kernelFX(end))
        drawLine([lxMax, lxMax]*1e-3, [kernelFY(1), kernelFY(end)]*1e-3, 'red', 2)
      end
      if (lyMin >= kernelFY(1)) 
        drawLine([kernelFX(1), kernelFX(end)]*1e-3, [lyMin, lyMin]*1e-3, 'red', 2)
      end
      if (lyMax <= kernelFY(end))
        drawLine([kernelFX(1), kernelFX(end)]*1e-3, [lyMax, lyMax]*1e-3, 'red', 2)
      end
      gridOn([1, 1, 0], 0.6);
    end
  end
end
  
