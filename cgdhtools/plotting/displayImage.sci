// Displays and/or saves a greyscale image.
//
// Inputs:
// x, y
//  - Vectors with X or Y sample coordinates, just for plot annotation.
// img
//  - Real or complex matrix, image to display and/or save.
//  - Size: length(y) rows, length(x) columns.
// normalize
//  - Method to convert a real matrix to the range [0, 1] for saving the image,
//    or to convert a complex matrix to a RGB image for its display and saving.
//    See getImageNormalizationParams for additional details.
//  - For real matrices, use 
//     'positive' - 0 is displayed as black, maximum positive value as white
//     'negative' - minimum negative value is displayed as black, 0 as white
//     'minmax'   - minimum value is displayed as black, maximum value as white
//     'symmetric' - 0 is displayed as 50// gray, negative values are darker, 
//                   positive values are brighter, the limits are symmetrical
//                   around 0
//     [minValue, maxValue] - a vector of two real numbers, value minValue
//                   is displayed as black, maxValue as white
//  - For complex matrics, use 
//     'complex' - basically absolute value of a complex number, colorized to
//                 recognize the phase. Color hue goes from red (phase 0),
//                 through orange (45 degrees), yellow (90 degrees), 
//                 green (180 degrees), cyan (225 degrees), blue (270 degrees).
//                 Note that it is similar to CIELAB system, where color
//                 axes a*b* span magenta-green and yellow-blue hues.
//     'complexReIm' - real part is displayed in the red channel of a RGB image,
//                 imaginary part is displayed as the green channel,
//                 blue channel is left empty. Value 0 is displayed as
//                 color [128,128,0], negative values go between 0 and 128,
//                 positive values go between 128 and 255. The color axis 
//                 tries to show which color hue corresponds to which phase
//                 change
//     'phase'   - the phase is displayed as a grayscale image, the color axis
//                 is labeled from 0 to 360 degrees
//  - For images (RGB or real) already prepared for display, use
//     'none' - does not alter the input in any way
//  - Type 'auto' selects either 
//     'complex' for complex matrices, 
//     'positive' or 'symmetric' for real matrices (depending on the content) and
//     'none' for RGB images.
// displayImages
//  - Boolean. If set, the image is displayed. 
//  - If missing, '%T' is assumed.
// fileName
//  - String, the file name to save the image to.
//  - If equal to '' or missing, image is not saved
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
function colorbarLimits = displayImage(x, y, img, normalize, displayImages, fileName)
  // Check input arguments
  if (nargin < 3)
    error('At least x coordinates, y coordinates and the image must be provided');
  end
  if (nargin < 4)
    normalize = 'auto';
  end
  if (nargin < 5)
    displayImages = 1;
  end
  if (nargin < 6)
    fileName = '';
  end

  // Select image normalization in case of 'auto'
  if (isequalString(normalize, 'auto'))
    if (size(img, 3) == 3)
      // RGB images
      normalize = 'none';
    elseif (or(~isreal(img)))
      normalize = 'complex';
    elseif (and(img >= 0))
      normalize = 'positive';
    else
      normalize = 'symmetric';
    end
  end

  if (size(normalize, 2) == 2)
    limits = normalize;
  elseif (~isequalString(normalize, 'none') && ...
          ~isequalString(normalize, 'phase'))
    limits = getImageNormalizationParams(img, normalize);
  else
    limits = [];
  end
  
  // note: this will be overriden for normalize == 'complex' 
  // or 'complexReIm'
  colorbarLimits = limits;
  
  /*
  if (isequalFloat(limits(1), limits(2)))
    if (isequalFloat(limits(1), 0))
      limits(1) = -1;
    else
      limits(1) = -limits(1);
    end
  end
  */

  // Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = %pi
  
  // Make 'working image' for image saving and display
  if (isequalString(normalize, 'complex'))
    minVal = limits(1);
    maxVal = limits(2);
    diffVal = maxVal - minVal;
    workingImg = zeros(size(img, 1), size(img, 2), 3);

    // extract 'positiveness' and 'negativeness' of the parts
    normImg = img / maxVal;
    rpPart = max(0, real(normImg));
    rnPart = max(0, -real(normImg));
    ipPart = max(0, imag(normImg));
    inPart = max(0, -imag(normImg));
    
    // color for real positive: [1, 0, 0];
    // color for real negative: [0, 1, 0];
    // color for imag positive: [1, 1, 0];
    // color for imag negative: [0, 0, 1];
    
    // make initial color hue (see the colors above)
    workingImg(:,:,1) = rpPart + ipPart;
    workingImg(:,:,2) = rnPart + ipPart;
    workingImg(:,:,3) = inPart;
    d = max(1e-6, workingImg(:,:,1), workingImg(:,:,2), workingImg(:,:,3));
    workingImg(:,:,1) = workingImg(:,:,1) ./ d;
    workingImg(:,:,2) = workingImg(:,:,2) ./ d;
    workingImg(:,:,3) = workingImg(:,:,3) ./ d;
    
    // darken the color according to absolute value
    absImg = abs(img);
    absImg = absImg / max(max(absImg));
    
    workingImg(:,:,1) = workingImg(:,:,1) .* absImg;
    workingImg(:,:,2) = workingImg(:,:,2) .* absImg;
    workingImg(:,:,3) = workingImg(:,:,3) .* absImg;
    // end of 'complex'
  elseif (isequalString(normalize, 'complexReIm'))
    minVal = limits(1);
    maxVal = limits(2);
    diffVal = maxVal - minVal;
    workingImg = zeros(size(img, 1), size(img, 2), 3);
    workingImg(:,:,1) = (real(img)-minVal)/diffVal;
    workingImg(:,:,2) = (imag(img)-minVal)/diffVal;
  elseif (isequalString(normalize, 'phase'))
    workingImg = wrapTo2Pi(angle(img)) / (2*piNumber);
  elseif (isequalString(normalize, 'none'))
    workingImg = img;  
  else
    workingImg = normalizeImage(img, limits);
  end

  // Save the image
  if (~isequalString(fileName, ''))
    imwrite(flipud(workingImg), fileName);
  end
  
  if (displayImages)
    if (isequalString(normalize, 'complex') || ...
        isequalString(normalize, 'complexReIm') || ...
        isequalString(normalize, 'phase') || ...
        isequalString(normalize, 'none'))
      if (isequalString(normalize, 'complex'))
        Matplot1(flipud(workingImg), [x(1), y(1), x($), y($)]);
        gcf().color_map = colormapComplex();
      elseif (isequalString(normalize, 'complexReIm'))
        Matplot1(flipud(workingImg), [x(1), y(1), x($), y($)]);
        gcf().color_map = colormapComplexReIm();
      elseif (isequalString(normalize, 'phase'))
        Matplot1(flipud(workingImg*256), [x(1), y(1), x($), y($)]);
        gcf().color_map = graycolormap(256);
      end
      colorbarLimits = [0, 360];
    else
      if (size(img, 3) == 1)  // grayscale image
        colmapSize = 256;
      else                    // RGB image
        colmapSize = 1;
      end
      Matplot1(flipud(workingImg) * colmapSize, [x(1), y(1), x($), y($)]);
      gcf().color_map = graycolormap(colmapSize);
    end
    gca().data_bounds = [x(1), y(1); x($), y($)];
    gca().axes_visible = ['on', 'on']
  end
end
