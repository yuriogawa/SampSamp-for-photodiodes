function data = storeDataInFIFO(data, buffersize, timeBlock, dataBlock)
%storeDataInFIFO Store continuous acquisition data in a FIFO data buffer
%  Storing data in a finite-size FIFO buffer is used to plot the latest "N" seconds of acquired data for
%  a smooth live plot update and without continuously increasing memory use.
%  The most recently acquired data (datablock) is added to the buffer and if the amount of data in the
%  buffer exceeds the specified buffer size (buffersize) the oldest data is discarded to cap the size of
%  the data in the buffer to buffersize.
%  input data is the existing data buffer (column vector Nx1).
%  buffersize is the desired buffer size (maximum number of rows in data buffer) and can be changed.
%  datablock is a new data block to be added to the buffer (column vector Kx1).
%  output data is the updated data buffer (column vector Mx1).

    oldDataSize = size(data, 1);
    newDataSize = size(timeBlock, 1);
    % If the data size is greater than the buffer size, keep only the
    % the latest "buffer size" worth of data
    % This can occur if the buffer size is changed to a lower value during acquisition
    if size(oldDataSize,1) > buffersize
        data = data(end-buffersize+1:end,:);
    end
    
    if newDataSize < buffersize
        % Data block size (number of rows) is smaller than the buffer size
        if oldDataSize == buffersize
            % Current data size is already equal to buffer size.
            % Discard older data and append new data block,
            % and keep data size equal to buffer size.
            shiftPosition = size(dataBlock,1);
            data = circshift(data,-shiftPosition);
            data(end-shiftPosition+1:end,:) = [timeBlock, dataBlock];
        elseif any((oldDataSize < buffersize)) && any((oldDataSize+newDataSize > buffersize))
            % Current data size is less than buffer size and appending the new
            % data block results in a size greater than the buffer size.
            data = [data; [timeBlock, dataBlock]];
            shiftPosition = size(data,1) - buffersize;
            data = circshift(data,-shiftPosition);
            data(buffersize+1:end, :) = [];
        else
            % Current data size is less than buffer size and appending the new
            % data block results in a size smaller than or equal to the buffer size.
            % (if (size(data,1) < buffersize) && (size(data,1)+size(datablock,1) <= buffersize))
            data = [data; [timeBlock, dataBlock]];
        end
    else
        % Data block size (number of rows) is larger than or equal to buffer size
        data = [timeBlock(end-buffersize+1:end,:), dataBlock(end-buffersize+1:end,:)];
    end