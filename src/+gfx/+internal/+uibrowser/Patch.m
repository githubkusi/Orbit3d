classdef Patch < handle
    methods (Static)
        function createGuiElement(hParent, hPatch)
            hButton = uibutton(hParent, 'state');
            hButton.Value = hPatch.Visible;
            hButton.Text = gfx.internal.uibrowser.patch.text(hPatch.DisplayName);
            hButton.ValueChangedFcn = @gfx.internal.uibrowser.Patch.visibleStateChanged;
            hButton.UserData.hObj = hPatch;
            hButton.BackgroundColor = gfx.internal.uibrowser.patch.color(hPatch);
            hButton.FontColor = gfx.internal.uibrowser.fontColor(...
                hButton.BackgroundColor,  hButton.FontColor);
        end

        function visibleStateChanged(btn, evnt)
            btn.UserData.hObj.Visible = evnt.Value;
        end
    end
end