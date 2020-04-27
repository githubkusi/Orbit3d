function hAxes = getCurrentOrCreateUiAxes(hParent)
if nargin == 0
    hParent = gfx.getCurrentOrCreateUiFigure;
end

hAxes = findobj(hParent, 'type', 'axes');
if isempty(hAxes)
    hAxes = uiaxes(hParent, Parent=hParent);

    if isa(hParent, 'matlab.ui.Figure')
        % Matlab 2021b doesn't center a new uiaxes in a uifigure, as it did
        % with the old axes. Maybe this can vanish again with a newer
        % Matlab version
        hAxes.Units = 'normalized';
        hAxes.Position = [0.05 0.05 0.9 0.9];
    end
    
end