// Example propagation of coherent light
//
// A source "image" is created in the plane z = 0. It consists of two points
// separated by pointsDistance. Subsequently, it is propagated to the plane 
// z = targetZ to a rectangular area "target". 
//
// Figure 1 shows the source image and the light intensity in the target. 
// Interference fringes should be clearly visible. 
// Figure 2 shows complex value of light phasor in the target.
// For convenience, a brief analysis is written to the console, its 
// result should match the propagation result.
// In case displayKernel is set to %T, Figure 3 shows important functions
// used in light propagation calculation.
//
// The resulting images should be displayed carefully as their high frequency
// details are prone to visual clutter (aliasing). The images shown in
// Figures 2 and 3 should not be taken too seriously, as Octave/MATLAB/Scilab
// cannot display such images properly.
// Thus, all results are saved to image files. They should be viewed using
// an image viewer that allows 1:1 pixel mapping, i.e. one pixel of the image
// is displayed using one pixel of the LCD display. For instance, most
// web browsers display images in that way.
//
// The absolute value of the source is saved to the file
//   singlePropagate_sourceAbs.png
// The complex phasor of the propagated light is saved to the file
//   singlePropagate_targetCplx.png
// The intensity of the propagated light is saved to the file
//   singlePropagate_targetIntensity.png
// The images from Figure 3 are saved (in case displayKenels is %T) to 
// files 'singlePropagate_kernel???.png'. See notes below for their detailed 
// description.
//
//
// The demo allows to set various light propagation techniques. There are three 
// basic calculation methods:
//
// - 3fft: light propagation is calculated as convolution in the spatial domain.
//   For efficiency, it is calculated using FFT as
//     target = IFFT( FFT(source) .* FFT(kernelXY) )
//   where kernelXY is a special function in the spatial domain defined by 
//   kernelType. Examples of kernelType are 'FresnelXY' or 'RayleighSommerfeldExact'. 
//   A complete list is given in the code of the demo.
//   The kernelXY is saved to file
//     singlePropagate_kernel_native(XY).png
//   For convenience, its Fourier transform is saved to file 
//     singlePropagate_kernel_other(FxFy).png
//
// - 2fft: light propagation is calculated as convolution in the frequency domain.
//   It is calculated using FFT as
//     target = IFFT( FFT(source) .* kernelFXFY )
//   where kernelFXFY is a special function in the frequency domain defined by 
//   kernelType. Examples of kernelType are 'FresnelFXFY' or 'AngularSpectrumExact'. 
//   A complete list is given in the code of the demo.
//   The kernelFXFY is saved to file
//     singlePropagate_kernel_native(FxFy).png
//   For convenience, its inverse Fourier transform is saved to file 
//     singlePropagate_kernel_other(XY).png
//
// - 1fft: light propagation is calculated using single FFT as
//     target = kernelXY .* FFT( source .* kernelXiEta )
//   where kernelXY and kernelXiEta are a special functions in the spatial domain.
//   Both are defined by kernelType, which can be 'Fresnel' or 'Fraunhofer'. 
//   Both functions are saved to files
//     singlePropagate_kernel_XiEta.png
//     singlePropagate_kernel_XY.png
//
//
// The demo allows to play with geometry of the source and location and
// size of the target.
// To compare two propagation methods side by side, check demos
//   DEMO_compare3fft2fft  (compare two convolution based methods)
//   DEMO_compare3fft1fft  (compare a convolution based and a FT based methods)
//   DEMO_compare1fft1fft  (compare two FT based methods)
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

//
// ALL DIMENSIONS ARE IN METRES
//
cgdhPath = '../cgdhtools'; exec(strcat([cgdhPath, '/loadSubfolders.sce']));

// Wavelength, a green DPSS laser
lambda = 532e-9;

// Display the propagation kernel details?
displayKernel = %T;

// Sampling distance, physical size and location of the source
sourceDelta = 20e-6;
sourceWidth = 3e-3;
sourceHeight = 3e-3;
sourceCenter = [0, 0, 0];

