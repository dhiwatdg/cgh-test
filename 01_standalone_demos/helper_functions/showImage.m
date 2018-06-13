% Display a matrix as an image
%
% Inputs:
% x, y
%  - coordinates of matrix cells (image samples), used for proper axis scale
% img
%  - 2D matrix of real numbers
% titleString
%  - string used as an image title
%
% Outputs:
% none
%
% NOTES:
% The .m and .sci files are completely independent
function showImage(x, y, img, titleString)
  convertMtoMM = 1e3;
  imagesc(x * convertMtoMM, y * convertMtoMM, img);
  set(gca, 'YDir', 'normal');
  title(titleString);
  xlabel('x [mm]');
  ylabel('y [mm]');
  axis('image');
end