// Display a matrix as an image
//
// Inputs:
// x, y
//  - coordinates of matrix cells (image samples), used for proper axis scale
// img
//  - 2D matrix of real numbers
// titleString
//  - string used as an image title
//
// Outputs:
// none
//
// NOTES:
// The .m and .sci files are completely independent
function showImage(x, y, img, titleString)
  clf();
  imgMax = max(max(img));
  imgMin = min(min(img));
  img = (img - imgMin)/(imgMax - imgMin);
  convertMtoMM = 1e3;
  colormapSize = 256;
  Matplot1(flipud(img) * colormapSize, [x(1), y(1), x($), y($)] * convertMtoMM); 
  gcf().color_map = graycolormap(colormapSize);
  gca().data_bounds = [x(1), y(1); x($), y($)] * convertMtoMM;
  gca().axes_visible = ['on', 'on']
  title(titleString);
  xlabel('x [mm]');
  ylabel('y [mm]');
  gca().isoview = 'on';
end
