// Inverse 2D FFT. For Octave/MATLAB compatibility.
// Octave/MATLAB directly implements ifft2()
function out = ifft2(m)
  out = conj(fft2(conj(m))) / prod(size(m));
end
