// Calculates intensity of the provided complex matrix.
// Intensity I is defined as I = |U|^2, where U is light phasor (complex 
// amplitude). 
//
// Inputs:
// wave
//  - complex matrix, each sample is a light phasor
//  - It is assumed that absolute value of the sample
//
// Outputs:
// meanIntensity  - mean intensity in the wave matrix
// maxIntensity   - maximum intensity in the wave matrix
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
function [meanIntensity, maxIntensity] = getWaveIntensity(wave)
  intensity = real(wave .* conj(wave));
  meanIntensity = mean(mean(intensity));
  if (argn(1) == 2)
    maxIntensity = max(max(intensity));
  end
end  