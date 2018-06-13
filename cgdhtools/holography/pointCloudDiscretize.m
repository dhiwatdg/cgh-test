% Quantization of a point cloud for perspective image rendering simulation.
%
% When rendering a point cloud, point coordinates are rounded to the neraest
% pixel position. This function adjusts X, Y coordinates and keeps Z coordinate
% in such a way that after projection, point position is aligned with pixel
% center.
% Projection screen is parallel to z = const. Tilt-shift camera is employed.
%
% Inputs:
% pointCloudPosition
%  - Matrix of 3-D points, each row makes a (x, y, z) point
% cameraPosition
%  - Vector [x, y, z] with projection center.
% imageCenter
%  - Center point of the projection screen. 
%  - The projection screen is equal to z = imageCenter(3)
%  - Center of the projection screen is equal to the center of the central pixel.
%  - Projection screen size is not limited.
% imageDelta
%  - Sampling distance(s) in X and Y directions.
%  - They are used for the quantization itself.
%
% Outputs:
% out
%  - Matrix of 3-D quantized points, each row makes a (x, y, z) point.
%  - Z coordinated are the same as of the original point cloud.
%
% NOTES:
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
function out = pointCloudDiscretize(pointCloudPosition, ...
  cameraPosition, imageCenter, imageDelta)
  % initialize output matrix
  out = zeros(size(pointCloudPosition, 1), size(pointCloudPosition, 2));

  deltaYX = getDeltaYX(imageDelta);
  deltaY = deltaYX(1);
  deltaX = deltaYX(2);
  
  xShift = cameraPosition(1) - imageCenter(1);
  yShift = cameraPosition(2) - imageCenter(2);
  
  for idx = 1:size(pointCloudPosition, 1)
    x = pointCloudPosition(idx, 1);
    y = pointCloudPosition(idx, 2);
    z = pointCloudPosition(idx, 3);

    perspFactor = (cameraPosition(3) - imageCenter(3)) / ...
                  (cameraPosition(3) - z);
    
    % projection to the image plane
    x = (x - cameraPosition(1))*perspFactor + xShift;
    y = (y - cameraPosition(2))*perspFactor + yShift;
    
    % discretize
    x = floor(x / deltaX + 0.5) * deltaX;   
    y = floor(y / deltaY + 0.5) * deltaY;   
    
    % backprojection to original z coordinate
    x = (x - xShift) / perspFactor + cameraPosition(1);
    y = (y - yShift) / perspFactor + cameraPosition(2);
    
    out(idx, :) = [x, y, z];
  end
end
