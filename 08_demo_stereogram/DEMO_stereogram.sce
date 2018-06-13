// Demonstration of various attempts to make a holographic stereogram.
// First, a holographic stereogram is calculated and displayed in Figure 1.
// Second, its reconstruction is calculated and displayed in Figure 2.
//
//
// The basic idea of holographic stereogram is straightforward. Let us explain 
// it for a simple case, where the object is just a single point.
//
// When making a classical hologram, an object illuminates the hologram plane. 
// If the object is just a single point, the object wave looks like a set
// of concentric circles (more precisely, phase of the object wave).
//
// When making a holographic stereogram, the hologram plane is decomposed to
// many small rectangular areas called subholograms. Strictly speaking,
// the object wave in each subhologram is composed of short segments of 
// concentric circles. If we approximate these circular segments with straight
// lines, the error is small if subholograms are small as well.
//
// The lines would also emerge if the object (a single point) is located far from
// the hologram. In this case, a spherical wave can be locally approximated by
// a plane wave very well. Direction of the plane wave must be the same as the
// direction of the object point from the center of the subhologram.
//
// Thus, we can place an ordinary "perspective camera" to the center of the
// subhologram and "capture an image" by geometrical means. Position of the
// object point in "the perspective image" tells direction of the point.
//
// The main trick follows. The Fourier transform of a plane wave is the Dirac
// delta, i.e. a single point in the (fx,fy) plane. Thus, the inverse Fourier
// transform of the perspective image taken from the subhologram center
// is equal to the phasor of the plane wave that we need as an approximate
// object wave inside the subhologram.
//
// In this demo, you can try to change stereogram calculation methods or 
// other parameters.
//
// First, you can select between three modes:
//
// 1. Calculation of the exact hologram (no subhologram tricks). This mode
//    shows the "ground truth" and allows to judge stereogram calculation 
//    quality.
//
// 2. Subdividing the hologram to subholograms and approximating the spherical
//    waves with plane waves. In this case, you can select if the object point
//    location is quantized (which is inevitable when using FFT) or not.
//    This mode is educational only. It allows to observe how quantization affects
//    the stereogram quality. It also allows better insight into the process of
//    approximation by plane waves.
//
// 3. Subdividing the hologram to subholograms and approximating the spherical
//    waves with plane waves. FFT is used for the conversion between the 
//    "perspective image" taken from the subhologram center and the object wave 
//    phasor.
//
// Note that the "mode" is selected using variables calcType, useFFT and 
// quantizePointLocation. 
//
// Mode 1 is selected by
//   calcType = 'exact';
//   useFFT = %F;
//   quantizePointLocation = %F;
//
// Mode 2 is selected by
//   calcType = 'plane...';   %// (e.g. plane, planeExact, planePAS, etc.)
//   useFFT = %F;
//
// Mode 3 is selected by
//   useFFT = %T;
//
// Also note that not all combinations are possible, for example it is
// NOT possible to set 
//   calcType = 'exact'; useFFT = %T;
// (as exact calculation cannot be done with FFT).
//
//
// Second, you can select between various methods how to approximate a spherical 
// wave with a plane wave:
//
// 1. calcType = 'exact';
//    This type does not approximate anything at all, it uses spherical waves.
//
// 2. calcType = 'planeExact';
//    calcType = 'plane';
//    Straight replacement with a plane wave that has the correct direction.
//    The difference between the two options is subtle. The type 'planeExact'
//    uses the same coordinates to calculate the wave as calcType = 'exact'
//    (that uses spherical waves, i.e. does not approximate anything). This
//    type is the easiest to understand.
//    The type 'plane' does basically the same but uses the same coordinate 
//    system that is used in FFT based calculation. Thus, the type 'plane'
//    can be used with or without FFT.
//    Note that both types do not adjust phase of the plane wave.
//
// 3. calcType = 'planePAS';
//    This type implements 'phase added stereogram' introduced in [Yamaguchi93].
//    It carefully adjusts phase of the plane wave. Long story short: phase
//    of the plane wave in the subhologram center should be the same as the
//    phase of the exact spherical wave.
//    Try this type with quantizePointLocation = %F; useFFT = %F;
//    Compare it to quantizePointLocation = %T; useFFT = %F;
//
// 4. calcType = 'planeCPAS';
//    This type implements 'compensated phase added stereogram' introduced in 
//    [Kang07]. It adjusts the phase of the plane wave in a similar way as the
//    phase added stereogram, but takes into account quantization of point 
//    location that is inevitable when using FFT.
//
// 5. calcType = 'planeA';
//    calcType = 'planeAPAS';
//    calcType = 'planeACPAS';
//    These types implement 'accurate' methods introduced in [Kang08] and 
//    [Kang09]. They address the FFT quantization problem in a better way than
//    the CPAS method. Long story short: If the "perspective image" is created
//    with higher resolution, point direction is more accurate. Taking IFFT
//    of such image results in phasor representation with larger spatial extent
//    than necessary (remember: better resolution in the frequency domain results
//    in larger spatial domain). We can crop the unnecessary part to get the
//    subhologram we need.
//    The type 'planeA' shows this enhancement alone. The type 'planePAS'
//    combines 'accurate' and PAS methods. The type 'planeACPAS' combines
//    'accurate' and CPAS methods.
//    Observe that in 'accurate' types, direction of the subhologram fringes 
//    approximates average direction of the exact subhologram better than 
//    'non-exact' types.
//    Note: In 'accurate' types, it is necessary to make finer perspective images
//    than in 'non-accurate' types. What is 'finer' is set by internal
//    variable accurateFactor in pointCloudIBPropagate().
//
//
// Finally, it is possible to switch between several scenes (a single point, 
// a few points, 3-D wireframe objects), several hologram recording methods
// and several hologram reconstruction methods.
//
// Please note that the image rendering in pointCloudImage() is currently
// very slow, which results in long stereogram calculation times. Anyway,
// this has nothing to do with wave related calculations.
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
//
// ---------------------------------------------
//
// Note that while a photographic film captures light intensity,
// the images that store intensity are actually not suitable for direct
// viewing. Recall that common digital images are supposed to be gamma
// corrected, gamma = 2.2. Thus, the image that stores amplitude can be 
// thought as a reasonable approximation of a gamma corrected intensity 
// image, as amplitude = intensity ^ (1/2).
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

