classdef UiBrowser < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        hFigure
        showNamelessItems = false
    end

    methods
        function self = UiBrowser(hFigure)
            arguments
                hFigure matlab.ui.Figure = gcf
            end
            self.hFigure = hFigure;
            self.buildGui;
        end

        function buildGui(self)
            hBrowser = findobj('Tag', 'browser');

            colorProperty = dictionary('patch', 'FaceColor', 'line', 'Color');


            glBrowser = uigridlayout(hBrowser, [2 1]);
            glBrowser.RowHeight = {'1x' 35};

            % each axes has its own layout
            glParentAxes = uigridlayout(glBrowser, [1 2]);

            % Tools
            glTools = uigridlayout(glBrowser, [1 1]);
            uicheckbox(glTools, ...
                "ValueChangedFcn", @self.showNamelessItemsChanged, ...
                Text="Show items with empty name", ...
                Value=self.showNamelessItems);

            for hAxes = findobj(self.hFigure, 'type', 'axes')'
                h = findobj(hAxes, 'type', 'patch', '-or', 'type', 'line');

                if isempty(h)
                    % axes has no content (e.g gui elements)
                    continue
                end

                gl = uigridlayout(glParentAxes, [1 1]);
                gl.BackgroundColor = [0.97 0.97 0.97];

                for k = 1:length(h)
                    if ~isempty(h(k).DisplayName) || self.showNamelessItems
                        hButton = uibutton(gl, 'state');
                        hButton.Value = h(k).Visible;
                        hButton.Text = h(k).DisplayName;
                        hButton.ValueChangedFcn = @self.isVisibleStateChanged;
                        hButton.UserData.hObj = h(k);
                        hButton.BackgroundColor = h(k).(colorProperty(h(k).Type));
                    end
                end
            end
        end

        function isVisibleStateChanged(~, btn, evnt)
            btn.UserData.hObj.Visible = evnt.Value;
        end

        function showNamelessItemsChanged(self, cbx, evnt)
            self.showNamelessItems = evnt.Value;
            self.buildGui;
        end

    end
end