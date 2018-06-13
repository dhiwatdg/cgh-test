// Really unoptimized code for a calculation of a hologram of a point cloud
// and its reconstruction.
//
// Please use the optimized versions for experiments
// (DEMO_optimized_hologram or DEMO_virtual_image_reconstruction)
// as they use matrix operations and are substantially faster than this demo.
// This demo is as simple as possible. On the other hand, its simplicity
// makes it suitable for a rewrite to another programming language such as C.
// 
//
// The demo calculates
//  1. the object wave,
//  2. the reference wave,
//  3. the hologram,
//  4. the kernel used for hologram reconstruction (light propagation),
//  5. the reconstructed real image.
// In each step, an image is shown and several images are saved.
// It is wiser to watch the images in an external image viewer
// that allows 1:1 pixel mapping between the image and the display.
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
// A few functions that accompany this demo are either for Octave/MATLAB/Scilab
// compatibility, or to provide easy to use way to save an image.
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
// 0. Initialization
// ALL DIMENSIONS ARE IN METRES
//

//
// GENERAL CALCULATION PARAMETERS
//

// Scilab compatibility
getd('../helper_functions');
imagUnit = sqrt(-1);
piNumber = %pi

//  Wavelength and the wave number
lambda = 532e-9;     // green DPSS laser light
k = 2*piNumber/lambda;

// Color map for the images displayed
gcf().color_map = graycolormap(256);

//
// HOLOGRAM PARAMETERS
//

//  Dimensions of the hologram
hologramWidth  = 2e-3;
hologramHeight = 2e-3;

// Hologram is located in z = hologramZ 
hologramZ = 0;

// Sampling distance in both xy axes
samplingDistance = 10e-6;  // common spatial light modulators

// Number of rows (y) and columns (x) of the hologram
hologramSamplesX = ceil(hologramWidth / samplingDistance);
hologramSamplesY = ceil(hologramHeight / samplingDistance);

// Location of the "lower left" corner of the hologram
// put center of the hologram to x=0, y=0
hologramCornerX = - (hologramSamplesX - 1) * samplingDistance / 2;
hologramCornerY = - (hologramSamplesY - 1) * samplingDistance / 2;

//
//  REFERENCE WAVE PARAMETERS
// 
//  Angles of direction of the reference wave with respect to the 
//  axes x and y; the angle gamma between the reference 
//  light direction and the axis z can be calculated as
//  gamma = sqrt(1 - alpha^2 - beta^2),
//  but we will not need it.
alpha = 90 * piNumber/180;
beta = 90.5 * piNumber/180;

//
// SCENE PARAMETERS
//

// Definition of the scene
// The real image will be reconstructed in the plane
// z = hologramZ + abs(pointsZ)
pointsZ = -200e-3;

// Scene depth
sceneDepth = 20e-3;

//  xyz coordinates of the point light points forming the object
points = [0, 0, pointsZ;  
  -hologramWidth / 4, -hologramHeight / 4, pointsZ;  
   hologramWidth / 4,  hologramHeight / 4, pointsZ - sceneDepth];


// ---------------------------------------------

//
// 1. The object wave calculation
//

mprintf('\nThe object wave calculation...\n');


objectWave = zeros(hologramSamplesY, hologramSamplesX);
nPoints = size(points, 1);
for s = 1:nPoints
  mprintf('Point light source %d of %d\n', s, size(points, 1));
  
  for column = 1:hologramSamplesX
    for row = 1:hologramSamplesY
      x = (column-1) * samplingDistance + hologramCornerX;
      y = (row-1)    * samplingDistance + hologramCornerY;
      r = sqrt((x         - points(s, 1))^2 + ...
               (y         - points(s, 2))^2 + ...
               (hologramZ - points(s, 3))^2);
      objectWave(row,column) = objectWave(row,column) + exp(imagUnit*k*r) / r;
    end
  end
end

//
// Display & save
//
saveAmplitude(objectWave, '01_objectWave_amplitude.png');
saveIntensity(objectWave, '01_objectWave_intensity.png');
savePhase(objectWave, '01_objectWave_phase.png');
saveComplexPart(real(objectWave), '01_objectWave_real.png');
saveComplexPart(imag(objectWave), '01_objectWave_imag.png');

xAxis = (0:hologramSamplesX - 1)*samplingDistance + hologramCornerX;
yAxis = (0:hologramSamplesY - 1)*samplingDistance + hologramCornerY;
showImage(xAxis, yAxis, real(objectWave), 'Object wave (real part)');
waitForKey('Press ENTER to continue.');

// ---------------------------------------------

//
// 2. The reference wave calculation
//

mprintf('\nThe reference wave calculation...\n');

// Direction vector of the reference wave
nX = cos(alpha); nY = cos(beta);
nZ = sqrt(1 - nX^2 - nY^2);

// Amplitude of the reference wave
refAmplitude = max(max(abs(objectWave)));

