// Simulation of a digital hologram recording and reconstruction
// In the first step, a hologram of a point cloud is recorded.
// In the second step, a hologram is illuminated and a camera
// equipped with a lens captures an image. A properly focused
// lens creates sharp image of the original point cloud.
// The point cloud is located around z = 0, the hologram is located in
// z = hologramZ. The front lens of the camera is near the hologram, i.e., is is
// located in z = hologramZ + "small shift". Intrinsic parameters of the camera
// (especially the distance of the lens and the imaging sensor) are calculated
// automatically in such a way that the camera is focused to a specified
// point in the scene.
//
// The geometrical image of the point cloud and two photographs of the virtual 
// image are displayed in Figure 1. Two photographs are provided as it is then 
// possible to, e.g., compare different views of the scene.
// The hologram is displayed in Figure 2.
// (Explore the demo DEMO_hologram_real_image to see how to reconstruct
// a real image.)
//
// This demo is mostly the same as the demo DEMO_hologram_real_image.
// Parameters affecting the hologram recording setup, hologram encoding
// and binarization are explained there.
//
// A slight change is made here in the reconstruction process: to see a perfect
// virtual image, it is necessary to use a replica of the reference wave
// in the reconstruction step. (Note that in DEMO_hologram_real_image,
// it is necessary to use a reconstruction wave that forms a real image
// on the screen.)
//
// Try changing the hologram recording setup, the hologram encoding parameters 
// and the camera parameters.
// Observe change of perspective in a photograph when the camera moves
// and the effect of lens focusing to different depths.
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

// Scilab compatibility
imagUnit = sqrt(-1);
piNumber = %pi

// Wavelength, a green DPSS laser
lambda = 532e-9;

// Select hologram recording (and reconstruction) geometry.
//
// hologramType = 'onAxis';
hologramType = 'offAxis';
// hologramType = 'lenslessFourier';

// Set hologram encoding method
//
hologramMethod = 'classical';
// hologramMethod = 'bipolar';
// hologramMethod = 'shiftedBipolar';
// hologramMethod = 'kinoformArgument';
// hologramMethod = 'complex';

// Binarize the hologram?
// Note: binarization is performed before bleaching.
// Binarization of a complex hologram is not supported.
binarize = %F;

// Select amplitude or phase (bleached) hologram
// (Note that 'kinoformArgument' and 'complex' types
// do not take this into account, see code below.)
bleach = %F;
bleachMaxPhase = 2*piNumber; // max. phase change for phase only holograms
  // Note that for binarized bleached hologram, bleachMaxPhase = 2*piNumber
  // results to no phase change at all

// Set reference:object wave intensity ratio
// ROratio = 5 means that intensity of the reference wave
// is five times as high as the average intensity of the object wave.
RORatio = 5;

// Define a point cloud located near z = 0
// As seen from the camera, it looks like a pattern
//     *  *    (closer to the camera)
//  *  *  *    (at z = 0)
//  *  *  *    (farther from the camera)
sceneDepth = 40e-3;
sceneWidth = 2e-3;
sceneHeight = 2e-3;
pointLocation = [ 0,  0,  0
                 -1,  0,  0;
                  1,  0,  0;
                 -1, -1, -1;
                  0, -1, -1;
                  1, -1, -1;
                  0,  1,  1;
                  1,  1,  1; 
                  ]; 
pointLocation(:, 1) = pointLocation(:, 1) * sceneWidth / 2;
pointLocation(:, 2) = pointLocation(:, 2) * sceneHeight / 2;
pointLocation(:, 3) = pointLocation(:, 3) * sceneDepth / 2;
pointAmplitudes = ones(1, size(pointLocation, 1));

// Set the hologram image dimensions
hologramWidth = 10e-3;
hologramHeight = 10e-3;
hologramDelta = 10e-6;

// Select image-hologram distance.
// High resolution images (small pixel size) can be closer
// to the hologram.
hologramZ = 500e-3;

// Set parameters of the camera A
// Its lens axis is perpendicular to the hologram.
lensFocusedToA = [0, 0, 0];              // The lens creates a sharp image of this point
lensFocalLengthA = 100e-3;               // Focal length of the lens
lensDiameterA = 5e-3;                    // Entrance pupil diameter
lensCenterA = [0, 0, hologramZ + 30e-3]; // Center of the lens
    // Set "exposure control" for DISPLAY purposes. It basically sets white level.
    // Setting exposureLimit to 0 means "auto exposure", i.e. maximum value
    // is displayed as white.
    // Setting it to non zero positive value can lead to overexposure or 
    // underexposure. On the other hand, it allows to compare reconstructions from
    // various holograms easily.
exposureLimitA = 6;                      

// Set parameters of the camera B
// Its lens axis is slightly slanted, i.e. the scene is captured a bit from
// the side. The lens is also focused to a different distance.
lensFocusedToB = [0, 0, -1] * sceneDepth / 2;
lensFocalLengthB = lensFocalLengthA;
lensDiameterB = lensDiameterA;
lensCenterB = lensCenterA + [5e-3, 0, 0];
exposureLimitB = exposureLimitA;

