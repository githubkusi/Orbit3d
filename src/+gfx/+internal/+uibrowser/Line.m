classdef Line < handle
    methods (Static)
        function hButton = createGuiElement(hParent, hObj)
            hButton = uibutton(hParent, 'state');
            hButton.Value = hObj.Visible;
            hButton.Text = hObj.DisplayName;
            hButton.ValueChangedFcn = @gfx.internal.uibrowser.Line.visibleStateChanged;
            hButton.UserData.hObj = hObj;
            hButton.BackgroundColor = hObj.Color;
        end

        function visibleStateChanged(btn, evnt)
            btn.UserData.hObj.Visible = evnt.Value;
        end
    end
end