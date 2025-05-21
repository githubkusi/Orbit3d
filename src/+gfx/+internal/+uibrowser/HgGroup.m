classdef HgGroup < handle
    methods (Static)
        function hButton = createGuiElement(hParent, hGroup)
            [col, txt] = gfx.internal.uibrowser.HgGroup.getColorAndType(hGroup);
            hButton = uibutton(hParent, 'state');
            hButton.Value = hGroup.Visible;
            hButton.Text = txt;
            hButton.ValueChangedFcn = @gfx.internal.uibrowser.HgGroup.visibleStateChanged;
            hButton.UserData.hObj = hGroup;
            hButton.BackgroundColor = col;
            hButton.FontColor = gfx.internal.uibrowser.fontColor(...
                hButton.BackgroundColor,  hButton.FontColor);
        end

        function [col, txt] = getColorAndType(hGroup)
            arguments
                hGroup matlab.graphics.primitive.Group
            end

            % First element in returned array is always used to set the
            % color in the legend, no matter where in the scenegraph the
            % object is located
            h = findobj(hGroup, 'type', 'patch', '-or', 'type', 'line');

            % DisplayName is always taken from the hggroup. DisplayName of
            % the childern is ignored
            switch h(1).Type
                case 'line'
                    col = h(1).Color;
                    txt = gfx.internal.uibrowser.line.text(h(1), hGroup.DisplayName);

                case 'patch'
                    col = gfx.internal.uibrowser.patch.color(h(1));
                    txt = gfx.internal.uibrowser.patch.text(hGroup.DisplayName);

                otherwise
                    warning('color picking/text not yet implemented, use default');
                    col = 'w';
                    txt = h.Type;
            end
        end

        function visibleStateChanged(btn, evnt)
            btn.UserData.hObj.Visible = evnt.Value;
        end
    end
end