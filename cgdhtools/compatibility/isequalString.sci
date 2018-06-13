// Compare two strings. 
//
// Inputs:
// a, b
//  - strings
// 
// Outputs:
// %T if case strings s1 and s2 are equal
// %F otherwise
//
// NOTES
// This function is intended as a wrapper with more logical name than
// strcmp(), as behaviour of strcmp() differs in Matlab/Octave and Scilab/C
function out = isequalString(s1, s2)
 if (type(s1) == 10 && type(s2) == 10)
   out = ~strcmp(s1, s2);
 else
   out = %F;
 end
end