// Makes a colormap for easier reading of images of complex matrices
// when displaying a complex matrix M using displayImage(x, y, M, 'complexReIm').
// Here, the real part is mapped to the red channel, the imaginary part to the
// green channel, the blue channel is zero.
// The complex values are scaled and shifted in such a way that 0 gets color 
// [0.5, 0.5, 0] (dark yellow).
// Positive real values (phase 0 degrees)  shift the color towards orange.
// Positive imaginary values (90 degrees)  shift the color towards warm green.
// Negative real values (180 degrees)      shift the color towards cold green.
// Negative imaginary values (270 degrees) shift the color towards dark red.
// The colormap cycles through all phases from 0 to 360 degrees (inclusive).
//
// Inputs:
// colormapSize
//  - Approximate size of the colormap, it is rounded to a multiple of 8 plus 1
//  - Optional, default colormap size is 249 colors.
//
// Outputs:
// The colormap, each row is a RGB color specification.
//
// NOTES
// The function displayImage sets this color map automatically for 
// a 'complexReIm' image.
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
function out = colormapComplexReIm(colormapSize)
  if (nargin < 1)
    n = 32;
  else
    n = max(2, ceil(colormapSize / 8));
  end
  
  out = zeros(8*(n-1)+1, 3);
  
  // from RG   1.0 0.5
  // to   RG   1.0 1.0
  s = 1;
  out(s:s+n-1, 1) = 1; out(s:s+n-1, 2) = linspace(0.5, 1, n)';

  // to   RG   0.5 1.0
  s = s + n - 1;
  out(s:s+n-1, 2) = 1; out(s:s+n-1, 1) = linspace(1, 0.5, n)';

  // to   RG   0.0 1.0
  s = s + n - 1;
  out(s:s+n-1, 2) = 1; out(s:s+n-1, 1) = linspace(0.5, 0, n)';

  // to   RG   0.0 0.5
  s = s + n - 1;
  out(s:s+n-1, 1) = 0; out(s:s+n-1, 2) = linspace(1, 0.5, n)';

  // to   RG   0.0 0.0
  s = s + n - 1;
  out(s:s+n-1, 1) = 0; out(s:s+n-1, 2) = linspace(0.5, 0, n)';

  // to   RG   0.5 0.0
  s = s + n - 1;
  out(s:s+n-1, 2) = 0; out(s:s+n-1, 1) = linspace(0, 0.5, n)';

  // to   RG   1.0 0.0
  s = s + n - 1;
  out(s:s+n-1, 2) = 0; out(s:s+n-1, 1) = linspace(0.5, 1, n)';

  // to   RG   1.0 0.5 
  s = s + n - 1;
  out(s:s+n-1, 1) = 1; out(s:s+n-1, 2) = linspace(0, 0.5, n)';
end