classdef UiBrowser < handle
    %UIBROWSER graphic object browser
    %   Replacement of Matlab's old plotbrowser

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

        function windowKeyPressCallback(~, ~, evnt)
            switch evnt.Key
                case 'q'
                    delete(findobj('Tag', 'browser'))
            end
        end

        function buildGui(self)
            hBrowser = findobj('Tag', 'browser');
            hBrowser.WindowKeyPressFcn = @self.windowKeyPressCallback;

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

                if self.showNamelessItems && numel(h) > 4 || ...
                        ~self.showNamelessItems && numel(findobj(hAxes, 'type', 'patch', '-or', 'type', 'line', '-not', 'DisplayName','')) > 4
                    gridSize = [1 2];
                else
                    gridSize = [1 1];
                end

                gl = uigridlayout(glParentAxes, gridSize);
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

        function showNamelessItemsChanged(self, ~, evnt)
            self.showNamelessItems = evnt.Value;
            self.buildGui;
        end

    end
end