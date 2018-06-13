// Saves actual figure including axes, descriptions, etc.
//
// Inputs:
// fileName
//  - String with the output file name, including suffix such as '.png'
// xSize, ySize
//  - Integers, width and height of the output figure
//
// Outputs:
// none
//
// NOTES:
// Very basic implementation.
// Note that in Octave, there can be problems with OpenGL based graphics
// toolkits.
// MATLAB code based on
// https://www.mathworks.com/matlabcentral/answers/102382-how-do-i-specify-the-output-sizes-of-jpeg-png-and-tiff-images-when-using-the-print-function-in-mat
//
// ---------------------------------------------
//
//  CGDH TOOLS
//  Petr Lobaz, lobaz@kiv.zcu.cz
//  Faculty of Applied Sciences, University of West Bohemia 
//  Pilsen, Czech Republic
//
//  Check http://holo.zcu.cz for more details and scripts.
//
// ---------------------------------------------
function saveFigure(fileName, xSize, ySize)
  gcf().figure_size=[xSize,ySize]; xs2png(gcf(), fileName);
end