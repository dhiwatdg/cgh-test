% Tests if two real values are approximately the same with respect to the
% machine epsilon (relative difference up to 16 * machine epsilon).
%
% Inputs:
% a, b
%  - two real scalars
%
% Outputs:
% true in case a \approx b
% false otherwise
%
% TODO
% Implement vectorized version.
function out = isequalFloat(a, b)
  if (~isscalar(a) || ~isscalar(b))
    error('isequalFloat: only for scalar values');
  end
  if (a == b)
    out = true;
  elseif (sign(a) ~= sign(b))
      out = false; 
  else
    % sign(a) == sign(b) ~= 0
    a = abs(a);
    b = abs(b);
    mn = min(a, b);
    mx = max(a, b);
    r = mx ./ mn;
    machineEpsilon = eps;      %% SCILAB %%     machineEpsilon = %eps;
    out = (r <= (1 + 16*machineEpsilon));
  end
end

%{
function tst(a, b, testResult)
  result = isequalFloat(a, b);
  if (result ~= testResult)
    fprintf('ERR: %f == %f  --> %d\n', a, b, result);
  end
end

s = eps*100;
e = eps;
% test that testing works
printf('testing testing: '); 
tst(0, 0, false);

% real testing
tst(0, 0, true);
tst(1, 1, true);
tst(-s, 0, false);
tst(-s, s, false);
tst(s, 2*s, false);
tst(1, 1+0.5*eps, true);


% tst([1, 2, 3], [1, 2, 1], [true, true, true]);
%}