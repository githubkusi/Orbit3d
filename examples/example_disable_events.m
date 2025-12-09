%% minimal example with 3d orbit
hAxes = uiaxes;
gfx.orbit3d(hAxes);
plot3(hAxes, [1 2], [1 2], [1 2])

%% disable keypress event
% Stop keyboard shortcuts such as color/transparency/grid/...
eventList = hAxes.UserData.UiEventList;
keypressUid = eventList([eventList.name] == "KeyPress").uid;
gfx.FigureEventDispatcher.disableEvent(hAxes, keypressUid)

%% re-enable keypress event
% Re-enable keyboard shortcuts
gfx.FigureEventDispatcher.enableEvent(hAxes, keypressUid)