// Set experiment type
// For 'singlePoint' it is instructive to set small hologram size to watch
// artifacts of various calculation methods.
// Adjust parameters hologramWidth and hologramHeight if necessary.
//
experiment = 'singlePoint';
// experiment = 'eightPoints';
// experiment = 'complexPointObject';

// Select stereogram calculation type.
// General types:
//
// calcType = 'plane';
// calcType = 'planePAS';
// calcType = 'planeCPAS';
// calcType = 'planeA';
// calcType = 'planeAPAS';
calcType = 'planeACPAS';

// These calculation types cannot be used with FFT
//
// calcType = 'exact';
// calcType = 'planeExact';


// Select algorithm of the stereogram calculation. 
//
// Non-FFT (direct) methods are generally slow for point clouds larger than a 
// few points; they are implemented for educational purpose only.
// They allow detailed understanding what actually happens during stereogram
// calculation. Moreover, as FFT based methods require point cloud quantization
// to a pixel grid, it can be difficult to decide if a calculation error 
// is caused by the quantization or if it is caused by different reason.
// In non-FFT methods, quantization can be turned on or off, which allows
// to study quantization effect in depth.
//
// Note that if quantization is turned on, the result should be the same regardless
// of whether FFT is used or not (up to a constant factor). 
// Also note if FFT is used, quantizePointLocation parameter is ignored.
//
useFFT = %T;
quantizePointLocation = %F;


// Set hologram encoding method
//
// hologramMethod = 'classical';
// hologramMethod = 'bipolar';
// hologramMethod = 'shiftedBipolar';
hologramMethod = 'complex';

// Select hologram recording setup. In 'offAxis' case,
// the reference wave angle is set automatically.
//
hologramType = 'onAxis';
// hologramType = 'offAxis';

// Select hologram reconstruction method
//
hologramReconstruction = 'realImage';
// hologramReconstruction = 'takePhotograph';

  
//
// DETAILS OF THE ABOVE SETTINGS
//

// Set the hologram dimensions and location (hologram center is on the z axis)
hologramZ = 250e-3;
hologramDelta = 10e-6;
hologramWidth = 10e-3;
hologramHeight = 10e-3;
// Use following size for closer examination of the stereogram behavior
// Consider changing 
hologramWidth = 255 * hologramDelta;
hologramHeight = hologramWidth;

