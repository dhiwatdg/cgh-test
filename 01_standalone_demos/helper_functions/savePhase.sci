// Saves the phase of a complex matrix as an image. 
//
// Inputs: 
// imageMatrix
//  - complex matrix containing an optical field 
// fileName
//  - string, should contain a suffix such as '.png'
//
// Outputs:
// none
function savePhase(imageMatrix, fileName)
  tmp = pmodulo(angle(imageMatrix), 2*%pi);
  tmp = tmp / (2*%pi);
  imwrite(flipud(tmp), fileName);
end
