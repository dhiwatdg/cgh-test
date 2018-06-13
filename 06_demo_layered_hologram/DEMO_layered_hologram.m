% Demonstration of calculation of a hologram of a scene composed of flat,
% partially transparent layers (billboards).
% In the first step, a hologram of the scene is recorded.
% In the second step, the hologram is illuminated (in place) with 
% a reconstruction wave and propagated to a screen.
% The scene reconstruction is displayed in Figure 1 together with the geometric
% image of the scene.
% The hologram is displayed in Figure 2.
%
% The billboards are defined in files layer00.png, layer01.png, ...
% Their transparencies are defined in files mask00.png, mask01.png, ...
% Note: currently, only opaque and fully transparent pixels are supported.
%
% The hologram calculation is simple. Light from the farthest layer 
% is propagated to the next layer. There, light phasors are replaced by
% the current layer color at positions where the current layer is opaque.
% The modified phasors are propagated to the next layer and so on.
% Finally, light from the last layer is propagated to the hologram plane.
% The method was introduced in [Lohmann78]. It serves as a basic idea behind
% many other hologram calculation methods that solve hidden surface elimination.
%
% The setup is made in such a way that a real image (i.e. copy
% of the original image) appears on the screen.
%
% Try changing hologram recording methods or the setup parameters.
% Observe amount of noise in the real image and image sharpness.
% Also watch brightness of the real image.
%
%
% REFERENCES:
%
% [Lohmann78] Lohmann, A. W., "Three-dimensional properties of wave-fields", 
%      Optik 51(2), 105-117 (1978).

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

% Select if the image to be recorded has random phase.
% Random phase leads to uniform hologram plane illumination suitable for phase
% only coding such as kinoform. It also helps to keep dynamic range of the 
% hologram low. However, random phase increases noise.
%
diffuseImage = true;

% Select hologram recording geometry. For the 'offAxis' case,
% the reference wave angle is set automatically.
%
% hologramType = 'onAxis';
hologramType = 'offAxis';
% hologramType = 'lenslessFourier';

% Select the hologram encoding method.
% Other hologram encoding methods (see DEMO_hologram_real_image) can be easily
% incorporated as well.
%
% hologramMethod = 'classical';
hologramMethod = 'bipolar';
% hologramMethod = 'complex';

% Set reference:object wave intensity ratio
% ROratio = 2 means that intensity of the reference wave
% is twice as high as the average intensity of the object wave.
RORatio = 2;

% Images and corresponding masks sorted from the farthest to the nearest one.
% All images (images and masks) must have the same resolution.
% For simplicity, even mask for the first image must be given,
% although it is never used.
sourceImages = { 'layer00.png', 'layer01.png', 'layer02.png' };
sourceMasks = { 'mask00.png', 'mask01.png', 'mask02.png' };
sceneDepth = 50e-3;
sceneCenterZ = -1500e-3;

% Z coordinates of the layers
sourceZ = [ -1, 0, 1 ] * sceneDepth / 2 + sceneCenterZ;

% Set the layers dimensions (all images are the same size)
sourceWidth = 10e-3;
sourceHeight = 10e-3;

% Select hologram size and position.
% Hologram sampling distance is the same as the source sampling distance.
hologramWidth = 2*sourceWidth;
hologramHeight = 2*sourceHeight;
hologramZ = 0e-3;

% For simplicity, the hologram will be reconstructed as a real image 
% in the place of the original scene by back propagation
screenZ = sourceZ(2);

%
% END OF ADJUSTABLE PARAMETER SETTINGS
%

% Initialize the calculation with the first (the farthest) layer
layersCount = size(sourceImages, 2);
source = loadImage(sourceImages{1});
image = source; % for the geometrical image of the scene
sourceSize = size(source);
sourceDeltaYX = calculateDelta(sourceSize, [sourceHeight, sourceWidth]);
sourceCenter = [0, 0, sourceZ(1)];
if (diffuseImage)
  source = applyRandomPhase(source);
end  

% Initialize the wavefront recording plane (WRP) that sweeps through the scene
wrpSize = sourceSize;
wrpDeltaYX = sourceDeltaYX;

% Hologram parameters
hologramDeltaYX = sourceDeltaYX;
hologramSize = calculateSamples([hologramHeight, hologramWidth], hologramDeltaYX);
hologramCenter = [0, 0, hologramZ];

% Screen for the hologram reconstruction
screenSize = sourceSize;
screenDeltaYX = sourceDeltaYX;
screenCenter = [0, 0, screenZ];

