// Slightly optimized code for a calculation of a hologram of a point cloud
// and its VIRTUAL IMAGE reconstruction.
// (Note the image is reversed as expected.)
//
// This demo is basically the same as 02_optimized/DEMO_optimized_hologram.
// It adds step 4 and slightly modifies the initialization step.
// All modification are denoted by %%%// LENS and %%// END LENS comments.
// The rest of the script is unchanged.
//
// The script calculates
//  1. the object wave,
//  2. the reference wave,
//  3. the hologram,
//  4. the lens applied to the virtual image observation
//  5. the kernel used for hologram reconstruction,
//  6. the "photographed" virtual image
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
// A few functions that accompany this demo are either for Octave/Matlab
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
  
// Wavelength and the wave number
lambda = 532e-9;     // green DPSS laser light
k = 2*piNumber/lambda;

// Color map for the images displayed
gcf().color_map = graycolormap(256);

//
// HOLOGRAM PARAMETERS
//

// Dimensions of the hologram
hologramWidth = 2e-3;
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
//  angles of direction of the reference wave with the 
//  axes x and y; the angle gamma between the reference 
//  light direction and the axis z can be calculated as
//  gamma = sqrt(1 - alpha^2 - beta^2),
//  but we will not need it.
alpha = 90 * piNumber/180;
beta = 90.5 * piNumber/180;

//
// SCENE PARAMETERS
//

// Center of the scene
pointsZ = -200e-3;

// Scene depth
sceneDepth = 20e-3;

//
//%%// LENS
//

// xyz coordinates of the point light points forming the object
// Note that the points 4 and 5 added in this example
// together with the point 1
// form a line that lies in the plane x = 0.
// This line should look vertical when viewed from [0, 0, 0],
// and oblique when viewed from [x, 0, 0], x != 0
points = [0, 0, pointsZ;  
  -hologramWidth / 4, -hologramHeight / 4, pointsZ;  
   hologramWidth / 4,  hologramHeight / 4, pointsZ - sceneDepth;
//
   0, hologramHeight / 4, pointsZ - sceneDepth;
   0, -hologramHeight / 4, pointsZ + sceneDepth
];

//
// HOLOGRAM RECONSTRUCTION PARAMETERS
//

// The lens is attached directly to the hologram, i.e.
// it is located in z = hologramZ.
// The sensor behind the lens is positioned automatically
// in this demo.

// Focal length of the lens used to photograph the virtual image
// here, 100 mm
focalLength = abs(pointsZ) / 2;

// Lens center in the xy plane. It defines "the camera position".
// Try lensCentre = 0 as well!
lensCentreX = hologramWidth / 4;
lensCentreY = 0;

// Lens radius, here 0.5 mm.
// Note this leads to f-number f/200,
// i.e. the image has large depth of field and is very blurry.
// The whole area of the lens should be within the hologram area
// in order to get intuitive results.
lensRadius = hologramWidth / 4;

// All points in z = focusZ will be in focus.
// Moreover, the sensor will be shifted in such a way such that 
// the point [focusX, focusY, focusZ] appears in the sensor center.
focusX = 0;
focusY = 0;
focusZ = pointsZ;


// Dimensions of the image sensor
targetWidth = hologramWidth;
targetHeight = hologramHeight;

// Subsequently, the image sensor will be placed to z = targetZ
// according to the the thin lens formula (in the common sign convention)
//   1/(focusZ - hologramZ) - 1/(targetZ - hologramZ) = -1/focalLength
// where we assume pointsZ < hologramZ < targetZ.
// For pointsZ = -200 mm, hologramZ = 0, focalLength = 100 mm,
// we get targetZ = 200 mm and the image magnification will be 1.

//
// END LENS
//

//
//  END OF CALCULATION DEFINITIONS
//

// We will use positions of all samples in the hologram plane in 
// the following calculation of the hologram.
x = (0:(hologramSamplesX-1)) * samplingDistance + hologramCornerX;
y = (0:(hologramSamplesY-1)) * samplingDistance + hologramCornerY;
[xx, yy] = meshgrid(x, y);

// ---------------------------------------------

//
// 1. The object wave calculation
//

mprintf('\nHologram recording:\n');
mprintf('\nThe object wave calculation...\n');


