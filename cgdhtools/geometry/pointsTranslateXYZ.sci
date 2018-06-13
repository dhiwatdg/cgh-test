// Translates a point cloud.
//
// Inputs:
// points
//  - Matrix of 3-D points, each row makes a (x, y, z) point
// x, y, z
//  - Translation vector
//
// Outputs:
// out
//  - Matrix of 3-D points, each row makes a (x, y, z) point
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
function out = pointsTranslateXYZ(points, x, y, z)
  out = [points(:, 1) + x, points(:, 2) + y, points(:, 3) + z];
end