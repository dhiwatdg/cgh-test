% Simulation of a digital hologram recording and reconstruction
% In the first step, a hologram of a flat image is recorded.
% In the second step, it is illuminated (in place) by a reconstruction wave
% and propagated to a screen.
% The setup is made in such a way that a REAL IMAGE (i.e. a copy
% of the original image) appears on the screen.
%
% The original image and its reconstruction are displayed in Figure 1.
% The hologram is displayed in Figure 2.
% (Explore the demo DEMO_hologram_virtual_image to see how to take a photograph
% of a virtual image.)
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
%    The image to be recorded is placed in plane z = 0.
%    The hologram is then recorded in plane z = hologramZ.
%
%    In the on-axis case, the reference wave direction is [0, 0, 1]. The 
%    screen is then placed to z = 2*hologramZ and a real image is reconstructed.
%
%    In the off-axis case, the reference wave angle is calculated automatically
%    as steep as possible, but not exceeding the limit imposed by the sampling
%    distance used in light propagation calculations. Again, the screen is 
%    placed to z = 2*hologramZ, the hologram is illuminated at an opposite angle
%    (if the reference came from the top, the reconstruction wave comes from
%    the bottom) and real image is reconstructed.
%
%    In the lensless Fourier setup, the reference wave is a point light source
%    located in the source image plane z = 0, slightly above the image.
%    In the reconstruction process, the hologram is illuminated by a plane 
%    wave perpendicular to the hologram (direction [0, 0, 1]) and the screen
%    is placed to z = 100 * hologramZ (far from the hologram). The reconstructed
%    real image is usually composed of two replica of the source image.
%
% 3. The hologram encoding method.
%    'classical' is the basic physically based method, the hologram is
%        simply the intensity of the object wave plus the reference wave.
%        If we denote the object wave amplitude as O and the reference wave
%        amplitude as R, the classical hologram C is given as
%          C = |O + R|^2 = (O + R) . (O + R)*
%        where * is the complex conjugate and . (dot) is multiplication. 
%    'bipolar' is a bipolar intensity popularized in [Lucente94Phd].
%        If we expand the formula for the classical hologram, we get
%          C = OO* + RR* + OR* + RO*
%            = OO* + RR* + 2 Re(OR*)
%        where Re() is the real part of a complex number. 
%        Only the last term is important for holography, the terms OO* and RR*
%        just add noise and move the result to positive values.
%        In computational holography, we can easily neglect them and define
%        the bipolar intensity as
%          B = Re(OR*)
%        A bipolar intensity hologram is free from the noise term and has
%        higher diffraction efficiency than the classical (physically based)
%        encoding. It can be thought as an intensity image where the negative 
%        parts add phase shift +pi radians.
%    'shiftedBipolar' is just a slight modification of the bipolar intensity.
%        It is defined as
%          S = B - min(B)
%        where B is the bipolar intensity and the constant term min(B) makes
%        all values non-negative. The shiftedBipolar hologram is then
%        a simple intensity image free from the noise present in the classical
%        encoding method.
%    'kinoformArgument' implements the kinoform method introduced in [Lesem69],
%        generalized to arbitrary reference wave. It is simply defined as
%          K = angle(OR*)
%        where angle() is the phase of a complex number.
%        [In other words, for any complex X it holds X = |X| . angle(X)]
%        The image 'K' must be converted to phase image before using it
%        (it must be bleached, see below). It means that the value K at a point
%        does not change the amplitude of the transmitted illumination wave,
%        but it changes its phase. Formally, it can be written as
%          Kb = (OR*) / |OR*|
%        The kinoform more or less requires |OR*| = const. over the area
%        of the hologram. Otherwise, reconstruction of the hologram is
%        very poor.
%        Please note that the original kinoform assumes R = 1, i.e. a plane
%        wave at normal incidence.
%    'complex' is in fact not a hologram at all. It is defined as
%          L = O / R
%        which means that if we illuminate such an amplitude-phase changing 
%        image with an exact copy of the reference wave, we get
%          L . R = (O / R) . R = O
%        i.e., the exact copy of the original object wave.
%        The complex type is very useful as a 'ground truth' as it provides
%        a perfect diffraction limited imaging method.
%        Note that for a plane reference wave with unit amplitude, it holds
%          L = O / R = OR*
%        i.e. it naturally finishes the sequence of hologram encodings:
%          C = OO* + RR* + 2 Re(OR*)      [classical intensity]
%          B = Re(OR*)                    [bipolar intensity]
%          K = angle(OR*)                 [kinoform (before bleaching)]
%          L = OR*                        [complex]
%
%    All intensity based types can be further "bleached". It means that
%    the image changes the phase of the transmitted reconstruction wave
%    instead of its amplitude. The name comes from classical photochemical
%    holography, where the hologram captured on a silver halide emulsion
%    (a black and white interference pattern) was treated in a bleaching 
%    solution. This solution converted opaque silver grains to a transparent
%    substance with a different index of refraction than the rest of the 
%    emulsion. The result: places that were originally deep black changed
%    phase of the transmitted light more than places originally transparent.
%    Note that the 'kinoformArgument' type must be bleached in order to
%    work. Also note that the 'complex' type already changes phase and cannot
%    be "bleached".
%
%    When encoding the object wave to a hologram using aforementioned methods,
%    it is necessary to set the reference wave intensity. This is another
%    parameter to play with.
%    If the ratio reference intensity / object intensity is high (the reference 
%    wave is much stronger than the object wave), the diffraction efficiency is
%    low (the reconstructed image is dim). On the other hand, such a hologram
%    does not require high dynamic range recording material and is generally
%    less noisy.
%    If the ratio reference intensity / object intensity smaller than one
%    (the reference wave is weaker than the object wave), the reconstruction
%    generally gets noisier and the diffraction efficiency is low.
%    The highest diffraction efficiency can be expected for the ratios between
%    1 and 10.
%    
%    Finally, the hologram can be binarized (before bleaching, if bleaching
%    is introduced). Note that many spatial light modulators are binary,
%    laser lithography of electron beam lithography are often binary as well.
%    Thus, binarization step allows to study its effects in practical
%    fabrication. Binarization has no advantage for pure computational 
%    holography.
%
% Try changing hologram encoding methods or the setup parameters.
% Observe amount of noise in the real image and image sharpness.
% Also watch brightness of the real image.
%
% REFERENCES:
%
% [Lucente94Phd] Lucente, M., [Diffraction-Specific Fringe Computation For 
%      Electro-Holography (Ph.D. thesis)], Massachusetts Institute of 
%      Technology, Cambridge (1994). 
% [Lesem69] Lesem, L. B., Hirsch, P. M., Jordan, J. A., "The Kinoform: A New 
%      Wavefront Reconstruction Device", IBM J. Res. Dev. 13(2), 150-155 (1969).

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
% hologramType = 'onAxis';
hologramType = 'offAxis';
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
%
exposureLimit = 1;
% exposureLimit = 1e-2; % start with this for the lensless Fourier setup

