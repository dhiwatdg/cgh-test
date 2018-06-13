# CGDH Tools development utilities

This folder contains handy utilities for development.
You do not need to bother with them if you just want to use CGDH Tools. 

* The main folder contains two batch files for Octave -> Scilab conversion:

  * `m2sce.cmd` for conversion from `.m` to `.sce`

  * `m2sci.cmd` for conversion from `.m` to `.sci`

  (They are essentially the same, only the suffix is different.)

  Both batches are plain SED (https://www.gnu.org/software/sed/) text 
  replacements. Note that the batch files DO NOT convert arbitrary Octave/MATLAB
  code to the Scilab syntax. The original CGDH Tools `.m` files are written in 
  such a way it is possible to do the conversion using simple replacements 
  such as "%" to "//" for comments.

  The program sed.exe should be located in the search path or in the local 
  subfolder `sed`. You can use Gnuwin32 version 
  (http://gnuwin32.sourceforge.net/packages/sed.htm). The only files that need 
  to be located there are `libiconv-2.dll`, `libiconv2.dll`, `libintl3.dll`,
  `regex2.dll`, `sed.exe`.

* The folder `sed` can contain local copy of the sed editor as described in the 
  previous paragraph.
  
* The folder `tests` contains a few unit tests and sets scripts.
  Currntly they just cover a few critical cases.
  
* The folder `testUtils` contains utility functions for testing.


