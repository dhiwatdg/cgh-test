% Example propagation of coherent light
%
% Compares propagation of coherent light calculated using a convolution based
% method (3fft or 2fft) and a Fourier transform based method (1fft). 
%
% A source "image" is created in the plane z = 0. Subsequently, it is propagated 
% to the plane z = targetZ to a rectangular area "target". 
%
% The comparison tries to set the target size of the convolution based method 
% (3fft or 2fft) so that it is the same as the result of the 1fft method.
%
% Figure 1 shows the source image and the light intensity in the target 
% calculated using two different methods.
% In case displayKernel is set to true, Figures 2 and 3 show important functions
% used in light propagation calculation.
%
% The demo provides several carefully selected experiments that lead to results 
% that can be easily visually analyzed and compared. In particular:
% Set experiment=0 to watch interference of two point light sources.
% Set experiment=1 to watch diffraction on a square aperture.
% Set experiment=2 to watch diffraction on a sine amplitude grating.
%
% For details on light propagation calculation, see DEMO_singlePropagate.
%
% See also demos DEMO_compare3fft2fft and DEMO_compare1fft1fft for comparison
% of two convolution based methods and of two Fourier transform based methods.
%
%
% Generally, the propagation using 1ff method is calculated as
%   target = kernelXY .* FFT( source .* kernelXiEta )
% where 
%   source is the phasor in the source plane,
%   target is the phasor in the target plane,
%   kernelXiEta
%   kernelXY are the auxiliary functions, usually
%     const * exp(j * const * (x^2 + y^2))
%
% The propagation using 2fft method is calculated as
%   target = IFFT(FFT(source) .* kernelFXFY)
% where
%   kernelFXFY is the auxiliary function calculated in the frequency domain.
%
% The propagation using 3fft method is calculated as
%   target = IFFT(FFT(source) .* FFT(kernelXY))
% where 
%   kernelXY is the auxiliary function calculated in the spatial domain.
%
% Set the propagation parameters below and watch the result in Figure 1.
% The auxiliary functions (propagation kernels) are displayed in Figures 2 and 3.
% For convenience, the kernels used in convolution based methods
% are displayed in their native domain (spatial or frequency) as well as
% in the other domain. This gives better insight into kernels.
% The resulting images should be displayed carefully as their high frequency
% details are prone to visual clutter (aliasing). The images shown in
% Figures 2 and 3 should not be taken too seriously, as Octave/MATLAB/Scilab
% cannot display such images properly.
% Thus, all results are saved to image files. They should be viewed using
% an image viewer that allows 1:1 pixel mapping, i.e. one pixel of the image
% is displayed using one pixel of the LCD display. For instance, most
% web browsers display images in that way.
% To turn Figures 2 and 3 off, just set displayKernel to false.
%
% The source is saved to 
%   'compare3fft1fft_sourceAbs.png'.
% The propagations are saved to 
%   'compare3fft1fft_targetA.png', 
%   'compare3fft1fft_targetB.png'
% Note that the image files have different pixel resolution 
% due to nature of the propagation methods!
%
% The kernel for the convolution based method in both the spatial and the 
% frequency domains is saved (in case displayKernels is true) to 
%   'compare3fft1fft_kernelA_???.png'.
% The suffix in the 3-FFT/2-FFT kernel file name indicates:
%   native - the function is used in this form (this domain)
%   other - FFT or IFFT of the 'native' form
%   (XY) - spatial domain
%   (FxFy) - frequency domain
%
% The kernels (i.e. the auxiliary phase multipliers) for the 1-FFT methods
% are saved to 
%   'compare3fft1fft_kernelB_XY.png'
%   'compare3fft1fft_kernelB_XiEta.png'
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

%
% ALL DIMENSIONS ARE IN METRES
%
addpath(genpath('../cgdhtools'));

% Wavelength, a green DPSS laser
lambda = 532e-9;

% Scilab compatibility
imagUnit = sqrt(-1);
piNumber = pi;

% Display the propagation kernel details?
displayKernel = true;

% Sampling distance, physical size and location of the source
sourceDelta = 10e-6;
sourceWidth = 1e-3;
sourceHeight = 1e-3;
sourceCenter = [0, 0, 0];

% Choose between two point lights interference (0) 
% diffraction on a square aperture (1)
% and diffraction on a sinusoidal amplitude grating (2)
experiment = 2;

% Set up the source matrix
sourceDeltaYX = getDeltaYX(sourceDelta);
sourceSize = calculateSamples([sourceHeight, sourceWidth], sourceDeltaYX);
source = zeros(sourceSize(1), sourceSize(2));

switch (experiment)
case 0
  %
  % Two point light sources
  %
  lightSource1 = [-100e-6, 0];
  lightSource2 = [100e-6, 0];
  tmpCenter = centerToMin(sourceCenter, size(source), sourceDeltaYX);
  index1 = floor((lightSource1 - tmpCenter(1:2))./sourceDeltaYX + 0.5);
  index2 = floor((lightSource2 - tmpCenter(1:2))./sourceDeltaYX + 0.5);
  source(index1(2), index1(1)) = 1;
  source(index2(2), index2(1)) = 1;
  sourceDescription = sprintf('Point sources at [%.1f, %.1f, %.1f] and [%.1f, %.1f, %.1f] [mm]', ...
    lightSource1(1)*1e3, lightSource1(2)*1e3, sourceCenter(3)*1e3, ...
    lightSource2(1)*1e3, lightSource2(2)*1e3, sourceCenter(3)*1e3);
