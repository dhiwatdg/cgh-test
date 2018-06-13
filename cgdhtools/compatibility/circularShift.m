% 2D circular shift in a matrix
%
% Wrapper for the Octave/MATLAB function circshift
% (for Scilab compatibility)
%
% Inputs:
% m
%  - 2D matrix
% rowShift, colShift
%  - circular shift in rows and columns
%  - row 1 becomes row '1+rowShift'
%  - column 1 becomes column '1+colShift' 
%
% Outputs:
% modified matrix out
%
% NOTES
% The .m and .sci files are completely independent
function out = circularShift(m, rowShift, colShift)
  out = circshift(m, [rowShift, colShift]);
end