% Select suitable image to be recorded.
% Remember to set a suitable hologram recording distance. Note that the hologram
% resolution affects angle of the reference wave in the off-axis setup, and thus
% small distances can lead to significant overlap of the zeroth-diffraction 
% order on the reconstructed image.
% Use low resolution for fast calculations, high resolution for nicer images.
%
% source = loadImage('../images/USAF_2_10mm_256px_onaxis.png');  % low resolution
source = loadImage('../images/USAF_2_10mm_1024px_onaxis.png');   % high resolution

% Select image-hologram distance.
% High resolution images (small pixel size) can be closer
% to the hologram.
%
% hologramZ = 3000e-3;  % suitable for the low-res image
hologramZ = 700e-3;     % suitable for the high-res image

% Set the source image dimensions
sourceWidth = 10e-3;
sourceHeight = 10e-3;

%
% END OF ADJUSTABLE PARAMETER SETTINGS
%

% Source image parameters
sourceSamplesYX = size(source);
sourceDeltaYX = calculateDelta(sourceSamplesYX, [sourceHeight, sourceWidth]);
sourceDimensionsYX = calculateDimension(sourceSamplesYX, sourceDeltaYX);
sourceHeight = sourceDimensionsYX(2);
sourceWidth = sourceDimensionsYX(1);
sourceCenter = [0, 0, 0];

% Hologram parameters
hologramSamplesYX = sourceSamplesYX;
hologramDeltaYX = sourceDeltaYX;
hologramDimensionsYX = calculateDimension(hologramSamplesYX, hologramDeltaYX);
hologramHeight = hologramDimensionsYX(2);
hologramWidth = hologramDimensionsYX(1);
hologramCenter = [0, 0, hologramZ];

% Propagation method for source -> hologram calculation
propagationMethod = '3fft';
kernelType = 'RayleighSommerfeldExact';
filteringMethod = 'localExact';

% Propagate the source to the hologram plane
if (diffuseImage)
  source = applyRandomPhase(source);
end  

[objectWave, hologramX, hologramY] = propagate(source, sourceDeltaYX, sourceCenter, ...
  hologramSamplesYX, hologramDeltaYX, hologramCenter, ...
  lambda, propagationMethod, kernelType, filteringMethod);
objectWaveIntensity = getWaveIntensity(objectWave); 

% Prepare the reference and the reconstruction waves 
[xx, yy] = meshgrid(hologramX, hologramY);

if (isequalString(hologramType, 'lenslessFourier'))
  % Lensless Fourier hologram
  referenceSource = [0, sourceHeight * 0.6, 0] + sourceCenter;
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
if (isequalString(hologramType, 'onAxis') || ...
    isequalString(hologramType, 'offAxis'))
  screenZ = 2*hologramZ;
  screenSize = sourceSamplesYX;
  screenDeltaYX = sourceDeltaYX;
  propagationMethod = '3fft';
  kernelType = 'RayleighSommerfeldExact';
  filteringMethod = 'localExact';
elseif (isequalString(hologramType, 'lenslessFourier'))
  screenZ = 100*hologramZ;
  screenSize = [];     % auto detection
  screenDeltaYX = [];  % auto detection
  propagationMethod = '1fft';
  kernelType = 'Fresnel';
  filteringMethod = 'localExact';
else
  error(sprintf('Unknown hologram type: %s', hologramType))
end

screenCenter = [0, 0, screenZ];

% Propagate hologram to the screen
[screen, screenX, screenY] = propagate(hologram .* reconstructionWave, ...
  hologramDeltaYX, hologramCenter, ...
  screenSize, screenDeltaYX, screenCenter, ...
  lambda, propagationMethod, kernelType, filteringMethod);

%
% Display the original image and the result of the hologram reconstruction
%
figure(1);
clf();

subplot(2, 1, 1);
[sourceX, sourceY] = ...
  getXYVectorFromCenter(sourceSamplesYX, sourceDeltaYX, sourceCenter);
limits = displayImage(sourceX*1e3, sourceY*1e3, abs(source), 'positive');
xlabel('x [mm]');
ylabel('y [mm]');
title(sprintf('Source image (abs value) located at [%g, %g, %g] mm', ...
  sourceCenter(1)*1e3, sourceCenter(2)*1e3, sourceCenter(3)*1e3));
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

limits = displayImage(hologramX*1e3, hologramY*1e3, hologram);
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
