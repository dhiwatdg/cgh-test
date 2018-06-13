// Makes a colormap for easier reading of images of complex matrices
// when displaying a complex matrix M using displayImage(x, y, M, 'complex').
// Here, the color for pure real numbers shifts from red (positive) to
// green (negative). For pure imaginary numbers, the color shifts from
// yellow (positive) to blue (negative). 
// Thus, colors change according to phase:
// 0 degrees   - red
// 45 degrees  - orange
// 90 degrees  - yellow
// 180 degrees - green
// 225 degrees - cyan
// 270 degrees - blue
// The colormap cycles through all phases from 0 to 360 degrees (inclusive).
//
// Inputs:
// colormapSize
//  - Size of the colormap
//  - Optional, default colormap size is 256 colors.
//
// Outputs:
// The colormap, each row is a RGB color specification.
//
// NOTES
// The function displayImage sets this color map automatically for a 'complex' 
// image.
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
function out = colormapComplex(colormapSize)
  if (nargin < 1)
    colormapSize = 256;
  end
  
  // Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = %pi
  
  // Base colormap on a unit circle in the complex plane
  phasor = exp(imagUnit * 2 * piNumber * linspace(0, 1, colormapSize));
  
  // Get coefficients how much a real or imaginary part is positive or negative
  // For example, number 1 + 0.5i is fully real positive (1), 
  // not real negative (0), half imag. positive (0.5), not imag. negative (0)
  rpPart = max(0, real(phasor));
  rnPart = max(0, -real(phasor));
  ipPart = max(0, imag(phasor));
  inPart = max(0, -imag(phasor));
  
  // Define base colors
  // These must be consistent with the colorization method used in displayImage!
  colorRP = [1, 0, 0];
  colorRN = [0, 1, 0];
  colorIP = [1, 1, 0];
  colorIN = [0, 0, 1];
  
  // Color tone is a linear combination of base colors
  out = rpPart' * colorRP + ...
        rnPart' * colorRN + ...
        ipPart' * colorIP + ...
        inPart' * colorIN;
        
  // Normalize colors so that maximum value in a single row is 1
  out = out ./ repmat(max(out, 'c'), 1, 3);
end
