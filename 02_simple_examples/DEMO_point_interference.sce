// Simple demonstration of CGDH Tools: 
// Interference pattern of several point light sources on the screen.
//
// There are 8 point light sources, wavelength lambda = 532 nm, located on a
// circle with radius 10 um in the plane z = 0.
//
// The screen is located in the plane z = 200 um, its size is 100 x 100 um.
//
// Figure 1 displays complex amplitude of light. Brightness of a pixel 
// corresponds to light amplitude, color corresponds to light phase.
// To display light amplitude, change the line with 'displayImage'
//
// The demo is as simple as possible. For more comprehensive show of
// CGDH Tools possibilities see other demos.
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

// Prepare the object - point sources
N = 8;
t = ((0:N-1)/N * 2*piNumber)';
points = [cos(t), sin(t), zeros(N, 1)] * 10e-6;
pointAmplitudes = ones(1, size(points, 1));

// Prepare position and size of the hologram
screenSize = [200, 200];
screenDelta = 0.25e-6;
screenZ = 200e-6;
screenCenter = [0, 0, screenZ];

// Object wave
[screenX, screenY] = getXYVectorFromCenter(screenSize, screenDelta, screenCenter);
[xx, yy] = meshgrid(screenX, screenY);
screen = pointCloudPropagate(points, pointAmplitudes, lambda, xx, yy, screenZ);

// Display the result
limits = displayImage(screenX*1e6, screenY*1e6, screen);

// Use this to display light amplitude:
// limits = displayImage(screenX*1e6, screenY*1e6, abs(screen));

// Use this to display light intensity.
// Note that the display is misleading. If you want to properly display 
// light intensity, the values should be gamma-corrected (see e.g. 
// 'Gamma correction' on Wikipedia), i.e. one should use
//   intensity.^(1/2.2)
// In our case this leads to
//   (abs(screen).^2).^(1/2.2)
//   = abs(screen).^(2.0/2.2)
//   = abs(screen).^0.909
//   ~ abs(screen)
// which means that displaying the absolute value is more meaningful.
// However, if you are interested in exact intensity values, you shoud use
// proper intensity, i.e. abs(screen).^2
//
// limits = displayImage(screenX*1e6, screenY*1e6, abs(screen).^2);

// Annotate
xlabel('x [um]');
ylabel('y [um]');
title(sprintf('Object wave on the screen z = %.0f um (complex value)', screenZ * 1e6));
drawColorbar(limits);
gca().isoview = 'on'; gca().tight_limits = 'on';

