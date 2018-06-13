% General matrix shift before FFT.
%
% It is assumed that an optical field of size M x N samples
% is being propagated to an optical field of size P x Q samples.
% FFT-based convolution must thus operate in arrays
% of size (M + P - 1) x (N + Q - 1) samples.
% If such an array size is uncomfortable (e.g. prime), it is
% certainly possible to increase P, Q to whatever number.
%
% This function shifts, e.g., kernel defined for zero-based
% indices for indices (1-M)..(P-1) and (1-N)..(Q-1)
% such that index [0,0] is shifted to row=1, col=1 position
%
% Intended use:
% kernelFXFY = genfftshiftPost(fft2(genfftshiftPre(kernelXY, m, n)), m, n);
%
% ---------------------------------------------
%
%  CGDH TOOLS
%  Petr Lobaz, lobaz@kiv.zcu.cz
%  Faculty of Applied Sciences, University of West Bohemia 
%  Pilsen, Czech Republic
%
%  Check http://holo.zcu.cz for more details and scripts.
%
% ---------------------------------------------
function out = genfftshiftPre(in, m, n)
  out = circularShift(in, -n+1, -m+1);
end
