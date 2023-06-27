function hBrowser = uibrowser
hBrowser = findobj('Tag', 'browser');
if isempty(hBrowser)
    hBrowser = uifigure(Tag="browser", HandleVisibility="on");
    hBrowser.Name = 'Object Browser';
end

h = findobj('type', 'patch', '-or', 'type', 'line');

gl = uigridlayout("Parent", hBrowser);

colors = dictionary('patch', 'FaceColor', 'line', 'Color');

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

function stateChanged(btn, evnt)
btn.UserData.hObj.Visible = evnt.Value;