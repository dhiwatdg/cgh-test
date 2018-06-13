// Saves the amplitude image. 
//
// Inputs: 
// imageMatrix
//  - complex matrix containing an optical field 
// fileName
//  - string, should contain a suffix such as '.png'
//
// Outputs:
// none
//
// NOTES:
// As a coincidence, the amplitude image can be also interpreted as an 
// almost properly saved gamma corrected intensity image. Thus, the 
// amplitude image looks like a properly displayed intensity image. 
// Explanation: a pixel of a common grayscale image should encode its 
// intensity I (measured in watt/m^2). Due to historical reasons, a common 
// display changes a value V stored in a pixel to light intensity V^2.2. 
// Thus, the pixel should actually store the value I^(1/2.2). It is called 
// gamma coding. Amplitude is just I^(1/2), which means it is almost the 
// same as a properly gamma encoded intensity I. 
function saveAmplitude(imageMatrix, fileName)
  tmp = real(imageMatrix .* conj(imageMatrix));  // ensure complex -> real conversion
  tmp = tmp .^ 0.5;
  tmp = tmp / max(max(tmp));
  imwrite(flipud(tmp), fileName);
end
