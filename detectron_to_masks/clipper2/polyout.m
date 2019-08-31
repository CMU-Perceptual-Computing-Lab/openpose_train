function [X,Y] = polyout(x1,y1,delta,join,info)
% POLYOUT  Outset (expand/inflate) a polygon.
% 
%  [X,Y] = POLYOUT(X1,Y1,DELTA,JOIN,JOININFO) outsets the polygon given by
%  points (X1(i),Y1(i)).  The corners are joined based on the (optional) JOIN:
%    JOIN = 'm' or 'miter' ==> exact corners but square at small angles (default)
%               Optional JOININFO is the miter limit, a multiple of DELTA;
%               if the corner point would be moved more than JOININFO*DELTA,
%               then it is squared off instead.  The default value, as well
%               as the minimum allowed, is 2.
%    JOIN = 's' or 'square' ==> square off corners
%               JOININFO is ignored.
%    JOIN = 'r' or 'round'  ==> round corners
%               Required JOININFO sets the precision of points along the arc
%               (smaller JOININFO ==> more points along the arc); for a 180deg
%               arc, the number of points is (pi/acos(1-JOININFO/DELTA) using
%               the same scaling as the polygon points.
%  X1 and Y1 must be vectors of the same size. JOININFO must be a scalar double.
%
%  X and Y are cell arrays (because the result may be multiple polygons)
%  containing the x and y coordinates of the resulting polygon(s).
%  
%  XY = POLYOUT([X1 Y1],DELTA,JOIN,JOININFO) does the same for column vectors
%  X1 and Y1, and XY is {X Y}.
%
% See also CLIPPER, POLYCLIP.

% Copyright (c)2015-17, Prof. Erik A. Johnson <JohnsonE@usc.edu>, 01/28/17

% 09/13/15  EAJ  Initial code
% 01/28/17  EAJ  Update for newer MATLAB versions
% 01/29/17  EAJ  Correct [X1 Y1] code (change x & y to x1 & y1)

narginchk(2,5)
nargoutchk(0,2)
if nargin==2 || (nargin>=3&&ischar(delta))  % POLYOUT([X1 Y1],DELTA,...)
	narginchk(2,4)
	if nargin>=3,
		if nargin==4
			info = join;
		end;
		join = delta;
	else
		join = [];
		info = [];
	end
	delta = y1;
	y1 = x1(:,end/2+1:end);
	x1(:,end/2+1:end) = [];
else
	if nargin<4, join=[]; end;
	if nargin<5, info=[]; end;
end
if isempty(join), join='miter'; end; %default join method
if ~ischar(join), error('JOIN must be a string'); end;
if isempty(info)
	infoArg = {};
else
	infoArg = {info};
end

scale=2^32;
% leave this in array format just in case we later adapt this
pack   = @(p) arrayfun(@(x) struct('x', int64(x.x*scale),'y', int64(x.y*scale)),p);
unpack = @(p) arrayfun(@(x) struct('x',double(x.x)/scale,'y',double(x.y)/scale),p);
packdelta   = @(d) d*scale;
packarc = packdelta;
packmiter = @(m) m;

if lower(join(1))=='r'
	if isempty(info)
		info = (abs(delta)+(delta==0))*(1-cosd(5)); % about every 5 degrees
		% error('A ''round'' JOIN must provice the ArcTolerance as the fourth argument.')
	end
	infoArg = {packarc(info)};
end

if ~isnumeric(x1) || ~isnumeric(y1)
	error('The polygon coordinates must be numeric matrices.')
elseif numel(x1)~=length(x1) || numel(y1)~=length(y1)
	error('Function only handles a single polygon');
elseif numel(x1)~=numel(y1)
	error('X1 must be the same size as Y1, and X2 the same size as Y2.');
end;

x1=x1(:); y1=y1(:); % ensure column

poly1 = struct('x',num2cell(x1,1),'y',num2cell(y1,1));
assert(numel(poly1)==1, 'Only single polygon outsets are allowed in the current code');
poly3 = unpack(clipper(pack(poly1),packdelta(delta),join,infoArg{:}));

if isempty(poly3)
	x = cell(1,0);
	y = cell(1,0);
else
	x = {poly3.x};
	y = {poly3.y};
end

if nargout>=2
	X=x; Y=y;
else
	X={x y};
end
