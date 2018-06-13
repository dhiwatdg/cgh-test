% Calculation of a diffractive optical element (DOE) that, when illuminated
% with a laser light, creates an image on a screen at a specified distance.
%
% The DOE is basically a digital hologram of a flat image. 
% In the first step, a hologram of a "big" flat image is recorded.
% The image is automatically made as big as possible in order to utilize the 
% hologram sampling distance. 
% In the second step, it is illuminated (in place) by a reconstruction wave
% and propagated to a screen.
% The setup is made in such a way that a sharp image (i.e. a real image)
% appears on the screen.
%
% The original image and its reconstruction are displayed in Figure 1.
% The hologram is displayed in Figure 2.
%
% Explore the demo DEMO_hologram_real_image to see how to make a hologram 
% of a flat image in a classical way and how to reconstruct its real image.
% Explore the demo DEMO_hologram_virtual_image to see how to take a photograph
% of a virtual image.
%
% This demo allows to play with different basic parameters that affect
% the hologram quality:
%
% 1. The image can be perfectly flat (phase at each point is the same)
%    or its surface can be rough (phase at each point is random).
%    Rough surface leads to uniform hologram plane illumination (and the
%    hologram does not need high dynamic range), but it increases noise.
%
% 2. Hologram recording setup. This demo implements on-axis, off-axis
%    and the lensless Fourier setup.
%    The image to be recorded is placed in plane z = reconstructionZ > 0.
%    The hologram is then recorded in plane z = hologramZ = 0.
%
%    The object wave is back-propagated light from the image plane backwards
%    to the hologram. Recall that in normal propagation, light tends to 
%    diverge, for example when light comes through a pinhole. Back-propagation
%    tries to estimate how light travels backwards in time, i.e. it tends to
%    converge. In this demo, backpropagated light from a large image 
%    converges to a small area of the hologram.
%
%    In the on-axis case, the reference wave direction is [0, 0, 1]. 
%    Note that it does not matter that light came from z > 0 
%    (due to backpropagation) and the reference wave travels in the opposite 
%    direction. Once a phasor of the object wave is known, it actually does not
%    matter if the light source was on its front or back side. The same
%    reasoning applies for other hologram recording geometries.
%
%    In the off-axis case, the reference wave angle is calculated automatically
%    as steep as possible, but not exceeding the limit imposed by the sampling
%    distance used in light propagation calculations. In the reconstruction step,
%    the hologram is illuminated at an opposite angle
%    (if the reference came from the top, the reconstruction wave comes from
%    the bottom) and real image is reconstructed.
%
%    In the lensless Fourier setup, the reference wave is a point light source
%    located in the source image plane z = reconstructionZ, half way between 
%    the image center and the image top edge.
%    In the reconstruction process, the hologram is illuminated by a plane 
%    wave perpendicular to the hologram (direction [0, 0, 1]).
%
%    In all cases, the screen is placed to z = reconstructionZ.
%    Observe the minus-first diffraction order (sharp image), the plus-first
%    diffraction order (rays making the virual image create an unsharp image
%    on the screen) and the zero-th order (undiffracted light).
%    Also observe physical size of the hologram and of the projected image.
%
% 3. The hologram encoding method.
%    See description in the script DEMO_hologram_real_image
%
% Try changing hologram encoding methods or the setup parameters.
% Observe amount of noise in the real image and image sharpness.
% Also watch brightness of the real image.
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

% Scilab compatibility
imagUnit = sqrt(-1);
piNumber = pi;

% Wavelength, a green DPSS laser
lambda = 532e-9;

% Select if the image to be recorded has random phase.
% Random phase leads to uniform hologram suitable for phase
% only coding such as kinoform, but increases noise.
%
diffuseImage = true;

% Select hologram recording (and reconstruction) geometry.
% Consider changing exposureLimit when changing the geometry.
%
hologramType = 'onAxis';
% hologramType = 'offAxis';
% hologramType = 'lenslessFourier';

% Set hologram encoding method
%
hologramMethod = 'classical';
% hologramMethod = 'bipolar';
% hologramMethod = 'shiftedBipolar';
% hologramMethod = 'kinoformArgument';
% hologramMethod = 'complex';

% Binarize the hologram?
% Note: binarization is performed before bleaching.
% Binarization of a complex hologram is not supported.
binarize = false;

% Select amplitude or phase (bleached) hologram
% (Note that 'kinoformArgument' and 'complex' types
% do not take this into account, see code below.)
bleach = false;
bleachMaxPhase = 2*piNumber; % max. phase change for phase only holograms
  % Note that for binarized bleached hologram, bleachMaxPhase = 2*piNumber
  % results to no phase change at all

% Set reference:object wave intensity ratio
% ROratio = 5 means that intensity of the reference wave
% is five times as high as the average intensity of the object wave.
RORatio = 5;

