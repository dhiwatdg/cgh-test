// Saves a bipolar real matrix as an image. 
// The matrix is saved so that the value 0 is represented as mid-gray.
// Intended for saving real/imaginary part of a complex matrix.
//
// Inputs: 
// imageMatrix
//  - a real matrix
// fileName
//  - string, should contain a suffix such as '.png'
//
// Outputs:
// none
function saveComplexPart(imageMatrix, fileName)
  norm1 = max(max(imageMatrix));
  norm2 = -min(min(imageMatrix));
  norm = max(norm1, norm2);
  tmp = 0.5 * imageMatrix / norm + 0.5;
  imwrite(flipud(tmp), fileName);
end  
