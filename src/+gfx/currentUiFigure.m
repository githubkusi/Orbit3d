function hFig = currentUiFigure
hRoot = groot;
hFigs = findobj(hRoot.Children, 'type', 'figure', '-not', 'tag', 'browser');

if isempty(hFigs)
    hFig = uifigure("HandleVisibility", "on");
else
    % the first figure in the array is the current one
    hFig = hFigs(1);
end