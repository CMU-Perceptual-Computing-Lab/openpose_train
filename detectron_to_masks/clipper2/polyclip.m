function [X,Y] = polyclip(x1,y1,x2,y2,method)
% POLYCLIP  Clip two polygons (intersect, union, xor, diff).
% 
%  [X,Y] = POLYCLIP(X1,Y1,X2,Y2,METHOD) clips the two polygons given by the
%  points (X1(i),Y1(i)) and (X2(j),Y2(j)) according to the METHOD:
%         METHOD = 0 or 'dif' ==> difference (P1-P2)
%         METHOD = 1 or 'int' ==> intersection
%         METHOD = 2 or 'xor' ==> Xor
%         METHOD = 3 or 'uni' ==> Union
%  X and Y are cell arrays (because the result may be multiple polygons)
%  containing the x and y coordinates of the resulting polygon(s).
%
%  XY = POLYCLIP([X1 Y1],[X2 Y2],METHOD) does the same assuming the Xi and Yi
%  are column vectors.  The result is {X Y}.
%
% See also CLIPPER, POLYOUT.

% Copyright (c)2015-17, Prof. Erik A. Johnson <JohnsonE@usc.edu>, 01/29/17

% 09/13/15  EAJ  Initial code
% 01/28/17  EAJ  Update for newer MATLAB versions
% 01/29/17  EAJ  Fix: test for METHOD as string, single output

narginchk(2,5);
if any(nargin==[2 4]), method=[]; end
if any(nargin==[2 3]) % POLYCLIP([X1 Y1],[X2 Y2],METHOD)
	if size(x1,2)~=2 || size(y1,2)~=2 || ~isnumeric(x1) || ~isnumeric(y1),
		error('The [X1 Y1] and [X2 Y2] matrices must be numeric two-column matrices.');
	end
	if nargin == 3
		method = x2;
	else
		method = [];
	end
	y2=y1(:,2); x2=y1(:,1);
	y1=x1(:,2); x1=x1(:,1);
else
	if ~isnumeric(x1) || ~isnumeric(y1) || ~isnumeric(x2) || ~isnumeric(y2)
		error('The polygon coordinates must be numeric matrices.')
	elseif numel(x1)~=length(x1) || numel(y1)~=length(y1) || numel(x2)~=length(x2) || numel(y2)~=length(y2)
		error('Function only handles the clipping of one polygon with another, not multiple polygons with multiple polygons');
	elseif numel(x1)~=numel(y1) || numel(x2)~=numel(y2)
		error('X1 must be the same size as Y1, and X2 the same size as Y2.');
	end;
	if length(x1)==numel(x1), x1=x1(:); y1=y1(:); end; % ensure column
	if length(x2)==numel(x2), x2=x2(:); y2=y2(:); end; % ensure column
	if nargin == 4
		method = [];
	end
end;
if isempty(method), method=0; end
if isstr(method)
	find(lower(method(1))==['dixu']) - 1;
	if isempty(ans)
		error('METHOD must be an integer (0 to 3) or {''diff'',''int'',''xor'',''union''}.');
	end;
	method = ans;
end
if ~isscalar(method) || ~any(method==0:3)
	error('METHOD must be 0, 1, 2 or 3.')
end;

scale = 2^4;%2^32;

% leave this in array format just in case we later adapt this
pack   = @(p) arrayfun(@(x) struct('x', int64(x.x*scale),'y', int64(x.y*scale)),p);
unpack = @(p) arrayfun(@(x) struct('x',double(x.x)/scale,'y',double(x.y)/scale),p);

poly1 = struct('x',num2cell(x1,1),'y',num2cell(y1,1));
poly2 = struct('x',num2cell(x2,1),'y',num2cell(y2,1));

assert(numel(poly1)==1, 'Only single polygon clippings are allowed in the current code');
poly3 = unpack(clipper(pack(poly1),pack(poly2),method));

if isempty(poly3)
	x = cell(1,0);
	y = cell(1,0);
else
	x = {poly3.x};
	y = {poly3.y};
end

% % package into single polygon with NaN's separating individual polygons
% lens = cellfun(@numel,{poly3.x}');
% cellfun(@(x,l) [x;NaN(max(lens)-l,1)], {poly3.x}', num2cell(lens), 'UniformOutput',false); x=cat(2,ans{:});
% cellfun(@(y,l) [y;NaN(max(lens)-l,1)], {poly3.y}', num2cell(lens), 'UniformOutput',false); y=cat(2,ans{:});

if nargout>=2
	X = x;
	Y = y;
else
	% X = cellfun(@(x,y) [x(:) y(:)],x,y,'UniformOutput',false);
	X = {x y};
end
