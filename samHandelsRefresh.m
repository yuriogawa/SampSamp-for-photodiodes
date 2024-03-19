function [handles,samHandles]=samHandelsRefresh(handles)
    samHandles = getappdata(0,'samHandles');
    samHandles.stopTrig = str2num(get(handles.stopTrig,'String'));
    samHandles.triggVal = str2num(get(handles.triggVal,'String'));
    
    samHandles.fileName = get(handles.name, 'String');
    
    if length(samHandles.fileName)==length(samHandles.nameNull)
        if samHandles.fileName == samHandles.nameNull

            samHandles.fileName = '';
        end

    end
    
    samHandles.saveDir = get(handles.saveDir,'String');
samHandles.folderName = datestr(now,'dd-mmm-yyyy T HHMMSS');
samHandles.folderDir =([samHandles.saveDir '\' samHandles.folderName ]);

samHandles.fileNameMat = samHandles.folderName;

freqString = get(handles.freq,'String');
samHandles.freq = str2num(freqString);
delayTimeString = get(handles.delSam,'String');
samHandles.delaySamples = str2num(delayTimeString)/samHandles.freq;

samHandles.nameNull = get(handles.name,'String');

setappdata(0,'samHandles',samHandles);