// Set subhologram size
drawSubHologramBorders = %T; // just for display purposes
subHologramSamplesX = 32;
subHologramSamplesY = 32;

// Define parameters for both hologram reconstruction methods:
// Location of a screen for a real image created by backpropagation
realImageZ = 0;

// Camera that takes a photograph of the virtual image
lensFocusedTo = [0, 0, 0];
lensFocalLength = 100e-3;
lensDiameter = 5e-3;
lensCenter = [0, 0, hologramZ];
exposureLimit = 0; // Just for display purposes
  // exposureLimit sets the white level.
  // It is useful to set it somehow in order to compare various methods
  // in terms of diffraction efficiency. Setting it 0 sets white level
  // to the maximum level incident on the camera sensor (i.e. auto exposure).
sensorWidth = 3e-3;
sensorHeight = 3e-3;

// Each experiment sets its reference wave intensity. It is necessary to know 
// it in advance, this demonstration script does not implement any way to guess 
// it. Note that some hologram recording methods (e.g. kinoform) do not
// require it, but generally it is necessary to set it somehow.
// The script reports a suitable value after the calculation,
// so it is possible to run the script twice.
//
// Note that the object wave intensity depends on the algorithm, i.e.
// useFFT and calcType.

switch (experiment)
  case 'singlePoint'
    // Useful for detailed examination of different stereogram calculation 
    // methods
    pointLocations = [ -0,  0,  0 ];
    pointAmplitudes = [1];
    referenceWaveIntensity = 4.5e-9;
  case 'eightPoints'
    // Define a point cloud located near z = 0
    // As seen from the camera, it looks like a pattern
    //     *  *    (closer to the camera)
    //  *  *  *    (at z = 0)
    //  *  *  *    (farther from the camera)
    sceneDepth = 40e-3;
    sceneWidth = 2e-3;
    sceneHeight = 2e-3;
    pointLocations = [ 0,  0,  0;
                      -1,  0,  0;
                       1,  0,  0;
                      -1, -1, -1;
                       0, -1, -1;
                       1, -1, -1;
                       0,  1,  1;
                       1,  1,  1]; 
    pointLocations(:, 1) = pointLocations(:, 1) * sceneWidth / 2;
    pointLocations(:, 2) = pointLocations(:, 2) * sceneHeight / 2;
    pointLocations(:, 3) = pointLocations(:, 3) * sceneDepth / 2;
    pointAmplitudes = ones(1, size(pointLocations, 1));
    referenceWaveIntensity = 3.5e-8;
  case 'complexPointObject'
    // Scene composed of many points simulating three wireframe objects  
    object1Z = 0;
    object2Z = object1Z - 10e-3;
    object3Z = object1Z + 10e-3;

    // Wireframe objects will be composed of points separated by DeltaLine
    DeltaLine = 30e-6;

    object1 = generateTetrahedron(0.5e-3, DeltaLine);
    object1 = pointsRotateXYZ(object1, -20*piNumber/180, 5*piNumber/180, 0);
    object1 = pointsTranslateXYZ(object1, 0, 0, object1Z);

    object2 = generateCube(0.5e-3, DeltaLine);
    object2 = pointsRotateXYZ(object2, -40*piNumber/180, 5*piNumber/180, 0);
    object2 = pointsTranslateXYZ(object2, -0.8e-3, -0.8e-3, object2Z);

    object3 = generateOctahedron(0.5e-3, DeltaLine);
    object3 = pointsRotateXYZ(object3, -10*piNumber/180, 15*piNumber/180, 0);
    object3 = pointsTranslateXYZ(object3, 0.8e-3, 0.8e-3, object3Z);

    pointLocations = [object1; object2; object3];

    // Points have amplitude 1, random phase
    rand ('seed', 1);
    pointAmplitudes = exp(imagUnit * 2 * piNumber * rand(size(pointLocations, 1), 1));
    referenceWaveIntensity = 1.0e-6;
  otherwise
    error(sprintf('DEMO_stereogram: unknown experiment type ""%s""', experiment));
end    
  

//
// END OF ADJUSTABLE PARAMETERS
//

