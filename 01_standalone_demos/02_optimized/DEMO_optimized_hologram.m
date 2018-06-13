% Slightly optimized code for a calculation of a hologram of a point cloud
% and its reconstruction.
% Contrary to the demo DEMO_simple_hologram,
% calculations use matrix operations. Reconstruction code is slightly 
% enhanced to accept any size of the reconstruction screen.
% It also correctly deals backpropagation.
%
% The demo calculates
%  1. the object wave,
%  2. the reference wave,
%  3. the hologram,
%  4. the kernel used for hologram reconstruction (light propagation),
%  5. the reconstructed real image.
% In each step, an image is shown and several images are saved.
% It is wiser to watch the images in an external image viewer
% that allows 1:1 pixel mapping between the image and the display.
%
% ---------------------------------------------
%
% Note that while a photographic film captures light intensity,
% the images that store intensity are actually not suitable for direct
% viewing. Recall that common digital images are supposed to be gamma
% corrected, gamma = 2.2. Thus, the image that stores amplitude can be 
% thought as a reasonable approximation of a gamma corrected intensity 
% image, as amplitude = intensity ^ (1/2).
%
% ---------------------------------------------
%
% A few functions that accompany this demo are either for Octave/MATLAB/Scilab
% compatibility, or to provide easy to use way to save an image.
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
% 0. Initialization
% ALL DIMENSIONS ARE IN METRES
%

%
% GENERAL CALCULATION PARAMETERS
%

% Scilab compatibility
addpath('../helper_functions');
imagUnit = sqrt(-1);
piNumber = pi;
  
% Wavelength and the wave number
lambda = 532e-9;     % green DPSS laser light
k = 2*piNumber/lambda;

% Color map for the images displayed
colormap('gray');

%
% HOLOGRAM PARAMETERS
%

% Dimensions of the hologram
hologramWidth  = 2e-3;
hologramHeight = 2e-3;

% Hologram is located in z = hologramZ 
hologramZ = 0;

% Sampling distance in both xy axes
samplingDistance = 10e-6;  % common spatial light modulators

% Number of rows (y) and columns (x) of the hologram
hologramSamplesX = ceil(hologramWidth / samplingDistance);
hologramSamplesY = ceil(hologramHeight / samplingDistance);

% Location of the "lower left" corner of the hologram
% put center of the hologram to x=0, y=0
hologramCornerX = - (hologramSamplesX - 1) * samplingDistance / 2;
hologramCornerY = - (hologramSamplesY - 1) * samplingDistance / 2;

%
%  REFERENCE WAVE PARAMETERS
% 
%  angles of direction of the reference wave with the 
%  axes x and y; the angle gamma between the reference 
%  light direction and the axis z can be calculated as
%  gamma = sqrt(1 - alpha^2 - beta^2),
%  but we will not need it.
alpha = 90 * piNumber/180;
beta = 90.5 * piNumber/180;

%
% SCENE PARAMETERS
%

% Center of the scene
pointsZ = -200e-3;

% Scene depth
sceneDepth = 20e-3;

%  xyz coordinates of the point light points forming the object
points = [0, 0, pointsZ;  
  -hologramWidth / 4, -hologramHeight / 4, pointsZ;  
   hologramWidth / 4,  hologramHeight / 4, pointsZ - sceneDepth];

%
% HOLOGRAM RECONSTRUCTION PARAMETERS
%
   
% Dimensions of the reconstructed image
targetWidth = 2e-3;
targetHeight = 2e-3;

% Location of the reconstructed image in the z axis
targetZ = pointsZ - sceneDepth;
% note that pointsZ < hologramZ, i.e. we will calculate backpropagation

% Number of rows (y) and columns (x) of the reconstructed image
targetSamplesX = ceil(targetWidth / samplingDistance);
targetSamplesY = ceil(targetHeight / samplingDistance);

% Location of the "lower left" corner of the reconstructed image
% put center of the reconstructed image to x=0, y=0
targetCornerX = - (targetSamplesX - 1) * samplingDistance / 2;
targetCornerY = - (targetSamplesY - 1) * samplingDistance / 2;
 
%
%  END OF CALCULATION DEFINITIONS
%

% We will use positions of all samples in the hologram plane in 
% the following calculation of the hologram.
x = (0:(hologramSamplesX-1)) * samplingDistance + hologramCornerX;
y = (0:(hologramSamplesY-1)) * samplingDistance + hologramCornerY;
[xx, yy] = meshgrid(x, y);

% ---------------------------------------------

%
% 1. The object wave calculation
%

fprintf('\nHologram recording:\n');
fprintf('\nThe object wave calculation...\n');
flushOutput();

objectWave=zeros(hologramSamplesY, hologramSamplesX);
for source=1:size(points, 1)
  fprintf('Point light source %d of %d\n', source, size(points, 1));
  flushOutput();
  % for backpropagation, flip the sign of the imaginary unit
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
fprintf('\n');

%
% Display & save
%

saveAmplitude(objectWave, '01_objectWave_amplitude.png');
saveIntensity(objectWave, '01_objectWave_intensity.png');
savePhase(objectWave, '01_objectWave_phase.png');
saveComplexPart(real(objectWave), '01_objectWave_real.png');
saveComplexPart(imag(objectWave), '01_objectWave_imag.png');

showImage(x, y, real(objectWave), 'Object wave (real part)');
waitForKey('Press ENTER to continue.');

% ---------------------------------------------

%
% 2. The reference wave calculation
%

fprintf('\nThe reference wave calculation...\n');
flushOutput();