% Set "exposure control" for DISPLAY purposes. It basically sets white level.
% Setting exposureLimit to 0 means "auto exposure", i.e. maximum value
% is displayed as white.
% Setting it to non zero positive value can lead to overexposure or 
% underexposure. On the other hand, it allows to compare reconstructions from
% various holograms easily.
% Note that autoexposure often leads to bad results as the undeffracted light
% (0-th diffraction order) can be much stronger than the reconstructed image.
%
exposureLimit = 1e-2;
% exposureLimit = 0;  % auto exposure

% Select suitable image to be recorded.
% Note that in this demo, the hologram sampling distance is fixed. 
% As the hologram has the same number of pixels as the image, it follows that
% an image with more pixels leads to physically larger hologram. 
%
if (isequalString(hologramType, 'onAxis'))
  % in the on-axis case, pick a file where the image is off the center
  imageSource = loadImage('../images/cgdh_offaxis_1024px.png');
else  
  % in the off-axis case, pick a file where the image is in the center
  imageSource = loadImage('../images/cgdh_onaxis_1024px.png');
end  

% Select distance from the hologram to the projected image.
% The projected image size depends on this distance and the sampling distance
% of the hologram.
reconstructionZ = 500e-3;     % suitable for the high-res image

% Minnimum sampling distance of the hologram.
% For square images, the sampling distances in both directions will be the same.
% For non-square images, sampling distances are adjusted: the long side of the
% image requires a big diffraction angle, thus small pixel pitch (sampling 
% distance). The short side does not require such a small sampling distance.
% Thus, the "minimum sampling distance" corresponds to the long side of the 
% image, the other sampling distance is calculated automatically.
%
% Note that hologramDeltaMin also affects the angle of the reference wave in the
% off-axis recording geometry.
hologramDeltaMin = 2e-6;

%
% END OF ADJUSTABLE PARAMETER SETTINGS
%

% Source image parameters
imageSamplesYX = size(imageSource);
imageCenter = [0, 0, reconstructionZ];

% Hologram parameters
hologramSamplesYX = imageSamplesYX; % must be the same, it is a limitation of 
                                    % the 1fft light propagation method used later
hologramDeltaYX = hologramDeltaMin * ...
                  [hologramSamplesYX(2)/hologramSamplesYX(1), 1];
hologramDimensionsYX = calculateDimension(hologramSamplesYX, hologramDeltaYX);
hologramHeight = hologramDimensionsYX(2);
hologramWidth = hologramDimensionsYX(1);
hologramZ = 0;
hologramCenter = [0, 0, hologramZ];


% Find projected image parameters
imageDeltaYX = get1fftTargetDeltaYX(lambda, ...
  hologramSamplesYX, hologramDeltaYX, imageCenter(3)-hologramCenter(3));
imageDimensions = calculateDimension(imageSamplesYX, imageDeltaYX);
imageHeight = imageDimensions(1);
imageWidth  = imageDimensions(2);

% Propagation method for image -> hologram calculation
propagationMethod = '1fft'; 
kernelType = 'Fresnel';
filteringMethod = 'localExact';

% Propagate the image to the hologram plane
if (diffuseImage)
  imageSource = applyRandomPhase(imageSource);
end  

[objectWave, hologramX, hologramY] = propagate(...
  imageSource, imageDeltaYX, imageCenter, ...
  [], [], hologramCenter, ...
  lambda, propagationMethod, kernelType, filteringMethod);
objectWaveIntensity = getWaveIntensity(objectWave); 

% Prepare the reference and the reconstruction waves 
[xx, yy] = meshgrid(hologramX, hologramY);

if (isequalString(hologramType, 'lenslessFourier'))
  % Lensless Fourier hologram
  % Point light source used as the reference must be inside the image area,
  % as maximum diffraction angle from the hologram touches the image edges.
  referenceSource = [0, imageHeight * 0.25, 0] + imageCenter;  
  referenceWave = pointCloudPropagateNoAliasing(referenceSource, 1, lambda, xx, yy, hologramZ);
  referenceWaveIntensity = getWaveIntensity(referenceWave);
  referenceWave = sqrt(RORatio) * sqrt(objectWaveIntensity)  * ...
                  referenceWave / sqrt(referenceWaveIntensity);
  reconstructionWave = ...
    planeWave([0, 0, 1], lambda, xx, yy, hologramZ);
