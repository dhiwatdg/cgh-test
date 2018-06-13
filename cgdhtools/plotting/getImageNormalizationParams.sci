// Gets bounds for image display normalization.
//
// Inputs:
// img 
//  - real matrix (grayscale image)
//  - or complex matrix (then, only 'complex' should be used)
// normalize
//  - String, one of following:
//    'positive'   : limits = [0, max]
//    'negative'   : limits = [min, 0]
//    'minmax'     : limits = [min, max]
//    'symmetric'  : limits = [-max, max]
//    'complex'    : limits = [-max, max], max is the maximum value in re and im
//    'complexReIm': limits = [-max, max], max is the maximum value in re and im
//    ''           : limits = [0, 1]
//
// Outputs:
// limits
//  - A vector of length 2 intended as an input to the function 
//    normalizeImage
//
// NOTES
// Intended usage converts the image 'img' to the range [0, 1]
//   limits = getImageNormalizationParams(img, normalize);
//   normalizeImage(img, limits);
// The image normalization is used in displayImage function.
// There is no need to call it directly.
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
function limits = getImageNormalizationParams(img, normalize)
  if (isequalString(normalize, 'positive'))
    minValue = 0;
    maxValue = max(max(img));
    if (maxValue <= 0)
      warning('""positive"" image has no positive part, setting maxValue to 1');
      maxValue = 1;
    end
  elseif (isequalString(normalize, 'negative'))
    minValue = min(min(img));
    maxValue = 0;
    if (minValue >= 0)
      warning('""negative"" image has no negative part, setting minValue to -1');
      minValue = -1;
    end
  elseif (isequalString(normalize, 'minmax'))
    minValue = min(min(img));
    maxValue = max(max(img));
    if (isequalFloat(minValue, maxValue))
      warning('""minmax"" image is flat, resetting maxValue and minValue');
      if (isequalFloat(minValue, 0))
        maxValue = 1;
        minValue = -1;
      else
        maxValue = 2*minValue;
        minValue = 0
      end
    end
  elseif (isequalString(normalize, 'symmetric'))
    mn = abs(min(min(img)));
    mx = abs(max(max(img)));
    if (mn > mx) 
      mx = mn; 
    end
    minValue = -mx;
    maxValue = mx;
    if (minValue == 0)
      warning('""symmetric"" image is zero, setting maxValue to 1');
      maxValue = 1;
    end
  elseif (isequalString(normalize, 'complex') || ...
          isequalString(normalize, 'complexReIm'))
    rmn = abs(min(min(real(img))));
    rmx = abs(max(max(real(img))));
    if (rmn > rmx) 
      rmx = rmn; 
    end
    imn = abs(min(min(imag(img))));
    imx = abs(max(max(imag(img))));
    if (imn > imx) 
      imx = imn; 
    end
    if (imx > rmx)
      mx = imx;
    else
      mx = rmx;
    end
    minValue = -mx;
    maxValue = mx;      
    if (minValue == 0)
      warning('""complex"" image is zero, setting maxValue to 1');
      maxValue = 1;
    end
  else
    minValue = 0;
    maxValue = 1;
  end
  limits = [minValue, maxValue];
end  
