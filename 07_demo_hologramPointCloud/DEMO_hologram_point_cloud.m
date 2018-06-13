% Demonstration of calculation of a hologram of a point cloud.
% First, a hologram of a point cloud is calculated.
% Second, its reconstruction is calculated and displayed.
%
% The demo allows to watch just the result of the reconstruction, or
% all steps of the calculation if we set
%   displayIntermediate = true;
% 
%
% The demo allows to compare two methods of the object wave calculation:
% 1. Direct propagation to the hologram plane.
%    This is the simplest method of computer generated display holography.
%    It is very suitable for parallelization on both CPU, GPU or other hardware.
% 2. Aliasing-free propagation to the wavefront recording plane (WRP),
%    subsequent propagation to the hologram plane. The method was introduced
%    in [Shimobaba09] as a faster alternative of the direct method.
%    The basic idea is simple. In the direct method we usually assume that
%    the hologram plane is located far away from the point cloud. Thus,
%    each point illuminates each sample of the hologram. This leads to
%    excessive calculation times.
%    If we place an auxiliary plane (called WRP) close to the point cloud,
%    each point illuminates just a small area of the WRP. Thus, the propagation
%    of light from the point cloud to the WRP is substantially faster than
%    to the hologram plane. Light from the WRP can be then propagated to the
%    hologram plane using standard FFT-based propagation algorithms that run in 
%    O(N log N) time. Again, this propagation is substantially faster than
%    the direct propagation to the hologram plane.
%    Hint: select 
%      sceneType = 'fewPoints';
%      displayIntermediate = true;
%    to see the phasor in the WRP plane. Tweak sceneDepth to see what area of
%    the WRP is affected by the point sources.
%
% The demo also allows to compare various methods of hologram encoding
% - classical, i.e. 
%     hologram = abs(objectWave + referenceWave).^2
% - bipolar intensity, i.e. 
%     hologram = real(objectWave .* conj(referenceWave))
% - shifted bipolar intensity, i.e. the bipolar intensity with additional
%   offset that makes the values positive
% - no hologram calculation at all, i.e. the reconstruction is calculated
%   directly as backpropagation of the object wave
%   (can be also thought as "a full complex hologram")
% Other hologram encoding methods (see DEMO_hologram_real_image) can be easily
% incorporated as well.
%
%
% The script 
% 1. defines the recording geometry
% 2. calculates the object wave in the hologram plane,
% 3. optionally calculates the hologram (interference with a reference wave)
% 4. reconstructs the real image (either from the hologram, or the object wave)
%
%
% REFERENCES:
%
% [Shimobaba09] Shimobaba, T., Masuda, N., Ito, T., "Simple and fast calculation 
%      algorithm for computer-generated hologram with wavefront recording 
%      plane", Opt. Lett. 34(10), 3133-3135 (2009).
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
%  CGDH TOOLS
%  Petr Lobaz, lobaz@kiv.zcu.cz
%  Faculty of Applied Sciences, University of West Bohemia 
%  Pilsen, Czech Republic
%
%  Check http://holo.zcu.cz for more details and scripts.
%
% ---------------------------------------------


%
% 1. Initialization and recording geometry definition
% ALL DIMENSIONS ARE IN METRES
%
addpath(genpath('../cgdhtools'));

% Wavelength, a green DPSS laser
lambda = 532e-9;

% Scilab compatibility
imagUnit = sqrt(-1);
piNumber = pi;

% Select the scene type.
%
% sceneType = 'fewPoints';
sceneType = 'wireframeObjects';

% Select the calculation method
%
% calculationMethod = 'direct';
calculationMethod = 'WRP';

% Display just the reconstruction, or intermediate results as well?
displayIntermediate = false;

% Select the method of hologram encoding
% The option 'none' does not make the hologram at all. It just calculates
% the object wave and reconstructs it by back propagation
%
hologramMethod = 'classical';
% hologramMethod = 'bipolar';
% hologramMethod = 'shiftedBipolar';
% hologramMethod = 'none';

