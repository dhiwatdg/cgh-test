This folder contains two batch files:

* `m2sce.cmd` for conversion from `.m` to `.sce`

* `m2sci.cmd` for conversion from `.m` to `.sci`

(They are essentially the same, only the suffix is different.)

Both batches are plain SED (https://www.gnu.org/software/sed/) text 
replacements. Note that the batch files DO NOT convert arbitrary Octave/MATLAB
code to the Scilab syntax. The original CGDH Tools `.m` files are written in such a way it
is possible to do the conversion using simple replacements such as "%" to "//"
for comments.

The program sed.exe should be located in the search path or in the local 
subfolder `sed`. You can use Gnuwin32 version 
(http://gnuwin32.sourceforge.net/packages/sed.htm). The only files that need 
to be located there are `libiconv-2.dll`, `libiconv2.dll`, `libintl3.dll`,
`regex2.dll`, `sed.exe`.


