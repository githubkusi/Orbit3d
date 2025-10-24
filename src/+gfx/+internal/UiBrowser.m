classdef UiBrowser < handle
    %UIBROWSER graphic object browser
    %   Replacement of Matlab's old plotbrowser

    properties
        hBrowser
        hFigure
        hSelectedObj
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

                case 't'
                    self.toggleTransparency;

                case 'c'
                    self.toggleColor;
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

            % objects and tools
            hGrid = uigridlayout(self.hBrowser, [2 1], RowHeight=["1x" "fit"]);

            % each axes has its own layout
            numAxes = numel(findobj(self.hFigure, 'type', 'axes'));
            glParentAxes = uigridlayout(hGrid, [1 numAxes]);

            for hAxes = findobj(self.hFigure, 'type', 'axes')'

                hTreeRoot = uitree(glParentAxes, "checkbox", Tag="ObjectTree");
                hTreeRoot.CheckedNodesChangedFcn = @self.checkedNodesChanged;
                hTreeRoot.SelectionChangedFcn = @self.selectionChangedFcn;

                self.buildTreeLevel(hTreeRoot, hAxes, isTopLevel=true)
            end

            % tools
            hToolsGrid = uigridlayout(hGrid, [2 1], ...
                RowHeight=["fit" "fit"], ...
                Tag="ToolsGrid");
            uibutton(hToolsGrid, ...
                Text="Clear selected object", ...
                ButtonPushedFcn=@self.clearSelectedObject, ...
                Tag="ClearSelectedObject", ...
                Enable="off");
            uibutton(hToolsGrid, ...
                Text="Property inspector", ...
                ButtonPushedFcn=@self.openPropertyInspector, ...
                Tag="PropertyInspector", ...
                Enable="off");
        end

        function clearSelectedObject(self, ~, ~)
            delete(self.hSelectedObj);
            self.buildGui;
        end

        function openPropertyInspector(self, ~, ~)
            if isdeployed
                %#exclude inspect
                disp("'inspect' is non-deployable")
            else
                inspect(self.hSelectedObj)
            end
        end

        function selectionChangedFcn(self, ~, selectedNodesChangedData)
            node = selectedNodesChangedData.SelectedNodes;
            hToolsGrid = findobj(self.hBrowser, 'Tag', 'ToolsGrid');
            [hToolsGrid.Children.Enable] = deal(~isempty(node));

            if ~isempty(node)
                self.hSelectedObj = selectedNodesChangedData.SelectedNodes.NodeData.hObj;
            end


        end

        function buildTreeLevel(self, hParent, hObjRoot, pv)
            arguments
                self
                hParent, hObjRoot,
                pv.isTopLevel logical = false;
            end

            style.patch = @self.patchStyle;
            style.line = @self.lineStyle;
            style.hggroup = @self.hggroupStyle;
            style.text = @self.textStyle;

            for hObj = hObjRoot.Children'
                if ~ismember(hObj.Type, ["hggroup" "patch" "line" "text"])
                    % e.g. light
                    continue
                end

                [color, txt] = style.(hObj.Type)(hObj);
                hNode = uitreenode(Parent=hParent, Text=txt);
                hNode.NodeData.hObj = hObj;
                nodeStyle = uistyle(...
                    BackgroundColor=color, ...
                    FontColor=gfx.internal.uibrowser.fontColor(color, [0 0 0]));
                hTreeRoot = ancestor(hNode,  'matlab.ui.container.CheckBoxTree');
                hTreeRoot.addStyle(nodeStyle, "node", hNode);

                if hObj.Type == "hggroup"
                    self.buildTreeLevel(hNode, hObj);
                end

                if pv.isTopLevel && hObj.Visible
                    hTreeRoot.CheckedNodes = [hTreeRoot.CheckedNodes; hNode];
                end
            end
        end

        function tf = hasValidBrowserWindow(self)
            tf = isgraphics(self.hBrowser);
        end

        function checkedNodesChanged(~, hTree, ~)
            hNode = hTree.SelectedNodes;
            isChecked = ismember(hNode, hTree.CheckedNodes);
            hNode.NodeData.hObj.Visible = isChecked;
        end

        function [color, txt] = patchStyle(~, h)
            if ischar(h.FaceColor) && ismember(h.FaceColor, {'interp', 'flat'})
                color = mean(h.FaceVertexCData, 1);
            else
                color = h.FaceColor;
            end

            if strlength(h.DisplayName) > 0
                txt = h.DisplayName;
            else
                txt = "patch";
            end
        end

        function [color, txt] = lineStyle(~, hLine)
            color = hLine.Color;

            if strlength(hLine.DisplayName) > 0
                txt = hLine.DisplayName;
            else
                if hLine.LineStyle == "none"
                    txt = 'point';
                else
                    txt = 'line';
                end
            end
        end

        function [color, txt] = hggroupStyle(~, hGroup)
            arguments
                ~
                hGroup matlab.graphics.primitive.Group
            end

            % First element in returned array is always used to set the
            % color in the legend, no matter where in the scenegraph the
            % object is located
            h = findobj(hGroup, 'type', 'patch', '-or', 'type', 'line');

            if isempty(h)
                % e.g text?
                color = 'w';
                txt = hGroup.DisplayName;
                return
            end

            % DisplayName is always taken from the hggroup. DisplayName of
            % the childern is ignored
            switch h(1).Type
                case 'line'
                    color = h(1).Color;
                    txt = gfx.internal.uibrowser.line.text(h(1), hGroup.DisplayName);

                case 'patch'
                    color = gfx.internal.uibrowser.patch.color(h(1));
                    txt = gfx.internal.uibrowser.patch.text(hGroup.DisplayName);

                case 'text'
                    color = [1 1 1];
                    txt = 'text';

                otherwise
                    warning('color picking/text not yet implemented, use default');
                    color = 'w';
                    txt = h.Type;
            end
        end

        function [color, txt] = textStyle(~, hText)
            txt = hText.DisplayName;
            if isempty(txt)
                txt = 'text';
            end
            color = [1 1 1];
        end

        function toggleTransparency(self)
            hTree = findobj(self.hBrowser, Tag="ObjectTree");
            assert(isscalar(hTree), "multiple axes not yet supported")
            gfx.internal.toggleTransparency(hTree.SelectedNodes.NodeData.hObj)
        end

        function toggleColor(self)
            hTree = findobj(self.hBrowser, Tag="ObjectTree");
            assert(isscalar(hTree), "multiple axes not yet supported")
            hSelectedNode = hTree.SelectedNodes;
            color = gfx.internal.toggleColor(hSelectedNode.NodeData.hObj);

            nodeStyle = uistyle(...
                BackgroundColor=color, ...
                FontColor=gfx.internal.uibrowser.fontColor(color, [0 0 0]));

            hTree.removeStyle(find([hTree.StyleConfigurations.TargetIndex{:}] == hSelectedNode))
            hTree.addStyle(nodeStyle, Node=hSelectedNode)
        end
    end
end