objectWave=zeros(hologramSamplesY, hologramSamplesX);
for source=1:size(points, 1)
  mprintf('Point light source %d of %d\n', source, size(points, 1));
  
  // for backpropagation, flip the sign of the imaginary unit
  if (points(source, 3) > hologramZ)
    ii = -imagUnit;
  else
    ii = imagUnit;
  end
  r = sqrt((xx - points(source, 1)).^2 + ...
           (yy - points(source, 2)).^2 + ...
           (hologramZ - points(source, 3)).^2);
	objectWave = objectWave + exp(ii*k*r) ./ r;
end
mprintf('\n');

//
// Display & save
//

saveAmplitude(objectWave, '01_objectWave_amplitude.png');
saveIntensity(objectWave, '01_objectWave_intensity.png');
savePhase(objectWave, '01_objectWave_phase.png');
saveComplexPart(real(objectWave), '01_objectWave_real.png');
saveComplexPart(imag(objectWave), '01_objectWave_imag.png');

showImage(x, y, real(objectWave), 'Object wave (real part)');
waitForKey('Press ENTER to continue.');

// ---------------------------------------------

//
// 2. The reference wave calculation
//

mprintf('\nThe reference wave calculation...\n');


// direction vector of the reference wave
nX = cos(alpha); 
nY = cos(beta);
nZ = sqrt(1 - nX^2 - nY^2);

// allow nZ < 0, just in case...
if (nZ > 0)
  ii = imagUnit;
else
  ii = -imagUnit;
end

// amplitude of the reference wave
refAmplitude = max(max(abs(objectWave)));

referenceWave = refAmplitude * exp(ii * k * (xx*nX + yy*nY + hologramZ*nZ));

//
// Display & save
//

saveAmplitude(referenceWave, '02_referenceWave_amplitude.png');
saveIntensity(referenceWave, '02_referenceWave_intensity.png');
savePhase(referenceWave, '02_referenceWave_phase.png');
saveComplexPart(real(referenceWave), '02_referenceWave_real.png');
saveComplexPart(imag(referenceWave), '02_referenceWave_imag.png');

showImage(x, y, real(referenceWave), 'Reference wave (real part)');
waitForKey('Press ENTER to continue.');

// ---------------------------------------------

//
// 3. The hologram calculation
//

mprintf('\nThe hologram calculation...\n');


// Calculate the sum of object and reference wave first (optical field incident 
// on the hologram plane.
optField = objectWave + referenceWave;

// Calculate the intensity of the optical field
// (i.e. the recorded hologram)
hologram = optField .* conj(optField);

// Ensure that the imaginary part is zero
hologram = real(hologram);

//
// Display & save
//

saveIntensity(hologram, '03_hologram.png');
saveAmplitude(hologram, '03_hologram_amplitude.png');

showImage(x, y, hologram, 'Hologram (intensity)');
waitForKey('Press ENTER to continue.');

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//
// Numerical propagation of the hologram
//

//  number of rows (y) and columns (x) of the target
targetSamplesX = ceil(targetWidth / samplingDistance);
targetSamplesY = ceil(targetHeight / samplingDistance);

//
// LENS
//

// Determine the image sensor z position such that the plane
// z = focusZ will be in focus
targetZ = 1/(1/focalLength + 1/(focusZ - hologramZ)) + hologramZ;

// Shift the sensor center in such a way that points
//   [focusX, focusY, focusZ]
//   [lensCentreX, lensCentreY, hologramZ]
//   [targetCentreX, targetCentreY, targetZ]
// lie on a line.
targetCentreX = focusX + (targetZ - focusZ) * ...
  (lensCentreX - focusX ) / (hologramZ - focusZ)
targetCentreY = focusY + (targetZ - focusZ) * ...
  (lensCentreY - focusY ) / (hologramZ - focusZ)
 
// Location of the "lower left" corner of the reconstructed image
// put center of the reconstructed image to targetCentreX, targetCentreY
targetCornerX = - (targetSamplesX - 1) * samplingDistance / 2 + targetCentreX;
targetCornerY = - (targetSamplesY - 1) * samplingDistance / 2 + targetCentreY;


//
// 4. Apply the lens
//

mprintf('\nThe lens calculation...\n');



// A thin lens changes phase of the incoming light
// in this way, see e.g. Goodman: Introduction to Fourier Optics.
// Please note this simple lens shows many aberrations!
lens = exp(-imagUnit * k / (2*focalLength) * ...
  ((xx - lensCentreX).^2 + (yy - lensCentreY).^2));

// Mask areas outside the lens area
rho = (xx - lensCentreX ).^2 + (yy - lensCentreY).^2 - lensRadius^2;
lens(rho > 0) = 0;

