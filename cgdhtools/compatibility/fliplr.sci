// Flips a matrix (2D or 3D) left-right. For Octave/MATLAB compatibility.
// Octave/MATLAB directly implements fliplr()
//
// Inputs:
// A
// - 2D or 3D (RGB image) matrix
//
// Outputs:
// Matrix out with flipped columns (column 1 becomes last column, etc.)
function out = fliplr(A)
 out = A(:,$:-1:1,:);
end