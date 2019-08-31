clear
p1.x=[0 1 1 0]'; p1.y=[0 0 1 1]';
p2.x=p1.x+.5; p2.y=p1.y+.5;

scale=2^32;
pack   = @(p) arrayfun(@(x) struct('x', int64(x.x*scale),'y', int64(x.y*scale)),p);
unpack = @(p) arrayfun(@(x) struct('x',double(x.x)/scale,'y',double(x.y)/scale),p);
packdelta   = @(d) d*scale;
packarc = packdelta;
packmiter = @(m) m;

p = unpack(clipper(pack(p1),pack(p2),1));

disp([p1.x p1.y p2.x p2.y p.x p.y]);


p1(2,1)=p1; p2(2,1)=p2; 
p = clipper(pack(p1),pack(p2),1)
if numel(p)~=numel(p1), disp('as expected clipper did not properly handle simultaneous multiple polygon clippings'); else, warn('Contrary to expectation, clipper DID handle multiple simultaneous polygon clippings'); end;

ps = unpack(clipper(pack(p1(1)),packdelta(.05),'s'));

try
	P = unpack(clipper(pack(p1   ),packdelta(.05),'s'))
	warn('unexpectedly, clipper (outset mode) took a two-element input polygon')
catch
	disp('as expected, clipper  (outset mode) barfed on a two-element input polygon')
end

try
	pr = unpack(clipper(pack(p1(1)),packdelta(.05),'r'));
	warn('unexpectedly, clipper (outset mode) took a ''round'' join without an arcTolerance')
catch
	disp('as expected, clipper (outset mode) refused to do a ''round'' join without an arcTolerance')
end
pm = unpack(clipper(pack(p1(1)),packdelta(.05),'m'));

figure(1);
patch(p1(1).x,p1(1).y,'k','FaceColor','None');
patch(ps.x,ps.y,'r','FaceColor','None');
if exist('pr','var'), patch(pr.x,pr.y,'g--','FaceColor','None'); end;
patch(pm.x,pm.y,'b-.','FaceColor','None');
axis equal


figure(2);
clf
clear p; p.x=[0 1 1]'; p.y=[0 0 .5]';
patch(p.x,p.y,'k','FaceColor','None');
axis equal

pp=unpack(clipper(pack(p),packdelta(.05),'m',packmiter(1)));
patch(pp.x,pp.y,'r','FaceColor','none','EdgeColor','r');

pm = unpack(clipper(pack(p),packdelta(.05),'m'));
pr2 = unpack(clipper(pack(p),packdelta(.05),'r',packarc(.001)));
pr3 = unpack(clipper(pack(p),packdelta(.05),'r',packarc(.00001)));
pm1 = unpack(clipper(pack(p),packdelta(.05),'m',packmiter(1)));
pm2 = unpack(clipper(pack(p),packdelta(.05),'m',packmiter(2)));
pm05 = unpack(clipper(pack(p),packdelta(.05),'m',packmiter(0.5)));
