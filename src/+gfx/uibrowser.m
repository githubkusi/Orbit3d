function hBrowser = uibrowser(hFigure)
arguments
    hFigure = gcf
end

hBrowser = findobj('Tag', 'browser');
if isempty(hBrowser)
    hBrowser = uifigure(Tag="browser", HandleVisibility="on");
    hBrowser.Name = 'Object Browser';
end

colors = dictionary('patch', 'FaceColor', 'line', 'Color');

% each axes has its own layout
glAxes = uigridlayout("Parent", hBrowser);

for hAxes = findobj(hFigure, 'type', 'axes')'
    h = findobj(hAxes, 'type', 'patch', '-or', 'type', 'line');

    gl = uigridlayout("Parent", glAxes);
    gl.BackgroundColor = [0.97 0.97 0.97];

    for k = 1:length(h)
        if ~isempty(h(k).DisplayName)
            hButton = uibutton(gl, 'state');
            hButton.Value = h(k).Visible;
            hButton.Text = h(k).DisplayName;
            hButton.ValueChangedFcn = @stateChanged;
            hButton.UserData.hObj = h(k);
            hButton.BackgroundColor = h(k).(colors(h(k).Type));
        end
    end
end

function stateChanged(btn, evnt)
btn.UserData.hObj.Visible = evnt.Value;