function hBrowser = uibrowser(hFigure)
%GFX.UIBROWSER Graphical object browser
%  hBrowserFigure = gfx.uibrowser
%  hBrowserFigure = gfx.uibrowser(hFigure)
%
%  gfx.uibrowser intends to be a replacement for Matlab's plotbrowser()
%  and also workswith new web based uifigures (in contrast to plotbrowser,
%  which only supports the old java-based figures)
%
%  FEATUES
%  - One browser figure per object figure
%  - Supports multiple axes in one figure
%  - Visibility on/off
%  - Color copied from object, however object style is not yet reflected in
%    the browser window
%  - Close browser window with key "q"
%
%  AUTHOR
%    Copyright 2022-2023, Markus Leuthold, markus.leuthold@sonova.com
%
%  LICENSE
%    BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)
arguments
    hFigure matlab.ui.Figure = gcf
end

hBrowser = findobj('Tag', 'browser');
if isempty(hBrowser)
    hBrowser = uifigure(Tag="browser", HandleVisibility="on");
    hBrowser.Name = 'Object Browser';
    hBrowser.UserData.uiBrowser = gfx.internal.UiBrowser(hFigure);
else
    hBrowser.UserData.uiBrowser.buildGui(hFigure);
end