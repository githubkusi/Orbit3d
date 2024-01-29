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
%  - Items are named according <graphichandle>.DisplayName. If DisplayName
%    is empty, the object doesn't appear in the browser by default.
%
%  AUTHOR
%    Copyright 2022-2023, Markus Leuthold, markus.leuthold@sonova.com
%
%  LICENSE
%    BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)
arguments
    hFigure matlab.ui.Figure = gcf
end

if ~isfield(hFigure.UserData, 'uiBrowser') || ~hFigure.UserData.uiBrowser.hasValidBrowserWindow
    hBrowser = uifigure(Tag="browser", HandleVisibility="off");
    hBrowser.Name = 'Object Browser';
    hFigure.UserData.uiBrowser = gfx.internal.UiBrowser(hBrowser, hFigure);
end

% focus browser figure
figure(hFigure.UserData.uiBrowser.hBrowser);

hFigure.UserData.uiBrowser.buildGui;