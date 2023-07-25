function hBrowser = uibrowser(hFigure)
arguments
    hFigure matlab.ui.Figure = gcf
end

hBrowser = findobj('Tag', 'browser');
if isempty(hBrowser)
    hBrowser = uifigure(Tag="browser", HandleVisibility="on");
    hBrowser.Name = 'Object Browser';
    hBrowser.UserData.uiBrowser = gfx.internal.UiBrowser(hFigure);
end