else  
  % On-axis or off-axis hologram (plane reference wave)
  % Alpha and beta are angles relative to X and Y axes minus pi/2 rad,
  % i.e. alpha = beta = 0 results in direction [0, 0, 1]
  referenceAlpha = 0;
  if (isequalString(hologramType, 'onAxis'))
    referenceBeta = 0;
  elseif (isequalString(hologramType, 'offAxis'))  
    referenceBeta = getMaxDiffAngle(lambda, 2.0*hologramDeltaYX(2));
  else
    error('Wrong hologram type: %s\n', hologramType);
  end  

  referenceDirection = ...
    getVectorFromAngles(referenceAlpha, referenceBeta);
  referenceWave = sqrt(RORatio) * sqrt(objectWaveIntensity) * ...
    planeWave(referenceDirection, lambda, xx, yy, hologramZ);

  % Reconstruction wave angles are opposite to the
  % reference wave in order to watch the real image on the screen.  
  reconstructionAlpha = -referenceAlpha;
  reconstructionBeta = -referenceBeta;
  reconstructionDirection = ...
    getVectorFromAngles(reconstructionAlpha, reconstructionBeta);
  reconstructionWave = ...
    planeWave(reconstructionDirection, lambda, xx, yy, hologramZ);
end

%  
% Make the hologram
% Note that it does not matter that the object wave came from z > 0,
% while the reference wave possibly comes from the opposite direction.
% To understand why, realize that a point light source located at [0, 0, +Z]
% has the same amplitude and phase in the plane z = 0 as a point light source
% located at [0, 0, -Z]. 
%
hologram = calculateHologram(objectWave, referenceWave, hologramMethod, true);

% Binarize
if (binarize && ~isequalString(hologramMethod, 'complex'))
  % Convert the hologram to zeros and ones
  hologram = binarizeHologram(hologram);
  
  if (isequalString(hologramMethod, 'bipolar'))
    % For bipolar intensity, change it to +0.5 and -0.5
    hologram = hologram - 0.5;
  end
end

% Bleach the hologram, if desired
if (isequalString(hologramMethod, 'kinoformArgument'))
  bleach = true;
end

if (bleach && ~isequalString(hologramMethod, 'complex'))
  hologram = bleachHologram(hologram, bleachMaxPhase);
end

% Conjugate certain holograms in order to watch the real image
% in the reconstruction step.
if (isequalString(hologramMethod, 'complex') || ...
    isequalString(hologramMethod, 'kinoformArgument'))
  hologram = conj(hologram);
end  

% Prepare the screen for the hologram reconstruction
% and the propagation calculation parameters
screenZ = reconstructionZ;
screenSamplesYX = [];    % auto detection
screenDeltaYX = [];      % auto detection
propagationMethod = '1fft';
kernelType = 'Fresnel';
filteringMethod = 'localExact';

screenCenter = [0, 0, screenZ];

% Propagate hologram to the screen
[screen, screenX, screenY] = propagate(hologram .* reconstructionWave, ...
  hologramDeltaYX, hologramCenter, ...
  screenSamplesYX, screenDeltaYX, screenCenter, ...
  lambda, propagationMethod, kernelType, filteringMethod);

%
% Display the original image and the result of the hologram reconstruction
%
figure(1);
clf();

subplot(2, 1, 1);
[imageX, imageY] = ...
  getXYVectorFromCenter(imageSamplesYX, imageDeltaYX, imageCenter);
limits = displayImage(imageX*1e3, imageY*1e3, abs(imageSource), 'positive');
xlabel('x [mm]');
ylabel('y [mm]');
title(sprintf('Source image (abs value) located at [%g, %g, %g] mm', ...
  imageCenter(1)*1e3, imageCenter(2)*1e3, imageCenter(3)*1e3));
drawColorbar(limits);
axis('image');
  
subplot(2, 1, 2);
if (exposureLimit == 0)
  normalizeType = 'positive';
else
  normalizeType = [0, exposureLimit];
end
limits = displayImage(screenX*1e3, screenY*1e3, abs(screen), normalizeType);
xlabel('x [mm]');
ylabel('y [mm]');
title(sprintf('Reconstructed real image (abs. value) located at [%g, %g, %g] mm', ...
  screenCenter(1)*1e3, screenCenter(2)*1e3, screenCenter(3)*1e3));
drawColorbar(limits);
axis('image');

%
% Display the hologram
%
figure(2);
clf();

if (bleach)
  bleachString = ' bleached';
else
  bleachString = '';
end

% For the phase holograms, you may like changing display mode from 'auto'
% to 'phase' to see phase in grayscale.
limits = displayImage(hologramX*1e3, hologramY*1e3, hologram, 'auto');
xlabel('x [mm]');
ylabel('y [mm]');
title(sprintf('Hologram (%s, %s%s) located at [%g, %g, %g] mm', ...
  hologramType, hologramMethod, bleachString, ...
  hologramCenter(1)*1e3, hologramCenter(2)*1e3, hologramCenter(3)*1e3));
drawColorbar(limits);
axis('image');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END OF THE SCRIPT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
