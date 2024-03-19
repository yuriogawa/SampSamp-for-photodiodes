function main
f = figure
aH = axes('Xlim',[0, 1], 'YLim',[0 1]);

h = line([0.5 0.5], [0 1], ...
    'Color' , 'r',       ...
    'linewidth', 3,       ...
    'ButtonDownFcn', @startDragFcn);

set (f, 'WindowButtonUpFcn', @stopDragFcn);

function startDragFcn(varargin)

    set(f, 'WindowButtonMotionFcn',@draggingFcn)
end

    function draggingFcn(varargin)
        pt = get(aH,'CurrentPoint');
        set(h,'XData',pt(1)*[1 1]);
    end
    function stopDragFcn(varargin)
            set(f,'WindowButtonMotionFcn','');
    end
end
