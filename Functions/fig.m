function T
handles.figure = figure;
handles.axes = axes;
handles.line1 = line();
set(handles.line1,'XData',[0.5 0.5],'LineWidth',[3]);
set(handles.line1,'ButtonDownFcn',@(h,ev)pushButton(handles));
get(handles.line1)
set(handles.figure,'WindowButtonUpFcn',@(h,ev)stop(handles));

function pushButton(handles)
get(handles.figure)
set(handles.figure,'WindowButtonMotionFcn',@(h,ev)motion(motion))


function motion(handles)
position = get(handles.axes,'CurrentPoint');
set(handles.line1,'XData',[position(1) position(1)]);

function stop(handles)
set(handles.line1,'ButtonDownFcn','');