%
% Sweep the wavefront recording plane (wrp) through the scene
%
for layerIndex = 2:layersCount

  % Set the WRP position
  wrpCenter = [0, 0, sourceZ(layerIndex)];

  % Calculate optical field on the WRP
  wrpWave = propagate(source, sourceDeltaYX, sourceCenter, ...
    wrpSize, wrpDeltaYX, wrpCenter, ...
    lambda, '2fft', 'AngularSpectrumExact', 'localExact');

  % Read the layer located at the WRP position ("current layer")
  source = loadImage(sourceImages{layerIndex});
  mask = loadImage(sourceMasks{layerIndex});
  
  % Just for comparison, create a 'geometrical image' of the scene
  % by overlapping current layer on top of already processed layers.
  image(mask > 0) = source(mask > 0);
  
  % If necessary, apply random phase to current layer.
  if (diffuseImage)
    source = applyRandomPhase(source);
  end  
  
  % Pixels where the current layer is transparent should be equal to
  % the optical field propagated from previous layers
  source(mask == 0) = wrpWave(mask == 0);
  
  % Current layer becomes a new source
  sourceCenter = wrpCenter;
end

% Propagate the wavefront recording plane to the hologram plane.
% This is the object wave for the hologram creation process.

[objectWave, hologramX, hologramY] = propagate(source, sourceDeltaYX, sourceCenter, ...
  hologramSize, hologramDeltaYX, hologramCenter, ...
  lambda, '3fft', 'RayleighSommerfeldExact', 'localExact');
objectWaveIntensity = getWaveIntensity(objectWave);   
  
% Prepare the reference and the reconstruction waves.
% Reconstruction wave will be the exact copy of the reference wave (up to
% its amplitude). Real image can be reconstructed by backpropagation,
% virtual image can be photographed when a camera looks through the hologram.
[xx, yy] = meshgrid(hologramX, hologramY);

if (isequalString(hologramType, 'lenslessFourier'))
  % Lensless Fourier hologram
  referenceSource = [0, sourceHeight * 0.6, sceneCenterZ];
  referenceWave = pointCloudPropagateNoAliasing(referenceSource, 1, lambda, xx, yy, hologramZ);
  referenceWaveIntensity = getWaveIntensity(referenceWave);
  reconstructionWave = referenceWave;
  referenceWave = sqrt(RORatio) * sqrt(objectWaveIntensity)  * ...
                  referenceWave / sqrt(referenceWaveIntensity);
else  
  % On-axis or off-axis hologram (plane reference wave)
  referenceAlpha = 0;
  if (strcmp(hologramType, 'onAxis'))
    referenceBeta = 0;
  elseif (strcmp(hologramType, 'offAxis'))  
    referenceBeta = getMaxDiffAngle(lambda, 2.0*hologramDeltaYX(2));
  else
    error('Wrong hologram type: %s\n', hologramType);
  end  
  referenceDirection = ...
    getVectorFromAngles(referenceAlpha, referenceBeta);
  referenceWave = sqrt(RORatio) * sqrt(objectWaveIntensity) * ...
    planeWave(referenceDirection, lambda, xx, yy, hologramZ);
  reconstructionWave = ...
    planeWave(referenceDirection, lambda, xx, yy, hologramZ);
end

% Make the hologram
hologram = calculateHologram(objectWave, referenceWave, hologramMethod);

% Propagate hologram to the screen
[screen, screenX, screenY] = propagate(hologram .* reconstructionWave, ...
  hologramDeltaYX, hologramCenter, ...
  screenSize, screenDeltaYX, screenCenter, ...
  lambda, '3fft', 'RayleighSommerfeldExact', 'localExact');

%
% Display the scene and its reconstruction from the hologram
%
figure(1);
clf();

subplot(2, 1, 1);
[sourceX, sourceY] = ...
  getXYVectorFromCenter(sourceSize, sourceDeltaYX, sourceCenter);
limits = displayImage(sourceX*1e3, sourceY*1e3, image, [0, 1]);
xlabel('x [mm]');
ylabel('y [mm]');
drawTitle(sprintf('Source scene (depth %g mm) located around z = %g mm', ...
  sceneDepth*1e3, sceneCenterZ*1e3));
drawColorbar(limits);
axis('image');

subplot(2, 1, 2);
limits = displayImage(screenX*1e3, screenY*1e3, abs(screen), 'positive');
xlabel('x [mm]');
ylabel('y [mm]');
drawTitle(sprintf('Reconstructed real image in z = %g mm', ...
  screenCenter(3)*1e3));
drawColorbar(limits);
axis('image');

% saveFigure('layered-fig1.png', 400, 700);

% Display the hologram
figure(2);
clf();

limits = displayImage(hologramX*1e3, hologramY*1e3, hologram, 'auto');
xlabel('x [mm]');
ylabel('y [mm]');
drawTitle(sprintf('Hologram (%s, %s) centered at [%g, %g, %g] mm', ...
  hologramType, hologramMethod, ...
  hologramCenter(1)*1e3, hologramCenter(2)*1e3, hologramCenter(3)*1e3));
drawColorbar(limits);
axis('image');

% saveFigure('layered-fig2.png', 400, 400);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END OF THE SCRIPT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
