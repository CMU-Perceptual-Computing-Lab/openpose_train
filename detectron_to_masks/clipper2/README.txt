README for Clipper2

This package provides convenient MATLAB front ends to Angus Johnson's polygon
clipping routines (https://sourceforge.net/projects/polyclipping/).

FUNCTIONS:
   polyclip -- find the difference, intersection, xor or union of two polygons
   polyout  -- outset (or inset) a polygon's vertices
Each polygon is specified by a vector of x values and a vector of y values.
The work is done by the MEX file private/clipper (which must be compiled).


INSTALLATION

This has only been tested on a Mac (OS X 10.11.6 El Capitan, MATLAB R2016b).

1. Download clipper code from https://sourceforge.net/projects/polyclipping
2. Unzip the archive (if needed)
3. Remember the name of the resulting folder
4. Move the resulting folder inside clipper2/private/
5. Compile:
   A. via command line
        i) Edit clipper2/private/Makefile to specify:
            * where your MATLAB application is
            * the name of the clipper folder (from #3)
       ii) In Terminal:
              cd clipper2/private/
              make
   B. via a MATLAB command
        i) launch MATLAB
       ii) execute the following at MATLAB's command line
              cd('path/to/clipper2/private')
	      clipper_dir='clipper'; % change the folder name in #3
	      mex('-D__int64=__int64_t',['-I' clipper_dir '/cpp'],[clipper_dir '/cpp/clipper.cpp'],'mexclipper.cpp') 


CREDITS

This is distributed by Prof. Erik A Johnson <JohnsonE@usc.edu>.
The MEX wrapper is a re-write of one originally written by Emmett
    (http://www.mathworks.com/matlabcentral/fileexchange/36241-polygon-clipping-and-offsetting)
which was based on Sebastian Holz's Polygon Clipper mex wrapper for the GPC library
    (https://www.mathworks.com/matlabcentral/fileexchange/8818-polygon-clipper)

