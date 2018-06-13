// Converts a 1-D or a 2-D matrix to a string.
// Scalar: mat2str(1)         --> '[ 1 ]'
// Vector: mat2str([1, 2, 3]) --> '[1, 2, 3]'
// Vector: mat2str([1; 2; 3]) --> '[1 ; 2 ; 3]'
// Matrix: mat2str(eye(3,3))  --> '[1, 0, 0 ; 0, 1, 0 ; 0, 0, 1]'
function str = mat2str(matrix)
  if (isscalar(matrix))
    str = sprintf('[ %.6g ]', matrix);
  else
    mRows = size(matrix, 1);
    mColumns = size(matrix, 2);
    str = '';
    for row = 1:mRows
      if (row > 1)
        str = str + ' ; ';
      end
      for column = 1:mColumns
        if (column > 1)
          str = str + ', ';
        end
        str = sprintf('%s%.6g', str, matrix(row, column));
      end
    end
    str = sprintf('[%s]', str);
  end
end