% direction vector of the reference wave
nX = cos(alpha); 
nY = cos(beta);
nZ = sqrt(1 - nX^2 - nY^2);

% allow nZ < 0, just in case...
if (nZ > 0)
  ii = imagUnit;
else
  ii = -imagUnit;
end

% amplitude of the reference wave
refAmplitude = max(max(abs(objectWave)));

referenceWave = refAmplitude * exp(ii * k * (xx*nX + yy*nY + hologramZ*nZ));

%
% Display & save
%

saveAmplitude(referenceWave, '02_referenceWave_amplitude.png');
saveIntensity(referenceWave, '02_referenceWave_intensity.png');
savePhase(referenceWave, '02_referenceWave_phase.png');
saveComplexPart(real(referenceWave), '02_referenceWave_real.png');
saveComplexPart(imag(referenceWave), '02_referenceWave_imag.png');

showImage(x, y, real(referenceWave), 'Reference wave (real part)');
waitForKey('Press ENTER to continue.');

% ---------------------------------------------

%
% 3. The hologram calculation
%

fprintf('\nThe hologram calculation...\n');
flushOutput();

% Calculate the sum of object and reference wave first (optical field incident 
% on the hologram plane.
optField = objectWave + referenceWave;

% Calculate the intensity of the optical field
% (i.e. the recorded hologram)
hologram = optField .* conj(optField);

% Ensure that the imaginary part is zero
hologram = real(hologram);

%
% Display & save
%

saveIntensity(hologram, '03_hologram.png');
saveAmplitude(hologram, '03_hologram_amplitude.png');

showImage(x, y, hologram, 'Hologram (intensity)');
waitForKey('Press ENTER to continue.');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Numerical propagation of the hologram
%  
% 4. The propagation kernel calculation
%


fprintf('\n\n\nNumerical propagation of the hologram.');
fprintf('\nThe propagation kernel calculation...\n');
flushOutput();

% Propagation by convolution is calculated using matrices of size
% (cY rows) x (cX columns).
cX = hologramSamplesX + targetSamplesX - 1; 
cY = hologramSamplesY + targetSamplesY - 1; 

% Shift between corners of the hologram and the target
px = targetCornerX - hologramCornerX;
py = targetCornerY - hologramCornerY;
z0 = targetZ - hologramZ;

% Auxiliary x, y coordinates for the convolution calculation
auxCX = cX - hologramSamplesX + 1;
auxCY = cY - hologramSamplesY + 1;
auxX = (1-hologramSamplesX: auxCX-1) * samplingDistance + px;
auxY = (1-hologramSamplesY: auxCY-1) * samplingDistance + py;
[auxXX, auxYY] = meshgrid(auxX, auxY);

% Backward propagation is possible as well. In that case, the value of the
% imaginary constant has to be negative. Let's define a new imaginary
% constant ii equal to the common imaginary constant i and with a 
% correct sign.
if (z0 < 0) 
    ii = -imagUnit; 
else
    ii = imagUnit; 
end

% Calculate the Rayleigh-Sommerefeld propagation kernel.

r2 = auxXX.^2 + auxYY.^2 + z0^2;
r = sqrt(r2);
kernel = -1/(2*piNumber) * (ii*k - 1./r)*z0.*exp(ii*k*r) ./ r2 * ...
  samplingDistance^2;

%
% Display & save
%

saveAmplitude(kernel, '04_kernel_amplitude.png');
saveIntensity(kernel, '04_kernel_intensity.png');
savePhase(kernel, '04_kernel_phase.png');
saveComplexPart(real(kernel), '04_kernel_real.png');
saveComplexPart(imag(kernel), '04_kernel_imag.png');

showImage(auxX, auxY, real(kernel), 'Convolution kernel (real part)');
waitForKey('Press ENTER to continue.');

% ---------------------------------------------

%
% 5. The reconstruction calculation
%

fprintf('\nThe reconstruction calculation...\n');
flushOutput();

% Create the auxiliary matrix of the correct size for the convolution
% calculation. "Correct size" means that cyclic nature of the discrete
% convolution will be suppressed.
auxMatrix = zeros(cY, cX);

% Place a hologram illuminated by the reference wave
% to the auxiliary matrix. The rest of the samples is 0. This step
% is called "zero padding".
auxMatrix(1:hologramSamplesY, 1:hologramSamplesX) = hologram .* referenceWave;

% Kernel has to be folded so that the entry for x=0, y=0
% is in the first row, first column of the kernel matrix.
kernel = circularShift(kernel, 1-hologramSamplesY, 1-hologramSamplesX);

%  Calculate the cyclic convolution using FFT.
auxMatrixFT = fft2(auxMatrix) .* fft2(kernel);
auxMatrix = ifft2(auxMatrixFT);

% Pick the values that are not damaged by the cyclic nature
% of the FFT convolution.
reconstruction = auxMatrix(1:targetSamplesY, 1:targetSamplesX);

%
% Display & save
%

saveAmplitude(reconstruction, '05_reconstruction_amplitude.png');
saveIntensity(reconstruction, '05_reconstruction_intensity.png');
savePhase(reconstruction, '05_reconstruction_phase.png');
saveComplexPart(real(reconstruction), '05_reconstruction_real.png');
saveComplexPart(imag(reconstruction), '05_reconstruction_imag.png');

targetX = (0:(targetSamplesX-1)) * samplingDistance + targetCornerX;
targetY = (0:(targetSamplesY-1)) * samplingDistance + targetCornerY;

showImage(targetX, targetY, abs(reconstruction), 'Reconstructed image (intensity)');
waitForKey('Press ENTER to finish the script.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END OF THE SCRIPT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%