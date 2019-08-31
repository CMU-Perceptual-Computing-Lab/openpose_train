% function to test polyclip.m

clear all; close all;
x1=[0 1 1 0]'; y1=[0 0 1 1]';
x2=x1+.5; y2=y1+.5;

methodstrs = {'dif' 'difference'
              'int' 'intersection'
              'xor' 'Xor'
              'uni' 'union'
             };

d = [0 .75];
methods = 0:3;
for ii = 1:numel(d)
	for jj = 1:numel(methods)
		[x,y] = polyclip(x1,y1,x2+d(ii),y2,methods(jj));
		subplot(length(d),length(methods),jj+(ii-1)*length(methods));
		p=cellfun(@(x,y)patch(x,y,'k','FaceColor','g','EdgeColor','none'),x,y,'UniformOutput',false); p=cat(1,p{:});
		p1=patch(x1,y1,'k','FaceColor','none','EdgeColor','b','LineWidth',2);
		p2=patch(x2+d(ii),y2,'k','FaceColor','none','EdgeColor','r','LineWidth',2);
		title(sprintf('%d ''%s'' (%s)',methods(jj),methodstrs{methods(jj)+1,1},methodstrs{methods(jj)+1,2}));
		1/20; axis(reshape([eye(2)+[1 -1;-1 1]*ans]*reshape(axis,2,[]),1,[])); % expand axis limits a bit
	end
end


