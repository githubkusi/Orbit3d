classdef HgGroup < handle
    methods (Static)
        function hButton = createGuiElement(hParent, hObj)
            hButton = uibutton(hParent, 'state');
            hButton.Value = hObj.Visible;
            hButton.Text = hObj.DisplayName;
            hButton.ValueChangedFcn = @gfx.internal.uibrowser.HgGroup.visibleStateChanged;
            hButton.UserData.hObj = hObj;

            % try different things
            if isprop(hObj.Children(1), 'FaceColor')
                % patch or surface
                col = hObj.Children(1).FaceColor;
            else
                % default
                col = 'w';
            end

            hButton.BackgroundColor = col;
        end

        function visibleStateChanged(btn, evnt)
            btn.UserData.hObj.Visible = evnt.Value;
        end
    end
end