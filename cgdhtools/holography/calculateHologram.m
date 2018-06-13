% Calculates a hologram using given object wave and reference wave.
%
% Inputs:
% objectWave 
%  - Matrix of complex amplitudes (object wave)
% referenceWave 
%  - Matrix of complex amplitudes (reference wave)
%  - Sizes of objectWave and referenceWave must match
%  - For a plane wave at normal incidence, referenceWave can be just a scalar
%    (e.g. 1)
% method
%  - Type of hologram calculation method.
%  - If not given, defaults to 'classical'
%  - Implemented types are:
%    'classical'
%      Calculate the classical hologram, i.e.
%      hologram = |objectWave + referenceWave|.^2
%    'bipolar'
%      Calculate the bipolar intensity hologram, i.e.
%      hologram = real(objectWave .* conj(referenceWave))
%    'shiftedBipolar'
%      Calculate the bipolar hologram and shift its values to make them   
%      positive.
%    'kinoformArgument'
%      Kinoform is the phase only hologram containing just the phase of 
%      the optical field. After getting the 'kinoformArgument' result,
%      make the phase kinoform by calling bleachHologram(argKinoform);
%      Note: Classical kinoform codes phase of the object wave only,
%      this implementation includes intended reconstruction wave.
%      For a classical kinoform, set the reference wave to 1 or other constant.
%    'complex'
%      Full complex hologram (coding amplitude and phase).
%      Classical complex hologram is just the object wave, usually
%      with amplitude normalized to 1. This implementation includes intended 
%      reconstruction wave. For a classical complex hologram, set
%      the reference wave to 1 or other constant.
% normalize
%  - Boolean. If set true, the hologram is scaled in such a way that its maximum
%    absolute value is 1.
%  - 'kinoformArgument' is not normalized regardless this parameter
%  - If not given, defaults to true.
%
% Outputs:
% hologram
%  - Matrix of the same size as objectWave.
%  - Complex in case method = 'complex', otherwise real.
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
function hologram = calculateHologram(objectWave, referenceWave, method, normalize)
  if (nargin < 3)
    method = 'classical';
  end
  if (nargin < 4)
    normalize = true;
  end
  
  % Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = pi;

  switch (method)
    case 'classical'
      optField = objectWave + referenceWave;
      hologram = real(optField .* conj(optField));
    case 'bipolar'
      hologram = real(objectWave .* conj(referenceWave));
    case 'shiftedBipolar'
      hologram = real(objectWave .* conj(referenceWave));
      hologram = hologram - min(min(hologram));
    case 'kinoformArgument'
      if (~exist('wrapTo2Pi')) %% SCILAB %% // empty
        pkg load mapping;      %% SCILAB %% // empty
      end                      %% SCILAB %% // empty
      hologram = wrapTo2Pi(angle(objectWave .* conj(referenceWave))) / (2*piNumber);
      normalize = false;
    case 'complex'
      hologram = objectWave ./ referenceWave;
  end
  
  if (normalize)
    scale = max(max(abs(hologram)));
    hologram = hologram / scale;
  end
end
  