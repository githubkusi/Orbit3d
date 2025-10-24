function hBrowser = uibrowser(hFigure)
%GFX.UIBROWSER Graphical object browser
%  hBrowserFigure = gfx.uibrowser
%  hBrowserFigure = gfx.uibrowser(hFigure)
%
%  gfx.uibrowser intends to be a replacement for Matlab's "plotbrowser"
%  and also works with new web based "uifigure" (in contrast to plotbrowser,
%  which only supports the old java-based "figure")
%
%  USAGE
%    Press "b" in a figure to launch uibrowser
%
%  KEYBOARD SHORTCUTS
%    "c": toggle color of selected node
%    "t": toggle transparency of selected node (for patch only)
%
%  FEATURES
%  - One browser figure per object figure
%  - Supports objects of type patch/line/hggroup/text
%  - Supports multiple axes in one figure
%  - Visibility on/off
%  - Color copied from object, however object style is not yet reflected in
%    the browser window
%  - Close browser window with key "q"
%  - Items are named according <graphichandle>.DisplayName.
%  - A hggroup is represented as corresponding tree in a uitree object
%
%  EXAMPLE
%    Run "example_uibrowser"
%
%  AUTHOR
%    Copyright 2022-2025, Markus Leuthold, markus.leuthold@sonova.com
%
%  LICENSE
%    BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)
arguments
    hFigure = groot().CurrentFigure
end

if isempty(hFigure)
    disp("No figure found")
    return
end

assert(isgraphics(hFigure) && hFigure.Type == "figure", 'Input must be a figure object')

if ~isfield(hFigure.UserData, 'uiBrowser') || ~hFigure.UserData.uiBrowser.hasValidBrowserWindow
    hBrowser = uifigure(Tag="browser", HandleVisibility="off");
    hBrowser.Name = 'Object Browser';
    hFigure.UserData.uiBrowser = gfx.internal.UiBrowser(hBrowser, hFigure);
end

% focus browser figure
figure(hFigure.UserData.uiBrowser.hBrowser);

hFigure.UserData.uiBrowser.buildGui;