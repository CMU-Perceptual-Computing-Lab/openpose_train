% function to test polyout.m

clear all; close all;

x1=[0 1 1 0]'; y1=[0 0 1 1]';
x2=[0 1 .75 .5 0 0]'; y2=[0 0 1 .3 .75 0]';
X={x1 x2}; Y={y1 y2};

props = {'LineWidth' 2};
join_ = {'round' []
         'square' []
         'miter' []
         'miter' 2.5
         'miter' 5
         };
delta_ = .25:-.0625:-.25;
colors = parula(length(delta_));
colors_light = 1-(1-colors)*.25;
colors_dark  = colors*.75;
ax = [];
clf;
P = cell(length(X),size(join_,1));
joinstrs = {};
for jj = 1:size(join_,1), [join,miterfactor]=deal(join_{jj,:});
	if isempty(miterfactor)
		if strcmp(join,'miter')
			infostr = ' (default=2)';
		else
			infostr = '';
		end
		miterarg = {};
	else
		infostr = sprintf(' (%s)',num2str(miterfactor));
		miterarg = {miterfactor};
	end;
	for ii = 1:length(X)
		for kdelta = 1:length(delta_), delta=delta_(kdelta);
			[x,y] = polyout(X{ii},Y{ii},delta,join,miterarg{:});
			p = cellfun(@(x,y)patch(x,y,'k','FaceColor',colors_light(kdelta,:),'EdgeColor',colors_dark(kdelta,:)),x,y,'UniformOutput',false); p=cat(1,p{:});
			if delta==0, set(p,'EdgeColor','k',props{:}); end;
			P{ii,jj} = [P{ii,jj}; p];
		end
		% p = patch(X{ii},Y{ii},'k','FaceColor','none','EdgeColor','k',props{:});
	end
	joinstrs{1,jj} = sprintf('%s%s',join,infostr);
end

% spread them out
UOf = {'UniformOutput' false};
widths = cellfun(@(x) max(x)-min(x), cellfun(@(x) cat(1,x{:}),cellfun(@(p) get(p,{'XData'}), P, UOf{:}), UOf{:}));
dx = max(widths(:));
heights = cellfun(@(y) max(y)-min(y), cellfun(@(y) cat(1,y{:}),cellfun(@(p) get(p,{'YData'}), P, UOf{:}), UOf{:}));
dy = max(heights,[],2);
gap = .25;
.5; dx=round((dx+gap)/ans)*ans; dy=round((dy+gap)/ans)*ans;
dx=repmat(dx,1,size(P,2)/length(dx)); dx=cumsum([0 dx]); DX=dx(end); dx(end)=[];
dy=repmat(dy,size(P,1)/length(dy),1); dy=cumsum([0;dy]); DY=dy(end); dy(end)=[];
[dx,dy] = meshgrid(dx,dy);
cellfun(@(p,dx,dy) set(p,{'XData'},cellfun(@(x)x+dx,get(p,{'XData'}),UOf{:}),{'YData'},cellfun(@(y)y+dy,get(p,{'YData'}),UOf{:})), P, num2cell(dx), num2cell(dy), UOf{:})

% add strings
[x1;x2]; (max(ans)+min(ans))/2; text(dx(1,:)+ans,repmat(DY,1,size(dx,2)),joinstrs,'HorizontalAlignment','center')

% set axis limits
findobj(gcf,'Type','patch');
	x=get(ans,{'XData'}); x=cat(1,x{:});
	y=get(ans,{'YData'}); y=cat(1,y{:});
1/100; axis([[min(x) max(x)]*(eye(2)+[1 -1;-1 1]*ans) [min(y) max(y)]*(eye(2)+[1 -1;-1 1]*ans)]);
axis equal
