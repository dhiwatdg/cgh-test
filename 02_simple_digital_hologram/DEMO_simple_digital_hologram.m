% Simple demonstration of CGDH Tools: 
% Recording of an off-axis digital hologram of an image and subsequent 
% real image reconstruction.
%
% The image is located in the plane z = 0, its size is 10 x 10 mm.
%
% The hologram is located in the plane z = hologramZ = 700 mm. 
% The hologram size is 10 x 10 mm.
% The reference wave is a plane wave coming from the top, angle beta.
%
% The reconstruction wave comes from the bottom, angle -beta.
%
% The real image is formed on the screen located in the plane 
% z = 2*hologramZ = 1400 mm
%
% The demo is as simple as possible. For more comprehensive show of
% CGDH Tools possibilities see other demos.
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

% Prepare the object - an image with diffuse surface
source = loadImage('image.png');
source = applyRandomPhase(source);
sourceHeight = 10e-3;
sourceWidth = 10e-3;
sourceCenter = [0, 0, 0];

sourceSize = size(source);
sourceDeltaYX = calculateDelta(sourceSize, [sourceHeight, sourceWidth]);

% Prepare position and size of the hologram
hologramSize = sourceSize;
hologramDeltaYX = sourceDeltaYX;
hologramZ = 700e-3;
hologramCenter = [0, 0, hologramZ];

% Prepare position and size of the screen for the real image observation
screenSize = sourceSize;
screenDeltaYX = sourceDeltaYX;
screenCenter = [0, 0, 2*hologramZ];

% Parameters of the reference wave
referenceAlpha = 0;
referenceBeta = getMaxDiffAngle(lambda, 2.0*hologramDeltaYX(1));
referenceDirection = getVectorFromAngles(referenceAlpha, referenceBeta);

% Parameters of the reconstruction wave
reconstructionAlpha = -referenceAlpha;
reconstructionBeta = -referenceBeta;
reconstructionDirection = getVectorFromAngles(reconstructionAlpha, reconstructionBeta);

% Propagate the source to the hologram plane
[objectWave, hologramX, hologramY] = propagate(source, sourceDeltaYX, sourceCenter, ...
  hologramSize, hologramDeltaYX, hologramCenter, ...
  lambda, '3fft', 'RayleighSommerfeldExact', 'localExact');
objectWaveIntensity = getWaveIntensity(objectWave); 
  
% Prepare the reference and the reconstruction waves 
[xx, yy] = meshgrid(hologramX, hologramY);
referenceWave = sqrt(objectWaveIntensity) * ...
  planeWave(referenceDirection, lambda, xx, yy, hologramCenter(3));
reconstructionWave = ...
  planeWave(reconstructionDirection, lambda, xx, yy, hologramCenter(3));

% Make the hologram
hologram = calculateHologram(objectWave, referenceWave, 'classical');

% Propagate hologram to the screen
[screen, screenX, screenY] = propagate(hologram .* reconstructionWave, ...
  hologramDeltaYX, hologramCenter, ...
  screenSize, screenDeltaYX, screenCenter, ...
  lambda, '3fft', 'RayleighSommerfeldExact', 'localExact');

% Display the result
displayImage(screenX*1e3, screenY*1e3, abs(screen), 'positive', 1, 'simple-screen.png');
xlabel('x [mm]');
ylabel('y [mm]');
title('Reconstructed real image');
axis('image');

% Save the figure
saveFigure('output.png', 480, 480);