referenceWave = zeros(hologramSamplesY, hologramSamplesX);
for column = 1:hologramSamplesX
  for row = 1:hologramSamplesY
    x = (column-1) * samplingDistance + hologramCornerX;
    y = (row-1)    * samplingDistance + hologramCornerY;
    referenceWave(row,column) = refAmplitude * ...
       exp(imagUnit*k*(x*nX + y*nY + hologramZ*nZ));
  end
end

//
// Display & save
//

saveAmplitude(referenceWave, '02_referenceWave_amplitude.png');
saveIntensity(referenceWave, '02_referenceWave_intensity.png');
savePhase(referenceWave, '02_referenceWave_phase.png');
saveComplexPart(real(referenceWave), '02_referenceWave_real.png');
saveComplexPart(imag(referenceWave), '02_referenceWave_imag.png');

showImage(xAxis, yAxis, real(referenceWave), 'Reference wave (real part)');
waitForKey('Press ENTER to continue.');

// ---------------------------------------------

//
// 3. The hologram calculation
//

mprintf('\nThe hologram calculation...\n');

// Calculate the sum of object and reference wave first (optical field incident 
// on the hologram plane.
optField = objectWave + referenceWave;

//  Calculate the intensity of the optical field
//  (i.e. the recorded hologram)
hologram = optField .* conj(optField);

//  Ensure that the imaginary part is zero
hologram = real(hologram);

//
// Display & save
//

saveIntensity(hologram, '03_hologram.png');
saveAmplitude(hologram, '03_hologram_amplitude.png');

showImage(xAxis, yAxis, real(hologram), 'Hologram (intensity)');
waitForKey('Press ENTER to continue.');

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//
// Numerical propagation of the hologram
//  
// 4. The propagation kernel calculation
//

mprintf('\n\nNumerical propagation of the hologram.\n');
mprintf('The propagation kernel calculation...\n');


// Propagation from z=hologramZ (hologram position)
// to z=pointsZ. In this case, we are going to observe the real image
// located at the opposite side of the hologram.
propagZ = abs(pointsZ - hologramZ);

// Propagation by convolution is calculated using matrices of size
// (cY rows) x (cX columns).
cX = 2*hologramSamplesX-1; 
cY = 2*hologramSamplesY-1; 

//  Auxiliary x, y coordinates for the convolution calculation
auxX = ((0:cX-1) - (hologramSamplesX-1)) * samplingDistance;
auxY = ((0:cY-1) - (hologramSamplesY-1)) * samplingDistance;
[auxXX, auxYY] = meshgrid(auxX, auxY);

// Calculate the propagation kernel.
// Note it is equal to 
//    k * i * exp(i*k*r)/r * propagZ/r
// where r is a distance between points, i.e. it is not the exact 
// Rayleigh-Sommerfeld kernel. However, the difference is negligible.

r = sqrt(auxXX.^2 + auxYY.^2 + propagZ^2);
kernel = k*imagUnit*propagZ*exp(imagUnit*k*r) ./ r.^2;

//
// Display & save
//

saveAmplitude(kernel, '04_kernel_amplitude.png');
saveIntensity(kernel, '04_kernel_intensity.png');
savePhase(kernel, '04_kernel_phase.png');
saveComplexPart(real(kernel), '04_kernel_real.png');
saveComplexPart(imag(kernel), '04_kernel_imag.png');

showImage(auxX, auxY, real(kernel), 'Convolution kernel (real part)');
waitForKey('Press ENTER to continue.');

// ---------------------------------------------

//
// 5. The reconstruction calculation
//

mprintf('\nThe reconstruction calculation...\n');


// Create the auxiliary matrix of the correct size for the convolution
// calculation. "Correct size" means that cyclic nature of the discrete
// convolution will be suppressed.
auxMatrix = zeros(cY, cX);

// Place a hologram illuminated by the reference wave
// to the auxiliary matrix. The rest of the samples is 0. This step
// is called "zero padding".
auxMatrix(1:hologramSamplesY, 1:hologramSamplesX) = hologram .* conj(referenceWave);

// Kernel has to be folded so that the entry for x=0, y=0
// is in the first row, first column of the kernel matrix.
kernel = circularShift(kernel, hologramSamplesY - cX, hologramSamplesX - cX);

// Calculate the cyclic convolution using FFT.
auxMatrixFT = fft2(auxMatrix) .* fft2(kernel);
auxMatrix = ifft2(auxMatrixFT);

// Pick the values that are not damaged by the cyclic nature
// of the FFT convolution.
reconstruction = auxMatrix(1:hologramSamplesY, 1:hologramSamplesX);

//
// Display & save
//

saveAmplitude(reconstruction, '05_reconstruction_amplitude.png');
saveIntensity(reconstruction, '05_reconstruction_intensity.png');
savePhase(reconstruction, '05_reconstruction_phase.png');
saveComplexPart(real(reconstruction), '05_reconstruction_real.png');
saveComplexPart(imag(reconstruction), '05_reconstruction_imag.png');

showImage(xAxis, yAxis, abs(reconstruction), 'Reconstructed image (intensity)');
waitForKey('Press ENTER to finish the script.');

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// END OF THE SCRIPT
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
