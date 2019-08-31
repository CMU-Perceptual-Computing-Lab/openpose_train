function h = filledEllipse(A,xc,col,facealpha)
    % define points on a unit circle
    th = linspace(0, 2*pi, 50);
    pc = [cos(th);sin(th)];
    % warp it into the ellipse
    pe = sqrtm(A)*pc;
    pe = bsxfun(@plus, xc(:), pe);
    h = patch(pe(1,:),pe(2,:),col);
    set(h,'FaceAlpha',facealpha);
    set(h,'EdgeAlpha',0);
end
