// Calculate a vector from angles to X and Y axes
//
// Inputs:
// alpha, beta
//  - scalars, angles in radians
//  - alpha is the angle between the output vector and X asis minus pi/2
//  - beta is the same, but for Y axis
//  - alpha = 0, beta = 0      results to vector [0, 0, +1]
//  - alpha = -pi/2, beta = 0  results to vector [+1, 0, 0]
//  - alpha = +pi/2, beta = 0  results to vector [-1, 0, 0]
// signZ
//  - signum of the Z coordinate of the output vector
//  - set +1 for positive, -1 for negative
//  - vectors with opposite signZ are opposite to each other
//
// Outputs:
// unit vector [x, y, z]
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
function out = getVectorFromAngles(alpha, beta, signZ)
  // Scilab compatibility
  piNumber = %pi

  if (nargin < 3)
    signZ = 1;
  elseif (signZ == 0)
    signZ = 1;
  end
  ca = cos(piNumber/2 + alpha);
  cb = cos(piNumber/2 + beta);
  out = sign(signZ) * [ca, cb, sqrt(abs(1 - ca*ca - cb*cb))];  // abs to ensure positive value
end