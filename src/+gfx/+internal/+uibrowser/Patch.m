classdef Patch < handle
    methods (Static)
        function createGuiElement(hParent, hObj)
            hButton = uibutton(hParent, 'state');
            hButton.Value = hObj.Visible;
            hButton.Text = hObj.DisplayName;
            hButton.ValueChangedFcn = @gfx.internal.uibrowser.Patch.visibleStateChanged;
            hButton.UserData.hObj = hObj;

            if ischar(hObj.FaceColor) && ismember(hObj.FaceColor, {'interp', 'flat'})
                col = mean(hObj.FaceVertexCData, 1);
            else
                col = hObj.FaceColor;
            end
            hButton.BackgroundColor = col;
        end

        function visibleStateChanged(btn, evnt)
            btn.UserData.hObj.Visible = evnt.Value;
        end
    end
end