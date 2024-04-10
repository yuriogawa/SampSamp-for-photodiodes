function results = isEnoughDataBuffered(timeBuffer, delaySamples)
%isEnoughDataBuffered Checks whether buffering pre-trigger data is complete    

    % If specified trigger delay is less than 0, need to check
    % whether enough pre-trigger data is buffered so that a
    % triggered capture can be requested

    results = 0;
    if (size(timeBuffer,1) > delaySamples)
        results = 1;
    end
           