// Set the hologram geometry
hologramDeltaYX = getDeltaYX(hologramDelta);
hologramDeltaY = hologramDeltaYX(1);
hologramDeltaX = hologramDeltaYX(2);
hologramSamplesYX = calculateSamples([hologramHeight, hologramWidth], hologramDelta);
hologramSamplesY = hologramSamplesYX(1);
hologramSamplesX = hologramSamplesYX(2);
hologramCenter = [0, 0, hologramZ];
hologramMin = centerToMin(hologramCenter, hologramSamplesYX, hologramDeltaYX);
[hologramX, hologramY] = getXYVectorFromCenter(hologramSamplesYX, hologramDeltaYX, hologramCenter);

subHologramSamplesYX = [subHologramSamplesY, subHologramSamplesX];
subHologramsX = ceil(hologramSamplesX / subHologramSamplesX);
subHologramsY = ceil(hologramSamplesY / subHologramSamplesY);

// Virtual camera parameters
lensDelta = hologramDelta;
lensSamplesYX = calculateSamples([1, 1] * lensDiameter, lensDelta);
sensorSamplesYX = calculateSamples([sensorHeight, sensorWidth], lensDelta);


// Set reference wave parameters
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


//
// Calculate subholograms and make a composite hologram
//
hologram = zeros(hologramSamplesY, hologramSamplesX);
objectWaveIntensity = 0; // initialization, it will be updated in the loop below
subhologramsCount = subHologramsY * subHologramsX;

// Loop over all subholograms
for subY = 0:subHologramsY-1
  if (isequalString(experiment, 'complexPointObject'))
    // Calculation of this scene is slow, report progress.
    mprintf('Calculating subhologram row %d/%d\n', subY+1, subHologramsY);
    
  end
  for subX = 0:subHologramsX-1
    // Actual location of the subhologram corner
    subHologramMin = hologramMin + ...
      [subX * subHologramSamplesX * hologramDeltaX, ...
       subY * subHologramSamplesY * hologramDeltaY, ...
       0];
       
    // Object wave in the subhologram
    subObjectWave = pointCloudIBPropagate(...
      pointLocations, pointAmplitudes, ...
      lambda, ...
      subHologramMin, hologramDeltaYX, subHologramSamplesYX, ...
      calcType, useFFT, quantizePointLocation);
      
    // Update the mean object wave intensity
    objectWaveIntensity = objectWaveIntensity + ...
                          getWaveIntensity(subObjectWave) / subhologramsCount; 
    
    // Calculate the reference wave
    [x, y] = getXYVectorFromMin(subHologramSamplesYX, ...
                                hologramDeltaYX, subHologramMin);
    [xx, yy] = meshgrid(x, y);
    subReferenceWave = sqrt(referenceWaveIntensity) * ...
      planeWave(referenceDirection, lambda, xx, yy, hologramZ);

    // Make the subhologram
    subHologram = calculateHologram(subObjectWave, subReferenceWave, ...
                                    hologramMethod, %F);

    // Copy the subhologram samples to proper position in the hologram matrix
    minIndexX = subX*subHologramSamplesX+1; 
    maxIndexX = min(hologramSamplesX, (subX+1)*subHologramSamplesX);
    indexX = minIndexX:maxIndexX;
    minIndexY = subY*subHologramSamplesY+1;
    maxIndexY = min(hologramSamplesY, (subY+1)*subHologramSamplesY);
    indexY = minIndexY:maxIndexY;
    hologram(indexY, indexX) = subHologram(1:size(indexY, 2), 1:size(indexX, 2));
  end
end

// Report mean object wave intensity and recommend its adjustment if necessary
//
RORatio = 3; // generally useful ratio of the reference to the object wave intensity
mprintf('Mean object wave intensity is %g.\n', objectWaveIntensity);
mprintf('Actual reference wave intensity is %g.\n', referenceWaveIntensity);
mprintf(' (reference wave intensity / object wave intensity = %.1f, should be around %.0f)\n', ...
  referenceWaveIntensity / objectWaveIntensity, RORatio);
if (abs(referenceWaveIntensity / objectWaveIntensity - RORatio) > 0.25)
  mprintf('Consider setting the reference wave intensity to e.g. %g.\n', ...
    RORatio*objectWaveIntensity);
end    

