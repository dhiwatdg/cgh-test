// Attempt to convert a real image to the range [0, 1] according to given limits.
//
// Inputs:
// img
//  - Real matrix
// limits
//  - Vector [min, max].
//
// Outputs: 
// out
//  - Real matrix (img - min) / (max - min)
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
function out = normalizeImage(img, limits)
  out = (img - limits(1)) / (limits(2) - limits(1));
end	
