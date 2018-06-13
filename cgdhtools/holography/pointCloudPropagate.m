% Simple propagation of a point cloud to a plane z = optfieldZ 
% Does not check for aliasing
%
% Inputs:
% pointCloudPosition
%  - Matrix of 3-D points, each row makes a (x, y, z) point
% pointCloudAmplitude
%  - Vector of complex amplitudes of the points.
%  - It is assumed that the length of 'amplitudes' equals to number of points.
% lambda
%  - The wavelength.
% xx, yy
%  - X and Y coordinates of the samples.
%  - It is assumed they are calculated using
%    [xx, yy] = meshgrid(xVector, yVector)
% optfieldZ
%  - The wave is calculated in z = optfieldZ
%
% Outputs:
% optfield
%  - Matrix of complex amplitudes, the size is the same as size of xx.
%
% NOTES:
%  - It is assumed that no point lies in z = optfieldZ.
%  - Does not check aliasing; 
%    see pointsPropagateNoAliasing.m for improved version.
%  - Assumes z coordinates of points < optfieldZ.
%    Calculates "backpropagation" when 'point Z coordinate' > optfieldZ.
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
function optfield = pointCloudPropagate(pointCloudPosition, pointCloudAmplitude, ...
 lambda, xx, yy, optfieldZ)

  % Initialize
  optfield = zeros(size(xx, 1), size(xx, 2));
  nPoints = size(pointCloudPosition, 1);
  
  % Loop point by point
  for i = 1:nPoints
    % Add a spherical wave of a current point
    optfield = optfield + pointCloudAmplitude(i) * ...
               cgdhFunct('SphericalWave', ...
                (xx - pointCloudPosition(i, 1)), ...
                (yy - pointCloudPosition(i, 2)), ...
                [lambda, optfieldZ - pointCloudPosition(i, 3)]);
  end
end