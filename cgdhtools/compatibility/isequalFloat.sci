// Tests if two real values are approximately the same with respect to the
// machine epsilon (relative difference up to 16 * machine epsilon).
//
// Inputs:
// a, b
//  - two real scalars
//
// Outputs:
// %T in case a \approx b
// %F otherwise
//
// TODO
// Implement vectorized version.
function out = isequalFloat(a, b)
  if (~isscalar(a) || ~isscalar(b))
    error('isequalFloat: only for scalar values');
  end
  if (a == b)
    out = %T;
  elseif (sign(a) ~= sign(b))
      out = %F; 
  else
    // sign(a) == sign(b) ~= 0
    a = abs(a);
    b = abs(b);
    mn = min(a, b);
    mx = max(a, b);
    r = mx ./ mn;
    machineEpsilon = %eps;
    out = (r <= (1 + 16*machineEpsilon));
  end
end

/*
function tst(a, b, testResult)
  result = isequalFloat(a, b);
  if (result ~= testResult)
    mprintf('ERR: %f == %f  --> %d\n', a, b, result);
  end
end

s = eps*100;
e = eps;
// test that testing works
printf('testing testing: '); 
tst(0, 0, %F);

// real testing
tst(0, 0, %T);
tst(1, 1, %T);
tst(-s, 0, %F);
tst(-s, s, %F);
tst(s, 2*s, %F);
tst(1, 1+0.5*eps, %T);


// tst([1, 2, 3], [1, 2, 1], [%T, %T, %T]);
*/