// Set up the source matrix - two point light sources
sourceSize = calculateSamples([sourceHeight, sourceWidth], sourceDelta);
source = zeros(sourceSize(1), sourceSize(2));
pointsDistance = sourceHeight * 0.1;
centerColumn = floor(sourceSize(2) / 2);
source(floor((sourceHeight - pointsDistance) / 2 / sourceDelta + 0.5), centerColumn) = 1;
source(floor((sourceHeight + pointsDistance) / 2 / sourceDelta + 0.5), centerColumn) = 1;

// Select propagation method and the kernel calculation type
// Note that each propagation method allows different kernel types.
// For convenience, the type 'Fresnel' is defined for all propagation methods,
// in each method it is interpreted in a specific way (i.e. calculation of
// a certain function in the spatial or the frequency domain).
// The type 'Exact' can be used for 2fft and 3fft calculation types,
// where is means AngularSpectrumExact or RayleighSommerfeldExact, respectively.
//
//
// 3fft available parameters
//                                            
propagationMethod = '3fft';
kernelType = 'RayleighSommerfeldExact';     // Full RS definition 
//  kernelType = 'Exact';                    // (This is just an alias for 
                                            //  RayleighSommerfeldExact when using 
                                            //  3fft method)
//  kernelType = 'RayleighSommerfeldSimple'; // RS without 1/r term
//  kernelType = 'FresnelXY';                // Fresnel kernel in the spatial domain
//  kernelType = 'Fresnel';                  // (This is just an alias for FresnelXY 
                                            //  when using 3fft method)
//  kernelType = 'SphericalWave';            // Huygens spherical wavelet 
                                            //  (just for curiosity)

//
// 2fft available parameters
//                                            
// propagationMethod = '2fft';
// kernelType = 'AngularSpectrumExact';        // FT of the exact Rayleigh-Sommerfeld kernel
// kernelType = 'Exact';                       // (This is just an alias for 
//                                             //  AngularSpectrumExact when using 
//                                             //  2fft method)
// kernelType = 'AngularSpectrumNoEvanescent'; // Like AngularSpectrumExact without evanescent waves
// kernelType = 'FresnelFXFY';                 // Fresnel kernel in the frequency domain
// kernelType = 'Fresnel';                     // (This is just an alias for FresnelFXFY 
                                              //  when using 3fft method)

//
// 1fft available parameters
//                                            
// propagationMethod = '1fft';
// kernelType = 'Fresnel';                     // Classical Fresnel (near field) approximation
// kernelType = 'Fraunhofer';                  // Classical Fraunhofer (far field) approximation

// As the kernel calculation is prone to aliasing, it is possible to 
// detect its aliased part and to set its samples to zero. While it cannot be
// strictly said this procedure is better than to do nothing, it is usually
// safer to clip the aliased part.
//
// Note that 3fft methods do not cause aliasing for large propagation distances,
// while 2fft methods do not cause aliasing for short propagation distances.
//
// 1fft methods are somewhat strange as some aliasing occurs for any propagation
// distance. Generally, it is better to use them for large propagation distance.
// In that case, the function used inside the Fourier transform (xi-eta 
// coordinates) is not aliased, while the phase multiplier outside the Fourier
// transform (x-y coordinates) is aliased. It means that at least the amplitude
// of the result is correct.
// For short propagation distances, the function inside the Fourier transform
// is aliased, which means that the whole result is flawed.
//
// filteringMethod = 'none';            // Do not filter aliased part. This is 
                                       //  especially useful if we are sure that
                                       //  aliasing does not occur.
filteringMethod = 'localExact';        // Clip exactly those samples that cause aliasing
                                       //  (based on local frequency evaluation)
// filteringMethod = 'localRect';       // Estimate the aliased part by a rectangle
                                       //  and clip it. Note that in most practical
                                       //  cases it is mostly the same as localExact.

// Following 'angular' filterTypes are applicable for 2fft method only.
// More details can be found in kernelFXFY.
// Check DEMO_compare3fft2fft to see how 'angular' types actually work.
//
// filteringMethod = 'angular';           // Clip the transfer function according
                                         // to the extent of the convolution kernel
                                         // in the spatial domain.
