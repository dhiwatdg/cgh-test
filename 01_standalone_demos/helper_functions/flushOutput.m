% Flushes the standard output (stdout). Useful if print to a console
% should appear immediately, such as when printing calculation progress.
% Calls to flushOutput should be removed in Scilab
function flushOutput()
  if (isOctave) 
    fflush(stdout);
  end
end
