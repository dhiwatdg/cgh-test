% Returns array size necessary to calculate cyclic convolution of vectors
% of length a and b. (Note that anything larger than a+b-1 is OK.)
%
% Inputs:
% a, b
%  - Vector lengths or matrix sizes of signals for convolution
%
% Outputs:
%  - Vector length or matrix size of zero padded signals for convolution
%    calculation.
%
% NOTES
% TODO: Instead of a + b - 1, find any larger integer suitable for efficient
%       FFT calculation.
% 
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
function k = convolutionSize(a, b)
	k = a + b - 1;
end