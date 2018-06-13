% Writes a text to the console and waits for Enter
%
% Inputs:
% message
%  - string to be written to the console
%
% Outputs:
% none
function waitForKey(message)
  disp(message); %% SCILAB %%     disp(message);
  pause();       %% SCILAB %%     tmp = mscanf('%s');
end