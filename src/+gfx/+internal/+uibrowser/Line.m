classdef Line < handle
    methods (Static)
        function hButton = createGuiElement(hParent, hLine)
            hButton = uibutton(hParent, 'state');
            hButton.Value = hLine.Visible;
            hButton.Text = gfx.internal.uibrowser.line.text(hLine);
            hButton.ValueChangedFcn = @gfx.internal.uibrowser.Line.visibleStateChanged;
            hButton.UserData.hObj = hLine;
            hButton.BackgroundColor = hLine.Color;
            hButton.FontColor = gfx.internal.uibrowser.fontColor(...
                hButton.BackgroundColor,  hButton.FontColor);
        end

        function visibleStateChanged(btn, evnt)
            btn.UserData.hObj.Visible = evnt.Value;
        end
    end
end