// Set the sensor size of both cameras A and B
sensorWidth = 1e-3;
sensorHeight = 1e-3;

// Location of the "geometric camera" that is used to make a geometrical
// image of the scene.
geometricCamera = lensCenterB;

//
// END OF ADJUSTABLE PARAMETER SETTINGS
//

// Hologram parameters
hologramSamplesYX = calculateSamples([hologramHeight, hologramWidth], hologramDelta);
hologramCenter = [0, 0, hologramZ];

// Additional camera and lens parameters
lensDelta = hologramDelta;
lensSamplesYX = calculateSamples([1, 1] * max(lensDiameterA, lensDiameterB), lensDelta);
sensorSamplesYX = calculateSamples([sensorHeight, sensorWidth], lensDelta);

// Propagate the point cloud to the hologram plane
[hologramX, hologramY] = ...
  getXYVectorFromCenter(hologramSamplesYX, hologramDelta, hologramCenter);
[xx, yy] = meshgrid(hologramX, hologramY);
objectWave = pointCloudPropagate(pointLocation, pointAmplitudes, lambda, xx, yy, hologramZ);
objectWaveIntensity = getWaveIntensity(objectWave); 

// Prepare the reference and the reconstruction waves 

if (isequalString(hologramType, 'lenslessFourier'))
  // Lensless Fourier hologram
  referenceSource = [0, sceneHeight*1.5, 0];
  referenceWave = pointCloudPropagateNoAliasing(referenceSource, 1, lambda, xx, yy, hologramZ);
  referenceWaveIntensity = getWaveIntensity(referenceWave);
  reconstructionWave = referenceWave / sqrt(referenceWaveIntensity);
  referenceWave = sqrt(RORatio) * sqrt(objectWaveIntensity)  * ...
                  referenceWave / sqrt(referenceWaveIntensity);
else  
  // On-axis or off-axis hologram (plane reference wave)
  // Alpha and beta are angles relative to X and Y axes minus pi/2 rad,
  // i.e. alpha = beta = 0 results in direction [0, 0, 1]
  referenceAlpha = 0;
  if (isequalString(hologramType, 'onAxis'))
    referenceBeta = 0;
  elseif (isequalString(hologramType, 'offAxis'))  
    referenceBeta = getMaxDiffAngle(lambda, 2.0*hologramDelta);
  else
    error('Wrong hologram type: %s\n', hologramType);
  end  

  referenceDirection = ...
    getVectorFromAngles(referenceAlpha, referenceBeta);

  // Reconstruction wave angles are the same as the
  // reference wave in order to watch the perfect virtual image.  
  reconstructionAlpha = referenceAlpha;
  reconstructionBeta = referenceBeta;
  reconstructionDirection = ...
    getVectorFromAngles(reconstructionAlpha, reconstructionBeta);
  
  // Prepare the reference and the reconstruction waves 
  referenceWave = sqrt(RORatio) * sqrt(objectWaveIntensity) * ...
    planeWave(referenceDirection, lambda, xx, yy, hologramZ);
  reconstructionWave = ...
    planeWave(reconstructionDirection, lambda, xx, yy, hologramZ);
end

//  
// Make the hologram
//
hologram = calculateHologram(objectWave, referenceWave, hologramMethod, %T);

// Binarize
if (binarize && ~isequalString(hologramMethod, 'complex'))
  // Convert the hologram to zeros and ones
  hologram = binarizeHologram(hologram);
  
  if (isequalString(hologramMethod, 'bipolar'))
    // For bipolar intensity, change it to +0.5 and -0.5
    hologram = hologram - 0.5;
  end
end

// Bleach the hologram, if desired
if (isequalString(hologramMethod, 'kinoformArgument'))
  bleach = %T;
end

if (bleach && ~isequalString(hologramMethod, 'complex'))
  hologram = bleachHologram(hologram, bleachMaxPhase);
end

// Propagate illuminated hologram to the lens plane
propagationMethod = '2fft';
kernelType = 'AngularSpectrumExact';
filteringMethod = 'localExact';

[lensOptfield, lensX, lensY] = propagate(...
  hologram .* reconstructionWave, ...
  hologramDelta, hologramCenter, ...
  lensSamplesYX, lensDelta, lensCenterA, ...
  lambda, propagationMethod, kernelType, filteringMethod);

// Take the photograph A  
[sensorOptfieldA, sensorXA, sensorYA] = takePhotograph(...
  lambda, lensOptfield, lensDelta, lensCenterA, ...
  lensDiameterA, lensFocalLengthA, lensFocusedToA, ...
  sensorSamplesYX);

// Prepare for taking photograph B
// If the lens position of B is different from A, calculate new
// light propagation.
if (~isequal(lensCenterA, lensCenterB))
  [lensOptfield, lensX, lensY] = propagate(...
    hologram .* reconstructionWave, ...
    hologramDelta, hologramCenter, ...
    lensSamplesYX, lensDelta, lensCenterB, ...
    lambda, propagationMethod, kernelType, filteringMethod);
