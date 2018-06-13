// Wraps matrix values from [-%pi, +%pi] to [0, 2*%pi]
function out = wrapTo2Pi(m)
  if (isscalar(m) && m < 0)
    m = m + 2*%pi;
  else
    index = m < 0;
    if (~isempty(index))
      m(index) = m(index) + 2*%pi;
    end
  end
  out = m;
end
