// Test of the calculation of the aliasing-free zone 
// of various complex valued functions, such as the Rayleigh-Sommerfeld 
// convolution kernel or simple spherical wave.
//
// In computer generated display holography, it is necessary to evaluate
// various special functions in the spatial (x-y) or the frequency (fx-fy)
// domain. Moreover, it is necessary to check is they are sampled properly,
// or if there is a risk of aliasing (sampling below the Nyquist limit).
//
// This demo allows to explore such functions.
// Select the function type by setting functionType.
// Adjust parameters such as lambda (wave length), z0, px or py that
// affect their calculation. You can also change the sampling distances
// that affect aliasing.
// Figure shows the real part of the function.
// Depending on parameters such as removeAliasedPart the figure shows which
// parts of the function are aliased.
// Moreover, bounds of the aliasing-free part are estimated and displayed
// as vertical and horizontal lines. If there is no aliasing, the lines
// are not drawn.
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

// Uncomment one functionType.
// Adjust the constant z0 at line after the comment "Z0 ADJUSTMENT"
// if the aliasing-free zone is too small.
// Try changing px, py at lines after the comment "PX, PY ADJUSTMENT"
// to see shifted frequency domain functions.

// functionType = 'SphericalWave';
  functionType = 'RayleighSommerfeldExact';
// functionType = 'RayleighSommerfeldSimple';
// functionType = 'FresnelXY';
// functionType = 'AngularSpectrumExact';
// functionType = 'AngularSpectrumNoEvanescent';
// functionType = 'FresnelFXFY';

// It is possible to display the calculated function as is,
// or to hide its aliased part. 
// hideFactor=0 removes it from the image completely,
// hideFactor=1 actually does not hide it at all.
removeAliasedPart = %T;
hideFactor = 0.1;


// It is also possible to draw approximate maximum coordinates
// of the area where the function is not aliased
drawLimitLines = %T;

//
// Testing conditions
//

// wavelength
lambda = 500e-9;

// The function will be evaluated at 
// (2*imageSamplesHalf+1) x (2*imageSamplesHalf+1)
// samples
imageSamplesHalf = 200;


// Determine if the function should be calculated 
// in the frequency domain (fx-fy plane)
// or in the spatial domain (x-y plane)
if (isequalString(functionType, 'SphericalWave') || ...
    isequalString(functionType, 'RayleighSommerfeldExact') || ...
    isequalString(functionType, 'RayleighSommerfeldSimple') || ...
    isequalString(functionType, 'FresnelXY'))
      spatialDomain = %T;
elseif (isequalString(functionType, 'AngularSpectrumExact') || ...
    isequalString(functionType, 'AngularSpectrumNoEvanescent') || ...
    isequalString(functionType, 'FresnelFXFY'))
      spatialDomain = %F;
else
      error(sprintf('Wrong function type: %s.', functionType));
end


// Please note that for all functions we assume x, y coordinates
// although for the angular spectrum based we should name them
// fX, fY as the function is calculated in the frequency domain.

// Z0 ADJUSTMENT
// The function takes z0 constant meaning 
// 'z coordinate of a light source'.
if (spatialDomain)
  // Try this for spatial domain functions
  z0 = 0.0006;
else
  // Try this for frequency domain functions
  z0 = 0.00006;
end

// PX, PY ADJUSTMENT
// Constants px, py are taken into account in frequency
// domain functions, they add linear phase in the exponential
// (see cgdhFunct.m). Try values about 1e-5 or so.
px = 0;
py = 0;


// Set sampling distances of the spatial or the frequency domain
if (spatialDomain)
  // Sampling of the the spatial domain
  DeltaX = 1e-6;
  DeltaY = 1e-6;
