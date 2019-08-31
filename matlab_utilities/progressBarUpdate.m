function progressBarUpdate(current_index, max_index)
    % Update progress bar
    if mod(current_index, round(max_index/100)) == 0
        fprintf('\b.\n');
    end
end