% Reference : object wave ratio for hologram recording
hologramRORatio = 3;

% Hologram (or the object wave) dimensions
hologramHeight = 4e-3;
hologramWidth  = 4e-3;

% The hologram (or the object wave plane) is located in z = hologramZ 
% centered at x = 0, y = 0
hologramZ = 40e-3;
hologramCenter = [0, 0, hologramZ];

% Sampling distance in both xy axes
Delta = 10e-6 / 2;

%
% Definition of the scene.
% The scene is located around z = -100 mm.
%
% The real image will be then reconstructed in
% z = reconstructionZ
reconstructionZ = -100e-3;

% The wavefront recording plane (if used) is located in z = wrpZ
wrpZ = -90e-3;

% Define the scene
switch (sceneType)
  case 'fewPoints'
    % Define a point cloud located near z = -100 mm
    % As seen from the camera, it looks like a pattern
    %     *      (closer to the camera)
    %     *      (at z = -100 mm)
    %   *        (farther from the camera)
    sceneDepth = 6e-3;
    sceneWidth = 2e-3;
    sceneHeight = 2e-3;
    sceneCenterZ = -100e-3;
    points =  [0,  1,  1;
               0,  0,  0
              -1, -1, -1];
    points(:, 1) = points(:, 1) * sceneWidth / 2;
    points(:, 2) = points(:, 2) * sceneHeight / 2;
    points(:, 3) = points(:, 3) * sceneDepth / 2 + sceneCenterZ;
    amplitudes = ones(1, size(points, 1));              
  case 'wireframeObjects'
    % Scene composed of many points simulating three wireframe objects  
    object1Z = -100e-3;
    object2Z = object1Z + 2e-3;
    object3Z = object1Z - 2e-3;

    % Wireframe objects will be composed of points separated by DeltaLine
    DeltaLine = 30e-6;

    object1 = generateTetrahedron(0.5e-3, DeltaLine);
    object1 = pointsRotateXYZ(object1, -20*piNumber/180, 5*piNumber/180, 0);
    object1 = pointsTranslateXYZ(object1, 0, 0, object1Z);

    object2 = generateCube(0.5e-3, DeltaLine);
    object2 = pointsRotateXYZ(object2, -40*piNumber/180, 15*piNumber/180, 10*piNumber/180);
    object2 = pointsTranslateXYZ(object2, -0.8e-3, -0.7e-3, object2Z);

    object3 = generateOctahedron(0.5e-3, DeltaLine);
    object3 = pointsRotateXYZ(object3, -10*piNumber/180, 15*piNumber/180, 0);
    object3 = pointsTranslateXYZ(object3, 0.8e-3, 0.8e-3, object3Z);

    points = [object1; object2; object3];

    % Points have amplitude 1, random phase
    rand ('seed', 1);
    amplitudes = exp(imagUnit * 2 * piNumber * rand(size(points, 1), 1));
end

%
% END OF ADJUSTABLE PARAMETERS
%

%
% 2. The object wave calculation
%

pointsCount = size(points, 1);

fprintf('\nThe object wave calculation, %d points...\n', pointsCount);
flushOutput();

% Initialize useful constants.

% Calculate number of samples in axes xy
samplesX  = calculateSamples(hologramWidth, Delta);
samplesY  = calculateSamples(hologramHeight, Delta);
hologramSize = [samplesY, samplesX];

% XY coordinates of the hologram samples
[hologramX, hologramY] = getXYVectorFromCenter(hologramSize, Delta, hologramCenter);
[xx, yy] = meshgrid(hologramX, hologramY);

