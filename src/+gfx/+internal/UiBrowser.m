classdef UiBrowser < handle
    %UIBROWSER graphic object browser
    %   Replacement of Matlab's old plotbrowser

    properties
        showNamelessItems = false
    end

    methods
        function self = UiBrowser(hFigure)
            arguments
                hFigure matlab.ui.Figure = gcf
            end
            self.buildGui(hFigure);
        end

        function windowKeyPressCallback(self, ~, evnt)
            switch evnt.Key
                case 'q'
                    delete(findobj('Tag', 'browser'))

                case 'b'
                    self.buildGui;
            end
        end

        function buildGui(self, hFigure)
            hBrowser = findobj('Tag', 'browser');

            % cleanup if there was a previous browser figure
            delete(hBrowser.Children)

            hBrowser.WindowKeyPressFcn = @self.windowKeyPressCallback;

            guiElement = dictionary(...
                'patch', @gfx.internal.uibrowser.Patch, ...
                'line',  @gfx.internal.uibrowser.Line);

            glBrowser = uigridlayout(hBrowser, [2 1]);
            glBrowser.RowHeight = {'1x' 35};

            % each axes has its own layout
            numAxes = numel(findobj(hFigure, 'type', 'axes'));
            glParentAxes = uigridlayout(glBrowser, [1 numAxes]);

            % Tools
            glTools = uigridlayout(glBrowser, [1 1]);
            uicheckbox(glTools, ...
                "ValueChangedFcn", @(~, evnt)self.showNamelessItemsChanged(hFigure, evnt.Value), ...
                Text="Show items with empty DisplayName", ...
                Value=self.showNamelessItems, ...
                Tooltip="Show object even if the property 'DisplayName' of the graphic handle is empty");

            for hAxes = findobj(hFigure, 'type', 'axes')'
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
                        fcn = guiElement(h(k).Type);
                        fcn().createGuiElement(gl, h(k));
                    end
                end
            end
        end

        function showNamelessItemsChanged(self, hFigure, value)
            self.showNamelessItems = value;
            self.buildGui(hFigure);
        end
    end
end