function hAxes = currentUiAxes(hParent)
arguments
    hParent = gfx.currentUiFigure;
end

hFigure = ancestor(hParent, 'figure');
hAxes = hFigure.CurrentAxes;
if isempty(hAxes)
    hAxes = uiaxes(hParent);

    if isa(hParent, 'matlab.ui.Figure')
        % Matlab 2021b doesn't center a new uiaxes in a uifigure, as it did
        % with the old axes. Maybe this can vanish again with a newer
        % Matlab version
        hAxes.Units = 'normalized';
        hAxes.Position = [0.05 0.05 0.9 0.9];
    end

end