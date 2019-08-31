function printToc( timeToPrint )
    msec = 1e3*(timeToPrint - floor(timeToPrint));
    sec = rem(timeToPrint-msec*1e-3,60);
    min = rem(floor(timeToPrint/60), 60);
    hours = floor(floor(timeToPrint/60)/60);
    disp(['Total time = ', int2str(hours), ' hours, ', int2str(min), ' min, ', int2str(sec), ' sec, ', num2str(msec), ' msec']);
%     disp(['Total time = ', int2str(hours), ':', int2str(min), ':', int2str(sec), ':']);
end
