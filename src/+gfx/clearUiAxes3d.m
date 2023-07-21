function hAxes = clearUiAxes3d(hParent)
arguments
    hParent = gfx.getCurrentOrCreateUiFigure % normally figure or axis
end
hAxes = gfx.getCurrentOrCreateUiAxes(hParent);

% Delete old callbacks, to avoid double callbacks. They are recreated with gfx.orbit3d
if isfield(hAxes.UserData, 'UiEventList')
    hAxes.UserData = rmfield(hAxes.UserData, 'UiEventList');
end

% cla kills the light, therefore the orbit is newly created
cla(hAxes);
gfx.orbit3d(hAxes);