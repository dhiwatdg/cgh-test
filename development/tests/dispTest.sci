function dispTest(img, normParam, fileName)
  if (or(~isreal(img)))
    imgString = 'complex';
  else
    imgString = 'real';
  end
  
  if (nargin < 3)
    fileName = '';
  end
  
  x = 1:size(img, 2);
  y = 1:size(img, 1);
  
  clf();

  if (nargin < 2)
    if (isequalString(fileName, ''))
      limits = displayImage(x, y, img);
    else
      limits = displayImage(x, y, img, 'auto', 1, fileName);
    end
    normString = 'no parameters';
  else
    if (isequalString(fileName, ''))
      limits = displayImage(x, y, img, normParam);
    else
      limits = displayImage(x, y, img, normParam, 1, fileName);
    end
    if (size(normParam, 1) == 1 && size(normParam, 2) == 2)
      normString = mat2str(normParam);
    else
      normString = normParam;    
    end
  end
  
  gca().isoview = 'on'; gca().tight_limits = 'on';
  drawColorbar(limits);
  waitForKey(sprintf('%s, %s (Press ENTER to continue)', imgString, normString));
end