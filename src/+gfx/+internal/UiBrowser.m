classdef UiBrowser < handle
    %UIBROWSER graphic object browser
    %   Replacement of Matlab's old plotbrowser

    properties
        showNamelessItems = false
        hBrowser
        hFigure
    end

    methods
        function self = UiBrowser(hBrowser, hFigure)
            self.hBrowser = hBrowser;
            self.hFigure = hFigure;
            self.hBrowser.WindowKeyPressFcn = @self.windowKeyPressCallback;
        end

        function windowKeyPressCallback(self, ~, evnt)
            switch evnt.Key
                case 'q'
                    delete(self.hBrowser)

                case 'b'
                    self.buildGui;
            end
        end

        function buildGui(self)
            % kill window if the corresponding figure is gone
            if ~isgraphics(self.hFigure)
                delete(self.hBrowser)
                return
            end

            % cleanup if there was a previous browser figure
            delete(self.hBrowser.Children)

            guiElement = dictionary(...
                'patch', @gfx.internal.uibrowser.Patch, ...
                'line',  @gfx.internal.uibrowser.Line, ...
                'hggroup', @gfx.internal.uibrowser.HgGroup);

            glBrowser = uigridlayout(self.hBrowser, [2 1]);
            glBrowser.RowHeight = {'1x' 35};

            % each axes has its own layout
            numAxes = numel(findobj(self.hFigure, 'type', 'axes'));
            glParentAxes = uigridlayout(glBrowser, [1 numAxes]);

            % Tools
            glTools = uigridlayout(glBrowser, [1 1]);
            uicheckbox(glTools, ...
                "ValueChangedFcn", @(~, evnt)self.showNamelessItemsChanged(evnt.Value), ...
                Text="Show items with empty DisplayName", ...
                Value=self.showNamelessItems, ...
                Tooltip="Show object even if the property 'DisplayName' of the graphic handle is empty");

            for hAxes = findobj(self.hFigure, 'type', 'axes')'
                hGroups = findobj(hAxes, 'type', 'hggroup');
                hPatchOrLine = findobj(hAxes, 'type', 'patch', '-or', 'type', 'line');

                % don't dive into groups
                % ancestor returns cell if there are several hits but an
                % empty double if there are no hits
                hParentGroup = ancestor(hPatchOrLine, 'hggroup');
                if isempty(hParentGroup)
                    h = [hGroups; hPatchOrLine];
                else
                    isNotInGroup = cellfun(@isempty, hParentGroup);
                    h = [hGroups; hPatchOrLine(isNotInGroup)];
                end

                if isempty(h)
                    % axes has no content (e.g gui elements)
                    continue
                end

                hasNoDisplayName = arrayfun(@(hk)isempty(hk.DisplayName), h);
                if self.showNamelessItems
                    numItems = numel(h);
                else
                    numItems = nnz(~hasNoDisplayName);
                end

                if numItems == 0
                    continue
                end

                gridSize = [1 floor(sqrt(numItems))];

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

        function showNamelessItemsChanged(self, value)
            self.showNamelessItems = value;
            self.buildGui;
        end

        function tf = hasValidBrowserWindow(self)
            tf = isgraphics(self.hBrowser);
        end
    end
end