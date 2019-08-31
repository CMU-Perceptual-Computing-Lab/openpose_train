function startParallel(disableWarnings)
    % Start parpool if not started
    % Option a
    p = gcp;
    p.IdleTimeout = 525600;
    if exist('disableWarnings', 'var') && disableWarnings
        warning ('off','all');
    end
    % Option b
    % delete(gcp('nocreate')); parpool('local', 6);
end
