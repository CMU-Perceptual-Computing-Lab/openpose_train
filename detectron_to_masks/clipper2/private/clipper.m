function out = clipper(RefPol, ClipPol, Method, RefF, ClipF)
% CLIPPER Intersect polygons or outset/inset a polygon
%
%  NOTE: CLIPPER (and it's MEX version) should generally not be called directly.
%        Instead, use the simpler MATLAB interfaces in the functions:
%           POLYCLIP
%           POLYOUT
%
% -----------------------------------------------------------------------------
% 
%   P = CLIPPER(P1,P2,METHOD,FILL1,FILL2) clips polygons according to the METHOD
%         METHOD = 0 ==> difference (P1-P2)
%         METHOD = 1 ==> intersection
%         METHOD = 2 ==> Xor
%         METHOD = 3 ==> Union
%   The polygons are structures with .x and .y fields.  FILL1 & FILL2 are
%   optional fill types:
%                  0 ==> Even-Odd (default)
%                  1 ==> Non-Zero
%                  2 ==> Positive
%                  3 ==> Negative
%
%   P = CLIPPER(P1, DELTA, MITERTYPE, MITERINFO) outsets polygon P1 by the
%   distance DELTA (negative = inset).  The MITERTYPE is a character string:
%     's' or 'square' ==> square off corners
%                         MITERINFO is ignored.
%     'r' or 'round'  ==> round corners
%                         Required MITERINFO is precision for points along  arc
%                         (pi/acos(1-MITERINFO/DELTA) = # of points in 180deg),
%                         using the same scaling as the polygon points.
%     'm' or 'miter'  ==> miter corners (default)
%                         Optional MITERINFO is the miter limit, a multiple of DELTA;
%                         if the corner point would be moved more than
%                         MITERINFO*DELTA, then it is squared off instead;
%                         otherwise, the corner is done exactly.
%                         The default value of MITERINFO is 2;
%                         values below 2 are ignored.
%   P1 must be a single polygon (i.e., a scalar structure with fields .x and .y).
%   MITERINFO must be a scalar double.
%
%   CW = CLIPPER(P) returns whether the polygon(s) are clockwise oriented.
%   P may be a vector of polygons (each element with .x and .y fields.
%
%   Note: polygon coordinates MUST be of type int64.  Typically, real-valued
%   polygon coordinates are multiplied by some scalar (e.g., 2^32) and converted
%   to int64 before passing to clipper(); return polygon coordinates must have
%   the reverse mapping performed.
%
% This help text written by Prof. Erik A Johnson <JohnsonE@usc.edu>, 9/13/2015 & 1/28/2017
%
% This Mex function is a re-write by Prof. Erik Johnson of a mex wrapper originally written by Emmett
%    (http://www.mathworks.com/matlabcentral/fileexchange/36241-polygon-clipping-and-offsetting)
% which was based on Sebastian Hölz's Polygon Clipper mex wrapper for the GPC library
%    (https://www.mathworks.com/matlabcentral/fileexchange/8818-polygon-clipper)
%
% The Mex function calls a Polygon Clipping Routine based on Angus Johnson's clipper
%   (https://sourceforge.net/projects/polyclipping/)
%
% See also POLYCLIP, POLYOUT (all of which are simpler interfaces than CLIPPER)

error('must use the MEX version');