else
  // Sampling of the frequency domain is set a bit higher (factor 1.1)
  // in order to see limiting circle at 
  // fX^2 + fY^2 = 1/lambda^2
  // Note that the names of variables should be DeltaFX, DeltaFY,
  // but they are chosen as DeltaX, DeltaY in order to make the script
  // simpler.
  DeltaX = 1.1/(imageSamplesHalf*lambda);
  DeltaY = 1.1/(imageSamplesHalf*lambda);
end


// Make the samples coordinates.
// Note again that all functions work with x, y,
// although sometimes they should be named fX, fY
x = (-imageSamplesHalf:imageSamplesHalf)*DeltaX;
y = (-imageSamplesHalf:imageSamplesHalf)*DeltaY;
[xx, yy] = meshgrid(x, y);

// Actual sampling frequencies
fsX = 1/DeltaX;
fsY = 1/DeltaY;

// Limiting frequencies for the aliasing-free zone
// according to Shannon-Nyquist condition
lfxMax = fsX / 2;
lfyMax = fsY / 2;


//
// Calculate the function 'u'
// and the limits for the aliasing-free zone
//
[u, lfxRange, lfyRange, lfx, lfy] = ...
  cgdhFunct(functionType, xx, yy, [lambda, z0, px, py], [lfyMax, lfxMax]);


// For visualization: remove aliased part explicitly before normalization
if (removeAliasedPart)
  indices = (lfx > lfxMax) | (lfy > lfyMax);
  u(indices) = u(indices) * hideFactor;
end

scf(1); gcf().background = -2;
clf();
dispU = real(u);

// Normalize image
limits = getImageNormalizationParams(dispU, 'symmetric');
dispU = normalizeImage(dispU, limits);

// Colorize the aliased part
if (removeAliasedPart)
  dispURGB = zeros(size(dispU, 1), size(dispU, 2), 3);
  tmp = dispU;
  tmp(indices) = 0.1;
  dispURGB(:, :, 1) = tmp;
  dispURGB(:, :, 2) = dispU;
  dispURGB(:, :, 3) = dispU;
  dispU = dispURGB;
  clear tmp;
  clear dispURGB;
end

// Display the function
displayImage(x, y, dispU, 'auto');

// Describe axes properly
if (spatialDomain)
  xlabel('x [m]');
  ylabel('y [m]');
else
  xlabel('fx [m^-1]');
  ylabel('fy [m^-1]');
end

// Draw approximate borders of aliasing free zone  
if (drawLimitLines)
  set(gca(),'auto_clear','off');;
  lxMin = lfxRange(1);
  lxMax = lfxRange(2);
  lyMin = lfyRange(1);
  lyMax = lfyRange(2);
  
  if (lxMin > x(1))  
    // left border
    drawLine([lxMin, lxMin], [y(1), y($)], 'green',  2);
    drawString(lxMin, mean(lfyRange), sprintf(' %.3g', lxMin), ...
       'blue', 'right', 'middle');
  end
  
  if (lxMax < x($))
    // right border
    drawLine([lxMax, lxMax], [y(1), y($)], 'red',    2);
    drawString(lxMax, mean(lfyRange), sprintf(' %.3g', lxMax), ...
       'blue', 'left', 'middle');
  end

  if (lyMin > y(1))
    // bottom border
    drawLine([x(1), x($)], [lyMin, lyMin], 'blue',   2);
    drawString(mean(lfxRange), lyMin, sprintf(' %.3g', lyMin), ...
      'blue', 'center', 'top');
  end
  
  if (lyMax < y($))
    // top border
    drawLine([x(1), x($)], [lyMax, lyMax], 'yellow', 2);
    drawString(mean(lfxRange), lyMax, sprintf(' %.3g', lyMax), ...
      'blue', 'center', 'bottom');
  end
  
  set(gca(),'auto_clear','on');;
end


gca().isoview = 'on'; gca().tight_limits = 'on';
drawTitle(sprintf('Real part of function ''%s'' for z0=%.g mm, lambda=%g nm', ...
  functionType, z0*1e3, lambda*1e9));
  
// Save the figure
// saveFigure('output.png', 640, 480);