end

// Take the photograph B
[sensorOptfieldB, sensorXB, sensorYB] = takePhotograph(...
  lambda, lensOptfield, lensDelta, lensCenterB, ...
  lensDiameterB, lensFocalLengthB, lensFocusedToB, ...
  sensorSamplesYX);
  
//
// Just for testing purposes, make a perspective image of the point cloud
// as seen by camera B.
//
// The geometrical image aspect ratio should be the same as the scene aspect
// ratio.
pointCloudWidth = max(pointLocation(:, 1)) - min(pointLocation(:, 1));
pointCloudHeight = max(pointLocation(:, 2)) - min(pointLocation(:, 2));
imageWidth = 1.5 * pointCloudWidth;
imageHeight = 1.5 * pointCloudHeight;

// Resolve the singular cases
if (imageWidth == 0 && imageHeight == 0)
  imageWidth = 1;
  imageHeight = 1;
elseif (imageWidth == 0)
  imageWidth = imageHeight;
elseif (imageHeight == 0)
  imageHeight = imageWidth;
end

// Determine width and height of the image in pixels.
imagePixelSizeMax = 65;    // longer side of the image

// Image relative dimensions (height, width)
if (imageWidth > imageHeight)
  imageRelativeHW = [imageHeight / imageWidth, 1];
else
  imageRelativeHW = [1, imageWidth / imageHeight];
end

// Final image parameters
imageSamplesYX = floor(imagePixelSizeMax * imageRelativeHW + 0.5);
imageDeltaYX = calculateDelta(imageSamplesYX, [imageHeight, imageWidth]);

// Pixel "coordinates" for display purposes
imageX = (0:imageSamplesYX(2) - 1) - imageSamplesYX(2) / 2;
imageY = (0:imageSamplesYX(1) - 1) - imageSamplesYX(1) / 2;

// Make the geometrical image
image = pointCloudImage(pointLocation, pointAmplitudes, 1, ...
  imageSamplesYX, imageDeltaYX, [0, 0, 0], geometricCamera);

//
// Display the result
//
scf(1); gcf().background = -2;
clf();

subplot(3, 1, 1);
limits = displayImage(imageX, imageY, image);
xlabel('x [pixel]');
ylabel('y [pixel]');
title(sprintf('Geometrical image taken from [%g, %g, %g] mm', ...
  geometricCamera(1)*1e3, geometricCamera(2)*1e3, geometricCamera(3)*1e3));
drawColorbar(limits);
gca().isoview = 'on'; gca().tight_limits = 'on';

subplot(3, 1, 2);
sensorPhotoA = abs(sensorOptfieldA);
if (exposureLimitA == 0)
  normalizeType = 'positive';
else
  normalizeType = [0, exposureLimitA];
end
limits = displayImage(sensorXA*1e3, sensorYA*1e3, sensorPhotoA, normalizeType);
xlabel('x [mm]');
ylabel('y [mm]');
title(sprintf('Photograph taken from [%g, %g, %g] mm, lens %.0f mm / %.1f, focused to z = %.0f mm', ...
  lensCenterA(1)*1e3, lensCenterA(2)*1e3, lensCenterA(3)*1e3, ...
  lensFocalLengthA*1e3, lensFocalLengthA / lensDiameterA, ...
  lensFocusedToA(3)*1e3));
drawColorbar(limits);
gca().isoview = 'on'; gca().tight_limits = 'on';

subplot(3, 1, 3);
sensorPhotoB = abs(sensorOptfieldB);
if (exposureLimitB == 0)
  normalizeType = 'positive';
else
  normalizeType = [0, exposureLimitB];
end
limits = displayImage(sensorXB*1e3, sensorYB*1e3, sensorPhotoB, normalizeType);
xlabel('x [mm]');
ylabel('y [mm]');
title(sprintf('Photograph taken from [%g, %g, %g] mm, lens %.0f mm / %.1f, focused to z = %.0f mm', ...
  lensCenterB(1)*1e3, lensCenterB(2)*1e3, lensCenterB(3)*1e3, ...
  lensFocalLengthB*1e3, lensFocalLengthB / lensDiameterB, ...
  lensFocusedToB(3)*1e3));
drawColorbar(limits);
gca().isoview = 'on'; gca().tight_limits = 'on';

//
// Display the hologram
//
scf(2); gcf().background = -2;
clf();

if (bleach)
  bleachString = ' bleached';
else
  bleachString = '';
end

limits = displayImage(hologramX*1e3, hologramY*1e3, hologram);
xlabel('x [mm]');
ylabel('y [mm]');
title(sprintf('Hologram (%s, %s%s) located at [%g, %g, %g] mm', ...
  hologramType, hologramMethod, bleachString, ...
  hologramCenter(1)*1e3, hologramCenter(2)*1e3, hologramCenter(3)*1e3));
drawColorbar(limits);
gca().isoview = 'on'; gca().tight_limits = 'on';


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// END OF THE SCRIPT
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
