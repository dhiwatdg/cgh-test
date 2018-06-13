// Flips a matrix (2D or 3D) upside-down. For Octave/MATLAB compatibility.
// Octave/MATLAB directly implements flipud()
//
// Inputs:
// A
// - 2D or 3D (RGB image) matrix
//
// Outputs:
// Matrix out with flipped rows (row 1 becomes last row, etc.)
function out = flipud(A)
 out = A($:-1:1,:,:);
end