function hUiFig = currentUiFigure
% Return the current uifigure or create a new one if no uifigure exists.
% Does not affect the old java figures
hRoot = groot;
hFigs = findobj(hRoot.Children, 'type', 'figure');
hUiFigs = hFigs(arrayfun(@matlab.ui.internal.isUIFigure, hFigs));

if isempty(hUiFigs)
    hUiFig = uifigure("HandleVisibility", "on");
else
    % the first figure in the array is the current one
    hUiFig = hUiFigs(1);
end