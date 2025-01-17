function hAxes = clearUiAxes3d(hParentOrAxes, pv)
arguments
    hParentOrAxes = gfx.currentUiFigure % figure, uigrid or axis
    pv.ResetView logical = true; % If false, camera target & position are not reset
end

if hParentOrAxes.Type == "axes"
    hAxes = hParentOrAxes;
else
    hAxes = gfx.currentUiAxes(hParentOrAxes);
end

% Delete old callbacks, to avoid double callbacks. They are recreated with gfx.orbit3d
if isfield(hAxes.UserData, 'UiEventList')
    hAxes.UserData = rmfield(hAxes.UserData, 'UiEventList');
end

% cla kills the light, therefore the orbit is newly created
cla(hAxes);
gfx.orbit3d(hAxes);

if pv.ResetView
    gfx.resetView(hAxes);
end