% Actual calculation of the object wave 
switch (calculationMethod)
  case 'direct'
    objectWave = pointCloudPropagate(points, amplitudes, lambda, xx, yy, hologramZ);
  case 'WRP'
    wrpWave = pointCloudPropagateNoAliasing(points, amplitudes, lambda, xx, yy, wrpZ);
    objectWave = propagate(wrpWave, Delta, [0, 0, wrpZ], ...
      hologramSize, Delta, hologramCenter, ...
      lambda, '3fft', 'RayleighSommerfeldExact', 'localExact', 0, '');
end

% Display
if (displayIntermediate)
  if (isequalString(calculationMethod, 'WRP'))
    clf();
    limits = displayImage(hologramX * 1e3, hologramY * 1e3, wrpWave);
    drawTitle('Object wave in the WRP plane (complex)');
    xlabel('x [mm]');
    ylabel('y [mm]');
    axis('image');
    drawColorbar(limits);
    waitForKey('Press ENTER to continue.');
    fprintf('\n');
  end

  clf();
  limits = displayImage(hologramX * 1e3, hologramY * 1e3, objectWave);
  drawTitle('Object wave in the hologram plane (complex)');
  xlabel('x [mm]');
  ylabel('y [mm]');
  axis('image');
  drawColorbar(limits);
  waitForKey('Press ENTER to continue.');
end

%
% 3. The hologram calculation (if required)
%

if (~isequalString(hologramMethod, 'none'))

  fprintf('\nThe hologram calculation: the reference wave...\n');

  % Direction cosines of the plane reference wave.
  % Make it as steep as possible, but avoid aliasing.
  referenceAlpha = 0;
  referenceBeta = getMaxDiffAngle(lambda, 2.0*Delta);
  referenceDirection = ...
    getVectorFromAngles(referenceAlpha, referenceBeta);

  % The reference wave
  objectWaveIntensity = getWaveIntensity(objectWave); 
  referenceWave = sqrt(hologramRORatio) * sqrt(objectWaveIntensity) * ...
    planeWave(referenceDirection, lambda, xx, yy, hologramZ);

  % Display
  if (displayIntermediate)
    clf();
    limits = displayImage(hologramX * 1e3, hologramY * 1e3, referenceWave);
    drawTitle(sprintf('Reference wave (complex), beta = %.2f deg', referenceBeta * 180/piNumber));
    xlabel('x [mm]');
    ylabel('y [mm]');
    axis('image');
    drawColorbar(limits);
    waitForKey('Press ENTER to continue.');
  end

  % The hologram calculation
  fprintf('\nThe hologram calculation: the hologram...\n');
  hologram = calculateHologram(objectWave, referenceWave, hologramMethod);

  % Display
  if (displayIntermediate)
    clf();
    limits = displayImage(hologramX * 1e3, hologramY * 1e3, hologram);
    drawTitle(sprintf('Hologram (%s method)', hologramMethod));
    xlabel('x [mm]');
    ylabel('y [mm]');
    axis('image');
    drawColorbar(limits);
    waitForKey('Press ENTER to continue.');
  end
end


%
% 4. Reconstruction of the hologram or the object wave
%  

if (isequalString(hologramMethod, 'none'))
  fprintf('\nNumerical propagation of the original optical field.\n');
  optfield = objectWave;
  imageTitle = 'Reconstruction from the original object wave';
else
  fprintf('\nNumerical propagation of the hologram.\n');
  optfield = hologram .* referenceWave;
  imageTitle = ...
    sprintf('Reconstruction of the hologram, method %s, ref/obj ratio %.1f', ...
      hologramMethod, hologramRORatio);
end

reconstruction = propagate(optfield, Delta, ...
  hologramCenter, ...
  hologramSize, Delta, ...
  [0, 0, reconstructionZ], ...
  lambda, '3fft', 'RayleighSommerfeldExact', 'localExact', 0, '');

% Display
clf();
displayImage(hologramX * 1e3, hologramY * 1e3, abs(reconstruction));
drawTitle(imageTitle);
xlabel('x [mm]');
ylabel('y [mm]');
axis('image');
% waitForKey('Press ENTER to finish the script.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END OF THE SCRIPT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