case 1
  %
  % Rectangular aperture
  %
  lightWidth = 0.8e-3;
  lightHeight = 0.8e-3;
  xInd = floor(sourceSize(2)/2) + [-0.5,0.5] * floor(lightWidth / sourceDeltaYX(2) + 0.5);
  yInd = floor(sourceSize(1)/2) + [-0.5,0.5] * floor(lightWidth / sourceDeltaYX(1) + 0.5);
  source(yInd(1):yInd(2), xInd(1):xInd(2)) = 1;
  sourceDescription = sprintf('Rectangular aperture %.1f x %.1f [mm] in z = 0', ...
    lightWidth * 1e3, lightHeight * 1e3);
case 2
  %
  % Sine amplitude grating
  %
  [x, y] = getXYVectorFromCenter(size(source), sourceDeltaYX, sourceCenter);
  [xx, yy] = meshgrid(x, y);
  freq = 20e3;
  source = 0.5 + 0.5*cos(2*piNumber*freq*xx);
  sourceDescription = sprintf('Sine amplitude grating, f = %.1f mm^{-1} in z = 0', ...
    freq*1e-3);
otherwise
  error('Unknown experiment. Select correct experiment number (0, 1, 2).');
end

% Sampling distance, physical size and location of the target
targetCenter = [0e-3, 0e-3, 200e-3];

% Find the target parameters for 1-FFT method first
targetBSize = sourceSize;
targetBDeltaYX = get1fftTargetDeltaYX(lambda, sourceSize, sourceDeltaYX, targetCenter(3)-sourceCenter(3));
targetBWidth = sourceSize(2)*targetBDeltaYX(2);
targetBHeight = sourceSize(1)*targetBDeltaYX(1);

% Try to set the targetA parameters as similar to targetB as possible
targetADelta = sourceDelta;
targetAWidth = targetBWidth;
targetAHeight = targetBHeight;
targetASize = calculateSamples([targetAHeight, targetAWidth], targetADelta);

% Propagation methods
% Target A must be calculated using convolution based method (2fft or 3fft)
% Target B must be calculated using Fourier transform based method (1fft )
% See DEMO_singlePropagate for details on parameters
propagationMethodA = '3fft';
kernelTypeA = 'Fresnel';
filteringMethodA = 'localExact';

propagationMethodB = '1fft';
kernelTypeB = 'Fresnel';
filteringMethodB = 'localExact';

% Set variables for displaying/saving kernels
if (displayKernel)
  fileNameKernelA = 'compare3fft1fft_kernelA';
  fileNameKernelB = 'compare3fft1fft_kernelB';
  figureKernelA = 2;
  figureKernelB = 3;
else
  fileNameKernelA = '';
  fileNameKernelB = '';
  figureKernelA = 0;
  figureKernelB = 0;
end

 
% Propagate the source to the target
[targetA, xA, yA, targetADeltaYX, kernelA] = propagate(source, sourceDelta, sourceCenter, ...
  targetASize, targetADelta, targetCenter, ...
  lambda, propagationMethodA, kernelTypeA, filteringMethodA, ...
  figureKernelA, fileNameKernelA);

 [targetB, xB, yB, targetBDeltaYX, kernelB] = propagate(source, sourceDelta, sourceCenter, ...
  targetBSize, targetBDeltaYX, targetCenter, ...
  lambda, propagationMethodB, kernelTypeB, filteringMethodB, ...
  figureKernelB, fileNameKernelB);
  
% Display the result
figure(1);
clf();
  
subplot(3, 1, 1);
[sourceX, sourceY] = getXYVectorFromCenter(size(source), sourceDelta, sourceCenter);
limits = displayImage(sourceX*1e3, sourceY*1e3, abs(source), 'positive', 1, 'compare3fft1fft_sourceAbs.png');
xlabel('x [mm]');
ylabel('y [mm]');
title(sourceDescription);
drawColorbar(limits);
axis('image');


subplot(3, 1, 2);
limits = displayImage(xA*1e3, yA*1e3, abs(targetA).^2, 'positive', 1, 'compare3fft1fft_targetAIntensity.png');
xlabel('x [mm]');
ylabel('y [mm]');
title(sprintf('Target A %s/%s/%s (intensity) at [%g, %g, %g] mm', ...
  propagationMethodA, kernelTypeA, filteringMethodA, ...
  targetCenter(1)*1e3, targetCenter(2)*1e3, targetCenter(3)*1e3));
drawColorbar(limits);
axis('image');

subplot(3, 1, 3);
limits = displayImage(xB*1e3, yB*1e3, abs(targetB).^2, 'positive', 1, 'compare3fft1fft_targetBIntensity.png');
xlabel('x [mm]');
ylabel('y [mm]');
title(sprintf('Target B %s/%s/%s (intensity) at [%g, %g, %g] mm', ...
  propagationMethodB, kernelTypeB, filteringMethodB, ...
  targetCenter(1)*1e3, targetCenter(2)*1e3, targetCenter(3)*1e3));
drawColorbar(limits);
axis('image');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END OF THE SCRIPT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
