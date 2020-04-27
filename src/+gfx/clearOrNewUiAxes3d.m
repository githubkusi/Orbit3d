function hAxes = clearOrNewUiAxes3d(hParent)
if nargin == 0
    hParent = gfx.getCurrentOrCreateUiFigure;
end
hAxes = gfx.getCurrentOrCreateUiAxes(hParent);

% cla kills the light, therefore the orbit is newly created
cla(hAxes);
gfx.orbit3d(hAxes);