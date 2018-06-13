% Propagates the optical field SOURCE to the TARGET area using specified method
% It mostly serves as a dispatcher that calls a specialized propagation function
% such as propagate1fft, propagate2fft, propagate3fft.
%
% Inputs:
% source        
%  - Complex array of the phasors in the source plane.
% sourceDelta   
%  - Sampling distance of the source plane.
%  - It can be a number or a vector [deltaY, deltaX].
% sourceCenter  
%  - Location [x, y, z] of the center of the source area.
% targetSize    
%  - [rows, columns]
%  - Number of samples of the target matrix
%  - [] for automatic decision
% inTargetDelta 
%  - Desired sampling distance of the target optical field. Actual sampling
%    distance of the result is given as one of the output parameters.
%  - It can be a number or a vector [deltaY, deltaX].
%  - [] for automatic decision.
% targetCenter  
%  - Location [x, y, z] of the center of the target area.
% lambda        
%  - The wavelength.
% method        
%  - The propagation method. Currently implemented methods are:
%    '3fft'
%      The target is given by IFFT( FFT(source) .* FFT(kernelXY) ),
%      where FFT/IFFT stands for the fast Fourier transform and its inverse,
%      kernelXY is a function determined by kernelType.
%      3fft methods are generally useful for longer propagation distances.
%      3fft methods require the same sampling distances of the source and the 
%      target.
%    '2fft'
%      The target is given by IFFT( FFT(source) .* kernelFXFY ),
%      where FFT/IFFT stands for the fast Fourier transform and its inverse,
%      kernelFXFY is a function determined by kernelType.
%      2fft methods are generally useful for shorter propagation distances.
%      2fft methods require the same sampling distances of the source and the 
%      target.
%    '1fft'
%      The target is given by kernelXY .* FFT( source .* kernelXiEta ),
%      where FFT/IFFT stands for the fast Fourier transform and its inverse,
%      kernelXY and kernelXiEta are function determined by kernelType.
%      1fft methods are generally useful for longer propagation distances.
%      1fft methods require the same number of samples in the source and the 
%      target. The sampling distance of the target is determined by the
%      wavelength, the propagation distance and the physical size of the 
%      source. This sampling distance can be determined using get1fftTargetDeltaYX
% kernelType    
%  - Type of the kernel function used in a particular propagation method.
%  - See functions propagate1fft, propagate2fft, propagate3fft for supported
%    kernels
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
%  - 0 switches the kernel display off (default)
% saveKernel
%  - Saves the kernel to image files 'saveKernel????.png', where ???? indicates
%    the spatial or the frequency domain.
%  - '' switches the kernel saving off (default)
%
% Outputs:
% target        
%  - Complex matrix of phasors in the target area.
% x, y          
%  - Coordinates of the target samples. 
%  - Use them e.g. in displayImage(x, y, target)
% targetDeltaYX 
%  - Actual sampling distances (y, x) of the target area.
%  - Depending on the propagation method, can be different from inTargetDelta
% kernel
%  - Matrix of the kernel samples (useful for educational purposes)
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
function [target, x, y, targetDeltaYX, kernel] = ...
  propagate(source, sourceDelta, sourceCenter, ...
        targetSize, inTargetDelta, targetCenter, ...
        lambda, method, kernelType, filterType, ...
        displayKernel, saveKernel)

  % Set default values        
  if (nargin < 12)
    saveKernel = '';
  end
  if (nargin < 11)
    displayKernel = 0;
  end
  
  sourceDeltaYX = getDeltaYX(sourceDelta);

  % Call appropriate propagation method  
  switch (method)
    case '3fft'
      % Set default targetSize
      if (isempty(targetSize))
        targetSize = size(source);
      end
      
      % Set and check the target sampling distances
      targetDeltaYX = getDeltaYX(inTargetDelta, sourceDeltaYX);
      if (sourceDeltaYX(1) ~= targetDeltaYX(1) || ...
          sourceDeltaYX(2) ~= targetDeltaYX(2))
        error('propagate: Source and target deltas must be tha same for the 3fft method.');
      end
      
      % Propagate
      [target, x, y, kernel] = propagate3fft(source, sourceDeltaYX, ...
                   centerToMin(sourceCenter, size(source), sourceDeltaYX), ...
                   targetSize, ...
                   centerToMin(targetCenter, targetSize, targetDeltaYX), ...
                   lambda, kernelType, filterType, ...
                   displayKernel, saveKernel);
    case '2fft'
      % Set default targetSize
      if (isempty(targetSize))
        targetSize = size(source);
      end

      % Set and check the target sampling distances
      targetDeltaYX = getDeltaYX(inTargetDelta, sourceDeltaYX);
      if (sourceDeltaYX(1) ~= targetDeltaYX(1) || ...
          sourceDeltaYX(2) ~= targetDeltaYX(2))
        error('propagate: Source and target deltas must be tha same for the 2fft method.');
      end

      % Propagate
      [target, x, y, kernel] = propagate2fft(source, sourceDeltaYX, ...
                         centerToMin(sourceCenter, size(source), sourceDeltaYX), ...
                         targetSize, ...
                         centerToMin(targetCenter, targetSize, targetDeltaYX), ...
                         lambda, kernelType, filterType, ...
                         displayKernel, saveKernel);
    case '1fft'
      % Check and set target size
      if (isempty(targetSize))
        targetSize = size(source);
      elseif (~isequal(size(source), targetSize))
        error('propagate: Source and target sizes must be the same for 1fft method.');
      end
      
      propagationDistance = targetCenter(3) - sourceCenter(3);

      % Set and check the target sampling distances
      targetDeltaYX = get1fftTargetDeltaYX(lambda, size(source), ...
        sourceDeltaYX, propagationDistance);
      if (~isempty(inTargetDelta))
        inTargetDeltaYX = getDeltaYX(inTargetDelta, []);
        if (~isequal(inTargetDeltaYX, targetDeltaYX))
          error('propagate: Target delta should be [] or properly set using get1fftTargetDeltaYX.');
        end
      end
      
      % Propagate
      [target, x, y, kernel] = propagate1fft(source, sourceDeltaYX, ...
        sourceCenter, ...
        targetSize, targetDeltaYX, ...
        targetCenter, ...
        lambda, kernelType, filterType, ...
        displayKernel, saveKernel);
  end
end