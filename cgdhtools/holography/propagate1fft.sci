// Propagates the source plane to the parallel target plane using single Fourier 
// transform (1fft). This method requires equal sizes of the source and the 
// target arrays. Note that the sampling distance of the target is not the same 
// as of the source.
//
// The target is given by kernelXY .* FFT( source .* kernelXiEta )
// where FFT/IFFT stands for the fast Fourier transform and its inverse,
// kernelXY and kernelXiEta are function determined by kernelType.
//
// Inputs:
// source
//  - Complex array of the phasors in the source plane.
// sourceDeltaYX
//  - Sampling distance of the source plane.
//  - Must be vector [deltaY, deltaX]
// sourceCenter
//  - Location [x, y, z] of the center of the source area.
// targetSize
//  - [rows, columns]
//  - Number of samples of the target matrix
//  - Currently it must be the same as the size of source.
// targetDeltaYX 
//  - Vector [deltaY, deltaX] of the target sampling distances.
//  - It should be calculated using get1fftTargetDeltaYX().
// targetCenter
//  - Location [x, y, z] of the center of the target area.
//  - Currently it makes little sense set x, y different from sourceCenter.
//  - Normally, light should be propagated from 'smaller Z' to 'larger Z', i.e.
//    sourceCenter(3) < targetCenter(3)
//  - In the opposite case, i.e. when sourceCenter(3) > targetCenter(3),
//    backpropagation is calculated.
// lambda        
//  - The wavelength.
// kernelType    
//  - Type of the propagation kernel
//  - Implemented types are
//    'Fresnel'
//      The Fresnel diffraction approximation, see [Goodman], Chapter 4.
//      Generally useful for larger propagation distances. 
//      For short propagation distances, the function kernelXiEta inside FFT
//      can be aliased.
//      Note that either kernelXY or kernelXiEta is aliased, but aliasing of
//      kernelXY is not important if we are interesten in the target intensity 
//      only.
//    'Fraunhofer'
//      The Fraunhofer diffraction approximation, see [Goodman], Chapter 4.
//      Generally useful for very large propagation distances. 
//      In fact, there is little reason to use it as the 'Fresnel' covers
//      both cases and the computational complexity is the same.
//      It is implemented for educational purposes only.
// filterType    
//  - The kernelXiEta function can be aliased. FilterType determines what to do.
//    Note that aliasing of kernelXY is not affected by filterType.
//  - In general, local frequency of the kernelXiEta is evaluated at each point.
//  - Type:
//    'none'
//      Does nothing, i.e. the kernelXiEta stays aliased.
//    'localExact' 
//      Makes the kernelXiEta 0 at points where the local frequency is too high.
//    'localRect'
//      Is similar to 'localExact', but the aliasing-free area is estimated by
//      a rectangle. It is computationally cheaper, but generally less precise. 
//      In case of 'Fresnel' and 'Fraunhofer' types, the aliasing-free zone
//      is always a rectangle, i.e. 'localExact' and 'localRect' are exactly 
//      the same.
// displayKernel
//  - Displays the kernel function in Figure(displayKernel).
//  - 0 switches the kernel display off (default)
// saveKernel
//  - Saves the kernel to image files 'saveKernel????.png', where ???? indicates
//    the function inside (_XiEta) or outside (_XY) the FFT.
//  - '' switches the kernel saving off (default)
//
// Outputs:
// target        
//  - Complex matrix of phasors in the target area.
// x, y          
//  - Coordinates of the target samples. 
//  - Use them e.g. in displayImage(x, y, target)
// kernel
//  - KernelXiEta used inside the Fourier transform (useful for educational purposes).
//
//
// NOTES
// TODO: 'localRect' and 'localExact' use the same algorithm, although
// 'localRect' can be made more efficient. 
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
function [target, x, y, kernel] = ...
  propagate1fft(source, sourceDeltaYX, sourceCenter, ...
                targetSize, targetDeltaYX, targetCenter, ... 
                lambda, kernelType, filterType, ...
                displayKernel, saveKernel)

  // Check filterType                
  if (~isequalString(filterType, 'localExact') && ...
      ~isequalString(filterType, 'localRect') && ...
      ~isequalString(filterType, 'none'))
    error(sprintf('Unknown filtering type: %s\n', filterType));
  end
  
  // For shorter code  
  [n, m] = size(source);
  q = targetSize(1);
  p = targetSize(2);

  // Get shift vector between source and target
  px = targetCenter(1) - sourceCenter(1);
  py = targetCenter(2) - sourceCenter(2);
  z0 = targetCenter(3) - sourceCenter(3);
  
  if (~(isequalFloat(px, 0) && isequalFloat(py, 0)))
    warning('Off-axis propagation is not supported by 1fft propagation method');
    px = 0;
    py = 0;
  end

  // Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = %pi

  // Wave number
  k = 2*piNumber/lambda;
  
  // Assume that 
  //   sourceCenter = [0, 0, 0],
  //   targetCenter = [px, py, z0]
  
  // Prepare coordinates for kernelXiEta
  // Note that (0,0) is in the array center
  xi = ((0:m-1) - floor(m/2)) * sourceDeltaYX(2);
  eta = ((0:n-1) - floor(n/2)) * sourceDeltaYX(1);
  [xixi, etaeta] = meshgrid(xi, eta);
  
  // Prepare coordinates for kernelXY
  // Note that (0,0) is in the array center if px, py = 0
  x = ((0:p-1) - floor(p/2)) * targetDeltaYX(2) + px;
  y = ((0:q-1) - floor(q/2)) * targetDeltaYX(1) + py;
  [xx, yy] = meshgrid(x, y);
  
  // Switch the sign of the imaginary unit for backpropagation.
  if (z0 < 0)
    jj = -imagUnit;
  else
    jj = imagUnit;
  end

  switch (kernelType)
    case 'Fresnel'
      kernelXiEta = exp(jj * k * ...
                        ((xixi).^2 + (etaeta).^2) ./ (2*z0)); 
      kernelXY = exp(jj * k * z0) / ...
                 (jj * lambda * z0) .* ...
                 exp(jj * k * (xx.*xx + yy.*yy) ./ (2*z0)); 
                 
      // Filter high frequencies
      if (isequalString(filterType, 'localExact') || ...
          isequalString(filterType, 'localRect'))
        lfxi = abs(xixi) / (lambda * z0);
        lfeta = abs(etaeta) / (lambda * z0);
        kernelXiEta(lfxi >= 0.5/sourceDeltaYX(2)) = 0;
        kernelXiEta(lfeta >= 0.5/sourceDeltaYX(1)) = 0;
      end
    case 'Fraunhofer'
      kernelXiEta = ones(size(xx, 1), size(xx, 2)); 
      kernelXY = exp(jj * k * z0) / (jj * lambda * z0) .* ...
                 exp(jj * k * (xx.*xx + yy.*yy) ./ (2*z0)); 
                 
      // Filter high frequencies
      if (isequalString(filterType, 'localExact') || ...
          isequalString(filterType, 'localRect'))
        lfxi = abs(xixi) / (lambda * z0);
        lfeta = abs(etaeta) / (lambda * z0);
        kernelXiEta(lfxi >= 0.5/sourceDeltaYX(2)) = 0;
        kernelXiEta(lfeta >= 0.5/sourceDeltaYX(1)) = 0;
      end
    otherwise
      error(sprintf('Unknown kernel type: %s\n', kernelType));
  end
  
  // Propagation calculation by the Fourier transform
  target = kernelXY .* ...
              fftshift(fft2(ifftshift(kernelXiEta .* source))) ...
            * sourceDeltaYX(1) * sourceDeltaYX(2);
  kernel = kernelXiEta;
  
  // Provide correct coordinates in the target plane
  // NOTE: px, py are currently 0
  // TODO: check this when calculating off-axis propagation
  x = x - px + sourceCenter(1);
  y = y - py + sourceCenter(2);

  // Display and/or save kernel images
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
      fnameA = sprintf('%s_XiEta.png', saveKernel);
      fnameB = sprintf('%s_XY.png', saveKernel);
    end

    limits = displayImage(xi * 1e3, eta * 1e3, kernelXiEta, 'complex', ...
      displayFlag, fnameA);
    if (displayKernel > 0)
      title(sprintf('KernelXiEta in 1fft/%s/%s method (inside FT)', ...
        kernelType, filterType));
      xlabel('xi [mm]');
      ylabel('eta [mm]');
      drawColorbar(limits);
      gca().isoview = 'on'; gca().tight_limits = 'on';
      gridOn([0, 0, 0], 0.8);
      subplot(2, 1, 2);
    end

    limits = displayImage(x * 1e3, y * 1e3, kernelXY, 'complex', ...
      displayFlag, fnameB);
    if (displayKernel > 0)
      title(sprintf('KernelXY in 1fft/%s/%s method (outside FT)', ...
        kernelType, filterType));
      xlabel('x [mm]');
      ylabel('y [mm]');
      drawColorbar(limits);
      gca().isoview = 'on'; gca().tight_limits = 'on';
      gridOn([0, 0, 0], 0.8);
    end
  end
end        
  
  