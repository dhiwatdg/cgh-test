function fnTestFloat(a, b, testDesc)
  if (size(a) == size(b))
    a = a(:);
    b = b(:);
    for idx = 1:size(a, 1)
      if (~isequalFloat(a(idx), b(idx)))
        if (nargin == 3)
          testString = sprintf('Test no. %d: ', testDesc);
        else
          testString = '';
        end
        if (size(a, 1) == 1)
          infoString = '';
        else
          infoString = sprintf(' at index %d', idx);
        end
        error(sprintf('%s%f NOT EQUAL TO %f%s\n', ...
          testString, a(idx), b(idx), infoString));
      end  
    end
    fprintf('OK\n');
  else
    testString = sprintf('Test no. %d: ', testDesc);
    error(sprintf('%sSizes do not match - %s vs. %s\n', ...
      testString, mat2str(size(a)), mat2str(size(b))));
  end
end