// Apply the lens
hologram = hologram .* lens;

showImage(x, y, real(lens), 'Lens phase change (real part)');
waitForKey('Press ENTER to continue.');

saveAmplitude(lens, '04_lens_amplitude.png');
savePhase(lens, '04_lens_phase.png');
saveComplexPart(real(lens), '04_lens_real.png');
saveComplexPart(imag(lens), '04_lens_imag.png');


//
// END LENS
//


//  
// 5. The propagation kernel calculation
//


mprintf('\n\n\nNumerical propagation of the hologram with with a lens attached.');
mprintf('\nThe propagation kernel calculation...\n');



// Propagation by convolution is calculated using matrices of size
// (cY rows) x (cX columns).
cX = hologramSamplesX + targetSamplesX - 1; 
cY = hologramSamplesY + targetSamplesY - 1; 

// Shift between corners of the hologram and the target
px = targetCornerX - hologramCornerX;
py = targetCornerY - hologramCornerY;
z0 = targetZ - hologramZ;

//  Auxiliary x, y coordinates for the convolution calculation
auxCX = cX - hologramSamplesX + 1;
auxCY = cY - hologramSamplesY + 1;
auxX = (1-hologramSamplesX: auxCX-1) * samplingDistance + px;
auxY = (1-hologramSamplesY: auxCY-1) * samplingDistance + py;
[auxXX, auxYY] = meshgrid(auxX, auxY);

// Backward propagation is possible as well. In that case, the value of the
// imaginary constant has to be negative. Let's define a new imaginary
// constant ii equal to the common imaginary constant i and with a 
// correct sign.
if (z0 < 0) 
    ii = -imagUnit; 
else
    ii = imagUnit; 
end

// Calculate the Rayleigh-Sommerefeld propagation kernel.

r2 = auxXX.^2 + auxYY.^2 + z0^2;
r = sqrt(r2);
kernel = -1/(2*piNumber) * (ii*k - 1./r)*z0.*exp(ii*k*r) ./ r2 * ...
  samplingDistance^2;

//
// Display & save
//

saveAmplitude(kernel, '05_kernel_amplitude.png');
saveIntensity(kernel, '05_kernel_intensity.png');
savePhase(kernel, '05_kernel_phase.png');
saveComplexPart(real(kernel), '05_kernel_real.png');
saveComplexPart(imag(kernel), '05_kernel_imag.png');

showImage(auxX, auxY, real(kernel), 'Convolution kernel (real part)');
waitForKey('Press ENTER to continue.');

// ---------------------------------------------

//
// 6. The reconstruction calculation
//

mprintf('\nThe reconstruction calculation...\n');


// Create the auxiliary matrix of the correct size for the convolution
// calculation. "Correct size" means that cyclic nature of the discrete
// convolution will be suppressed.
auxMatrix = zeros(cY, cX);

// Place a hologram illuminated by the reference wave
// to the auxiliary matrix. The rest of the samples is 0. This step
// is called "zero padding".
auxMatrix(1:hologramSamplesY, 1:hologramSamplesX) = hologram .* referenceWave;

// Kernel has to be folded so that the entry for x=0, y=0
// is in the first row, first column of the kernel matrix.
kernel = circularShift(kernel, 1-hologramSamplesY, 1-hologramSamplesX);

// Calculate the cyclic convolution using FFT.
auxMatrixFT = fft2(auxMatrix) .* fft2(kernel);
auxMatrix = ifft2(auxMatrixFT);

// Pick the values that are not damaged by the cyclic nature
// of the FFT convolution.
reconstruction = auxMatrix(1:targetSamplesY, 1:targetSamplesX);

//
// Display & save
//

saveAmplitude(reconstruction, '06_reconstruction_amplitude.png');
saveIntensity(reconstruction, '06_reconstruction_intensity.png');
savePhase(reconstruction, '06_reconstruction_phase.png');
saveComplexPart(real(reconstruction), '06_reconstruction_real.png');
saveComplexPart(imag(reconstruction), '06_reconstruction_imag.png');

targetX = (0:(targetSamplesX-1)) * samplingDistance + targetCornerX;
targetY = (0:(targetSamplesY-1)) * samplingDistance + targetCornerY;

showImage(x, y, abs(reconstruction), 'Reconstructed image (intensity)');
waitForKey('Press ENTER to finish the script.');

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// END OF THE SCRIPT
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%