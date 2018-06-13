% Rotates a point cloud aroud X, Y, Z axes.
%
% Inputs:
% points
%  - Matrix of 3-D points, each row makes a (x, y, z) point
% angleX, angleY, angleZ
%  - Rotation angles (in radians)
%
% Outputs:
% out
%  - Matrix of 3-D points, each row makes a (x, y, z) point
%
% NOTES
%  - Right-handed coordinate system assumed.
%  - Rotations are applied in the order X first, Y, Z last.
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
function out = pointsRotateXYZ(points, angleX, angleY, angleZ)
  m = eye(3, 3);
  if (angleX ~= 0)
    c = cos(angleX);
    s = sin(angleX);
    m = m * [1, 0, 0; 0, c, s; 0, -s, c];
  end
  if (angleY ~= 0)
    c = cos(angleY);
    s = sin(angleY);
    m = m * [c, 0, -s; 0, 1, 0; s, 0, c];
  end
  if (angleZ ~= 0)
    c = cos(angleZ);
    s = sin(angleZ);
    m = m * [c, s, 0; -s, c, 0; 0, 0, 1];
  end
  out = points * m;
end  