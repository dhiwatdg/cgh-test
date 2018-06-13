% Saves actual figure including axes, descriptions, etc.
%
% Inputs:
% fileName
%  - String with the output file name, including suffix such as '.png'
% xSize, ySize
%  - Integers, width and height of the output figure
%
% Outputs:
% none
%
% NOTES:
% Very basic implementation.
% Note that in Octave, there can be problems with OpenGL based graphics
% toolkits.
% MATLAB code based on
% https://www.mathworks.com/matlabcentral/answers/102382-how-do-i-specify-the-output-sizes-of-jpeg-png-and-tiff-images-when-using-the-print-function-in-mat
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
function saveFigure(fileName, xSize, ySize)
  if (isOctave())                                              %% SCILAB %% // empty
    print(fileName, sprintf('-S%d,%d', xSize, ySize));         %% SCILAB %% // empty
  else                                                         %% SCILAB %% // empty
    oldScreenUnits       = get(gcf(), 'Units');                %% SCILAB %% // empty
    oldPaperUnits        = get(gcf(), 'PaperUnits');           %% SCILAB %% // empty
    oldPaperPositionMode = get(gcf(), 'PaperPositionMode');    %% SCILAB %% // empty
    oldPaperPosition     = get(gcf(), 'PaperPosition');        %% SCILAB %% // empty
    oldPaperSize         = get(gcf(), 'PaperSize');            %% SCILAB %% // empty
    set(gcf(), 'PaperUnits', 'inches', ...                     %% SCILAB %% // empty
               'PaperPositionMode', 'auto', ...                %% SCILAB %% // empty
               'PaperPosition', [0 0 xSize/100 ySize/100], ... %% SCILAB %% // empty
               'PaperSize', [xSize/100 ySize/100]);            %% SCILAB %% // empty
    drawnow                                                    %% SCILAB %% // empty
    cdata = print('-RGBImage', '-r100');                       %% SCILAB %% // empty
    imwrite(cdata, fileName);                                  %% SCILAB %% // empty
    set(gcf(), 'Units', oldScreenUnits, ...                    %% SCILAB %% // empty
               'PaperUnits', oldPaperUnits, ...                %% SCILAB %% // empty
               'PaperPositionMode', oldPaperPositionMode, ...  %% SCILAB %% // empty
               'PaperPosition', oldPaperPosition, ...          %% SCILAB %% // empty
               'PaperSize', oldPaperSize);                     %% SCILAB %% // empty
  end                                                          %% SCILAB %% // empty
  %% SCILAB %%   gcf().figure_size=[xSize,ySize]; xs2png(gcf(), fileName);
end