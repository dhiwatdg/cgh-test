% Saves the intensity (amplitude squared) image. 
%
% Inputs: 
% imageMatrix
%  - complex matrix containing an optical field 
% fileName
%  - string, should contain a suffix such as '.png'
%
% Outputs:
% none
%
% NOTES:
% See the note in saveAmplitude().
function saveIntensity(imageMatrix, fileName)
  tmp = real(imageMatrix .* conj(imageMatrix));  % ensure complex -> real conversion
  tmp = tmp / max(max(tmp));
  imwrite(flipud(tmp), fileName);
end