// Normalize the whole hologram
// This is useful for comparison between various hologram calculation types.
hologram = hologram / max(max(abs(hologram)));

//
// RECONSTRUCT THE HOLOGRAM
//

// Make the reconstruction wave as a copy of the reference wave
[xx, yy] = meshgrid(hologramX, hologramY);
reconstructionWave = planeWave(referenceDirection, lambda, xx, yy, hologramZ);
    
switch (hologramReconstruction)
  case 'realImage'
    // Backpropagation to make the real image
    [reconstruction, recX, recY] = ...
      propagate(hologram .* reconstructionWave, hologramDeltaYX, hologramCenter, ...
            hologramSamplesYX, hologramDeltaYX, [0, 0, realImageZ], ...
            lambda, '3fft', 'RayleighSommerfeldExact', 'localExact');

  case 'takePhotograph'
    // Propagate illuminated hologram to the lens plane
    [lensOptfield, lensX, lensY] = propagate(...
      hologram .* reconstructionWave, ...
      hologramDelta, hologramCenter, ...
      lensSamplesYX, lensDelta, lensCenter, ...
      lambda, '2fft', 'AngularSpectrumExact', 'localExact');
    // Take a photograph
    [reconstruction, recX, recY] = takePhotograph(...
      lambda, lensOptfield, lensDelta, lensCenter, ...
      lensDiameter, lensFocalLength, lensFocusedTo, ...
      sensorSamplesYX);
   otherwise
     error(sprintf('Unknown hologram reconstruction method ""%s""', ...
                   hologramReconstruction));
end

//
// DISPLAY THE RESULTS
//

// Prepare the description of the results (e.g. for the output file name)
if (useFFT)
  descFFT = 'fft';
else
  descFFT = 'direct';
end

if (quantizePointLocation)
  descQuant = 'sceneQuantizedPointLocation';
else
  descQuant = 'sceneExact';
end

description = sprintf('%s-%s-%s', descFFT, calcType, descQuant);

//
// Display the holographic stereogram
//
scf(1); gcf().background = -2;
clf();

// Prepare the figure title
switch (hologramMethod)
  case 'classical'
    displayHoloDesc = '';
  case 'bipolar';
    displayHoloDesc = ' (signed)';
  case 'shiftedBipolar';
    displayHoloDesc = '';
  case 'complex';
    displayHoloDesc = ' (complex)';
  otherwise
    warning(sprintf('Unimplemented display method for hologramMethod %s', ...
      hologramMethod));
    displayHoloDesc = '';
end    
  
limits = displayImage(hologramX * 1e3, hologramY * 1e3, hologram, ...
  'auto', 1, sprintf('hologram_%s.tif', description));
xlabel('x [mm]');
ylabel('y [mm]');
drawColorbar(limits);
gca().isoview = 'on'; gca().tight_limits = 'on';
drawTitle(sprintf('Hologram (%s) %s', hologramMethod, description));

// Draw subhologram borders
if (drawSubHologramBorders)
  set(gca(),'auto_clear','off');;
  for (idx = [1:subHologramSamplesX:hologramSamplesX, hologramSamplesX])
    drawLine([hologramX(idx), hologramX(idx)]*1e3, ...
         [hologramY(1), hologramY(hologramSamplesY)]*1e3, ...
         'red');
  end  
  for (idx = [1:subHologramSamplesY:hologramSamplesY, hologramSamplesY])
    drawLine([hologramX(1), hologramX(hologramSamplesX)]*1e3, ...
    [hologramY(idx), hologramY(idx)]*1e3, ...
    'red');
  end  
  set(gca(),'auto_clear','on');;
end

//
// Display the reconstruction
//
scf(2); gcf().background = -2;
clf();
if (exposureLimit == 0)
  normalizeType = 'positive';
else
  normalizeType = [0, exposureLimit];
end
limits = displayImage(recX * 1e3, recY * 1e3, abs(reconstruction), normalizeType, ...
  1, sprintf('reconstruction_%s.tif', description));
xlabel('x [mm]');
ylabel('y [mm]');
drawTitle(sprintf('Reconstruction (%s) of %s', hologramReconstruction, description));
drawColorbar(limits);
gca().isoview = 'on'; gca().tight_limits = 'on';

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// END OF THE SCRIPT
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