// filteringMethod = 'angularLocalExact'; // Like 'localExact' + 'angular'
// filteringMethod = 'angularLocalRect';  // Like 'localRect' + 'angular'

                                       
targetZ = 500e-3;
targetCenter = [0, 0, targetZ];

//
// Sampling distance, physical size and location of the target
//
if (isequalString(propagationMethod, '3fft') || ...
    isequalString(propagationMethod, '2fft'))
  // For convolution based methods (2fft, 3fft), it is possible
  // to define any target dimensions. The sampling distance must be, however,
  // the same as the source sampling distance.
  targetDelta = sourceDelta;
  targetWidth = 6e-3;
  targetHeight = 3e-3;
  targetSize = calculateSamples([targetHeight, targetWidth], targetDelta);
elseif (isequalString(propagationMethod, '1fft'))
  // For the Fourier transform based method (1fft), the target dimensions
  // and the target sampling distance are given by the propagation distance
  // and the wave length. Number of samples of the target and the source is
  // the same.
  targetDelta = [];   // to be determined automatically
  targetSize = [];    // to be automatically set to sourceSize
else
  error(sprintf('Unknown propagation method: %s\n', propagationMethod));
end


// Set variables for displaying/saving kernels
if (displayKernel)
  fileNameKernel = 'singlePropagate_kernel';
  figureKernel = 3;
else
  fileNameKernel = '';
  figureKernel = 0;
end

// Print the experiment characteristics
fringesPeriod = lambda / sin(atan(pointsDistance / targetZ));
mprintf('Point light sources (lambda = %.1f nm) are %.3f mm apart.\n', ...
  lambda * 1e9, pointsDistance * 1e3);
mprintf('Thus, in the plane z = %.1f mm they should create interference fringes\n', ...
  targetZ * 1e3);
mprintf('with spatial frequency %.3f mm^-1, i.e. the fringes should be %.3f mm apart.\n', ...
  1e-3 / fringesPeriod, fringesPeriod * 1e3);


// Propagate the source to the target
[target, x, y] = propagate(source, sourceDelta, sourceCenter, ...
  targetSize, targetDelta, targetCenter, ...
  lambda, propagationMethod, kernelType, filteringMethod, ...
  figureKernel, fileNameKernel);

// Display the result
scf(1); gcf().background = -2;
clf();

subplot(2, 1, 1);
[sourceX, sourceY] = ...
  getXYVectorFromCenter(size(source), sourceDelta, sourceCenter);
limits = displayImage(sourceX*1e3, sourceY*1e3, abs(source), 'positive', 1, ...
  'singlePropagate_sourceAbs.png');
xlabel('x [mm]');
ylabel('y [mm]');
title(sprintf('Source image (abs. value) located at [%g, %g, %g] mm', ...
  sourceCenter(1)*1e3, sourceCenter(2)*1e3, sourceCenter(3)*1e3));
drawColorbar(limits);
gca().isoview = 'on'; gca().tight_limits = 'on';

subplot(2, 1, 2);
limits = displayImage(x*1e3, y*1e3, abs(target).^2, 'positive', 1, 'singlePropagate_targetIntensity.png');
xlabel('x [mm]');
ylabel('y [mm]');
title(sprintf('Target by %s/%s/%s (intensity) at [%g, %g, %g] mm', ...
  propagationMethod, kernelType, filteringMethod, ...
  targetCenter(1)*1e3, targetCenter(2)*1e3, targetCenter(3)*1e3));
drawColorbar(limits);
gca().isoview = 'on'; gca().tight_limits = 'on';


scf(2); gcf().background = -2;
clf();
limits = displayImage(x*1e3, y*1e3, target, 'complex', 1, 'singlePropagate_targetCplx.png');
xlabel('x [mm]');
ylabel('y [mm]');
title(sprintf('Target by %s/%s/%s (complex value) at [%g, %g, %g] mm', ...
  propagationMethod, kernelType, filteringMethod, ...
  targetCenter(1)*1e3, targetCenter(2)*1e3, targetCenter(3)*1e3));
drawColorbar(limits);
gca().isoview = 'on'; gca().tight_limits = 'on';




//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// END OF THE SCRIPT
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
