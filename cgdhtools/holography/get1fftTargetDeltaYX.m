% Calculates target sampling distance for 1fft propagation method
%
% Inputs:
% lambda 
%  - The wavelength.
% sourceSize 
%  - Size of the of the source array, i.e. the vector [rows, columns] .
% sourceDeltaYX 
%  - Sampling distances [deltaY, deltaX] of the source.
% propagationDistance 
%  - The propagation distance.
%
% Outputs:
% targetDeltaYX 
%  - Sampling distances [deltaY, deltaX] of the target.
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
function targetDeltaYX = get1fftTargetDeltaYX(lambda, sourceSize, sourceDeltaYX, propagationDistance)
    targetDeltaYX = lambda*abs(propagationDistance)./(sourceSize .* sourceDeltaYX);
end