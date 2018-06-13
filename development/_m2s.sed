/%% SCILAB %% [ \t]*\/\/ empty/d
s/%\([0-9]*\.\?[0-9]*[sdfg]\)/##\1/g
s/%{/\/*/g
s/%}/*\//g
/%% SCILAB %%/!s/%/\/\//
/%% SCILAB %%/!s/%\([^%]\)/\/\/\1/g
/%% SCILAB %%/s/^[^%]*%% SCILAB %% //
s/##/%/g
s/piNumber = pi;/piNumber = %pi/
s/true/%T/g
s/false/%F/g
s/colormap('gray')/gcf().color_map = graycolormap(256)/
s/fprintf(/mprintf(/g
s/flushOutput();//g
s/addpath('\([./]*\)helper_functions');/getd('\1helper_functions');/g
s/addpath('\([./]*\)testUtils');/getd('\1testUtils');/g
s/addpath(genpath('\([./]*\)cgdhtools'));/cgdhPath = '\1cgdhtools'; exec(strcat([cgdhPath, '\/loadSubfolders.sce']));/
s/iscomplex(/~isreal(/g
s/nargout()/argn(1)/g
s/axis('image')/gca().isoview = 'on'; gca().tight_limits = 'on'/
s/hold('on')/set(gca(),'auto_clear','off');/g
s/hold('off')/set(gca(),'auto_clear','on');/g
s/(end)/($)/g
s/figure(\([^)]*\))/scf(\1); gcf().background = -2/g