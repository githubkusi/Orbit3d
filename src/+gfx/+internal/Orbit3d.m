classdef Orbit3d < handle
    %ORBIT3D Interactive axes for rotateable and editable 3d objects
    %   o3d = gfx.internal.Orbit3d;
    %
    %   USER INTERACTIONS
    %     Left mouse click & move:  Rotate objects
    %     Double click:             Set rotation center
    %     Right click:              User defined callback
    %     Scroll wheel:             Zoom towards to/away from mouse pointer
    %                               Use <shift> to change the zoom factor
    %     Key r:                    Reset view
    %     Key t:                    Toggle transparency of selected obj
    %     Key w:                    Toggle wireframe of selected patch
    %     Key c:                    Toggle color of selected obj
    %     Key g:                    Toggle grid
    %     Key b:                    Show object browser
    %     Key h:                    Show help
    %
    %   USAGE
    %     Instance of Orbit3d needs to be kept in memory
    %
    %   NOTES
    %     Orbit3d works for both the old java-based axes and the new web-based
    %     uiaxes()
    %
    %     For registering additional keyboard or mouse callbacks, you must
    %     use gfx.FigureEventDispatcher() in order not to destroy Orbit3d's
    %     callbacks
    %
    %     Example of adding a right mouse click callback on hAxes
    %        gfx.FigureEventDispatcher.addAxesEvent(...
    %          "WindowMousePress", @(~,~)disp('right mouse btn'), hAxes, @(f,~)f.SelectionType == "alt");
    %
    %     Example of adding a global keyboard shortcut on hFigure
    %        gfx.FigureEventDispatcher.addFigureEvent(...
    %          "KeyPress", @(~,evnt)disp(evnt.Key), hFigure);
    %
    %   AUTHOR
    %     Copyright 2022-2023, Markus Leuthold, markus.leuthold@sonova.com
    %
    %   LICENSE
    %     BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)

    properties
        currentPoint % xy
        motionEventUid
        keyboardShortcuts
        slowZoom = false
    end

    methods
        function self = Orbit3d(hAxes)
            self.keyboardShortcuts.ResetView = 'r';
            self.keyboardShortcuts.Wireframe = 'w';
            self.keyboardShortcuts.Transparency = 't';
            self.keyboardShortcuts.Color = 'c';
            self.keyboardShortcuts.Grid = 'g';
            self.keyboardShortcuts.Help = 'h';
            self.keyboardShortcuts.ObjectBrowser = 'b';

            gfx.FigureEventDispatcher.addAxesEvent(...
                "WindowMousePress", @self.buttonDownCallback, hAxes);
            self.motionEventUid = gfx.FigureEventDispatcher.addAxesEvent(...
                "WindowMouseMotion", @(~, ~)[], hAxes);
            gfx.FigureEventDispatcher.addAxesEvent(...
                "WindowMouseRelease", @self.buttonUpCallback, hAxes);
            gfx.FigureEventDispatcher.addAxesEvent(...
                "WindowScrollWheel", @self.scrollWheelCallback, hAxes);
            gfx.FigureEventDispatcher.addAxesEvent(...
                "KeyPress", @self.keyPressCallback, hAxes);
            gfx.FigureEventDispatcher.addAxesEvent(...
                "KeyRelease", @self.keyReleaseCallback, hAxes);

            hAxes.DataAspectRatio = [1 1 1];

            % axis off keeps hAxes.Title.Visible enabled
            axis(hAxes, 'off');

            hold(hAxes, 'on');
            self.getOrNewLight(hAxes);
        end

        function tf = isAxesObject(~, h)
            % a ui control such as a slider is of no interest for Orbit3d
            %
            % Reject
            % - matlab.ui.control.{Button, Slider, ...} (web)
            % - matlab.ui.control.UIControl (java)
            %
            % Accept
            % - matlab.ui.control.UIAxes (web, inherits matlab.graphics.axis.Axes)
            % - matlab.graphics.axis.Axes (java)
            % - matlab.graphics.* (patch, line)
            % - matlab.ui.container.GridLayout
            % - matlab.ui.Figure (covers both java and web figure)

            % isa(h, 'matlab.graphics.axis.Axes') covers both java and web axes
            cls = class(h);
            tf = ~startsWith(cls, "matlab.ui.control") || isa(h, 'matlab.graphics.axis.Axes');
        end

        function hLight = getOrNewLight(~, hAxes)
            hLight = findobj(hAxes, 'type', 'Light');
            if isempty(hLight)
                hLight = light('parent', hAxes);
                hLight.Position = hAxes.CameraPosition - hAxes.CameraTarget;
            end
        end

        function xf = getCameraTransform(~, hAxes)
            x = hAxes.CameraUpVector';
            z = hAxes.CameraTarget' -  hAxes.CameraPosition';
            y = cross(z, x);
            xf = eye(4);
            xf(1:3, 1:3) = [x y z]./vecnorm([x y z]);
            xf(1:3, 4) = hAxes.CameraPosition';
        end

        function setCameraTransform(~, hAxes, xf)
            hAxes.CameraPosition = xf(1:3,4)';
            hAxes.CameraUpVector = xf(1:3,1)';
        end

        function buttonDownCallback(self, hFig, ~)
            if ~self.isAxesObject(hFig.CurrentObject)
                % Interacting with a GUI element such as a slider would as
                % well trigger Orbit3d which is unwanted
                return
            end

            hAxes = hFig.CurrentAxes;
            if isempty(hAxes)
                return
            end

            hAxes.CameraPositionMode = 'manual';
            hAxes.CameraUpVectorMode = 'manual';
            hAxes.CameraViewAngleMode = 'manual';
            hAxes.CameraTargetMode = 'manual';

            switch hFig.SelectionType
                case 'normal'
                    % left click
                    self.getOrNewLight(hAxes);
                    hFig = ancestor(hAxes, 'figure');
                    gfx.FigureEventDispatcher.editEvent(hAxes, self.motionEventUid, @self.buttonMotionCallback)
                    self.currentPoint = hFig.CurrentPoint;

                case 'open'
                    % double click
                    pickedPoint = gfx.internal.geometry.picker(hFig.CurrentObject);
                    if ~isempty(pickedPoint)
                        hAxes.CameraTarget = pickedPoint';
                    end
            end
        end

        function buttonMotionCallback(self, hFig, ~)
            cpDelta = hFig.CurrentPoint - self.currentPoint;
            self.currentPoint = hFig.CurrentPoint;
            self.updateRotation(hFig.CurrentAxes, cpDelta)
        end

        function buttonUpCallback(self, hFig, ~)
            gfx.FigureEventDispatcher.editEvent(hFig.CurrentAxes, self.motionEventUid, @(~,~)[]);
        end

        function scrollWheelCallback(self, hFig, scrollWheelData)
            hAxes = hFig.CurrentAxes;
            if isempty(hAxes)
                return
            end

            oldPoints = hAxes.CurrentPoint';

            % VerticalScrollCount
            %   1: scrollwheel up (away from user)
            %  -1: scrollwheel down (towards user)
            if self.slowZoom
                zoomFactor = 0.2;
            else
                zoomFactor = scrollWheelData.VerticalScrollAmount;
            end
            ds = scrollWheelData.VerticalScrollCount * zoomFactor;

            %setup
            %w: viewing angle
            %s: subjective size, seems to have quadratic relation with w
            %   s = 0 -> nearest position
            %   s = r -> furthest position
            %   w(s)=a*s^2 + c
            wFar = 30;  %angle far
            wNear = 0.01; %angle near
            r = 70;   %range: go in r clicks from near to far
            a = (wFar-wNear)/r^2;    %a,b,c: coeffs of quad eq
            c = wNear;

            %get current s
            w = camva(hAxes);
            z = roots([a 0 (c-w)]);
            s = max(z);

            %new s
            s = s+ds;
            if s<0,s = 0;end
            if s>r,s = r;end

            %new angle
            w = a*s^2+c;

            %set new angle
            camva(hAxes, w)

            %Old ax.CurrentPoint was under the cursor before the zoom. move it back under
            %the cursor
            currentPoints = hAxes.CurrentPoint';
            [~, new] = gfx.internal.geometry.distance.linePoint(oldPoints(:,1), oldPoints(:,2)-oldPoints(:,1), currentPoints(:,1));
            v = new - currentPoints(:,1);
            hAxes.CameraTarget = hAxes.CameraTarget + v';
        end

        function keyPressCallback(self, hFig, keyData)
            if ~isa(hFig.CurrentObject, 'matlab.graphics.primitive.Patch') && ~isempty(keyData.Character) && ismember(keyData.Character, {self.keyboardShortcuts.Wireframe self.keyboardShortcuts.Transparency self.keyboardShortcuts.Color})
                disp('Click first on an object')
            end

            switch keyData.Character
                case self.keyboardShortcuts.ResetView
                    hAxes = hFig.CurrentAxes;
                    self.resetView(hAxes)

                case  self.keyboardShortcuts.Wireframe
                    self.toggleWireframe(hFig.CurrentObject)

                case self.keyboardShortcuts.Transparency
                    self.toggleTransparency(hFig.CurrentObject)

                case self.keyboardShortcuts.Color
                    self.toggleColor(hFig)

                case self.keyboardShortcuts.Grid
                    self.toggleGrid(hFig.CurrentAxes)

                case self.keyboardShortcuts.ObjectBrowser
                    gfx.uibrowser(hFig);

                case self.keyboardShortcuts.Help
                    self.toggleHelp(hFig)
            end

            self.slowZoom = keyData.Key == "shift";
        end

        function keyReleaseCallback(self, ~, keyData)
            if keyData.Key == "shift"
                self.slowZoom = false;
            end
        end

        function updateRotation(self, hAxes, cpDelta)
            speed = 0.02;
            w = cpDelta * speed;
            xfCam = self.getCameraTransform(hAxes);

            qx = gfx.internal.math.Quaternion.angleaxis(w(2), [0;1;0]);
            qy = gfx.internal.math.Quaternion.angleaxis(-w(1), [1;0;0]);
            q = qx*qy;

            xfQ = eye(4);
            xfQ(1:3, 1:3) = q.RotationMatrix;

            dstCam = norm(hAxes.CameraPosition - hAxes.CameraTarget);
            v = eye(4);
            v(1:3, 4) = [0;0;1]*dstCam;

            xfNewCam = xfCam * v * xfQ * inv(v); %#ok<MINV>

            self.setCameraTransform(hAxes, xfNewCam)

            hLight = self.getOrNewLight(hAxes);
            hLight.Position = hAxes.CameraPosition - hAxes.CameraTarget;
        end

        function resetView(~, hAxes)
            gfx.resetView(hAxes);
        end

        function toggleWireframe(~, hObj)
            if isa(hObj, 'matlab.graphics.primitive.Patch')
                if isequal(hObj.EdgeColor, "none")
                    hObj.EdgeColor = 'k';
                else
                    hObj.EdgeColor = 'none';
                end
            end
        end

        function toggleTransparency(~, hObj)
            if isa(hObj, 'matlab.graphics.primitive.Patch')
                if hObj.FaceAlpha == 1
                    hObj.FaceAlpha = 0.3;
                else
                    hObj.FaceAlpha = 1;
                end
            end
        end

        function toggleColor(self, hFig)
            [r, g, b] = meshgrid(0:1,0:1,0:1);
            rgb = [r(:) g(:) b(:)];

            hObj = hFig.CurrentObject;
            switch class(hObj)
                case 'matlab.graphics.primitive.Patch'
                    if ischar(hObj.FaceColor)
                        idx = 1;
                    else
                        [~, idx] = min(sum(abs(rgb - hObj.FaceColor), 2));
                    end
                    hObj.FaceColor = rgb(gfx.internal.math.mod1(idx + 1, 8), :);

                case 'matlab.graphics.chart.primitive.Line'
                    [~, idx] = min(sum(abs(rgb - hObj.Color), 2));
                    hObj.Color = rgb(gfx.internal.math.mod1(idx + 1, 8), :);
            end

            self.updateBrowser(hFig);
        end

        function toggleGrid(~, hAxes)
            hAxes.Visible = ~hAxes.Visible;
            grid(hAxes, "on");
            xlabel(hAxes, "x");
            ylabel(hAxes, "y");
            zlabel(hAxes, "z");
        end

        function toggleHelp(~, hFig)
            hHelp = findobj(hFig, "Tag", "help");
            if isempty(hHelp)
                uilabel("Parent",hFig,"Text","left click & move: rotate obj",               "Position", [10 10 200 20], "Tag","help");
                uilabel("Parent",hFig,"Text","double click: set new rotation center",       "Position", [10 30 300 20], "Tag","help");
                uilabel("Parent",hFig,"Text","scroll wheel: zoom (slow zoom with <shift>)", "Position", [10 50 300 20], "Tag","help");
                uilabel("Parent",hFig,"Text","r: reset view",                               "Position", [10 70 200 20], "Tag","help");
                uilabel("Parent",hFig,"Text","w: wireframe",                                "Position", [10 90 200 20], "Tag","help");
                uilabel("Parent",hFig,"Text","c: next color",                               "Position", [10 110 200 20], "Tag","help");
                uilabel("Parent",hFig,"Text","t: transparency",                             "Position", [10 130 200 20], "Tag","help");
                uilabel("Parent",hFig,"Text","g: grid",                                     "Position", [10 150 200 20], "Tag","help");
                uilabel("Parent",hFig,"Text","b: object browser",                           "Position", [10 170 200 20], "Tag","help");
            else
                delete(hHelp)
            end
        end

        function updateBrowser(~, hFig)
            if isfield(hFig.UserData, 'uiBrowser') && hFig.UserData.uiBrowser.hasValidBrowserWindow
                hFig.UserData.uiBrowser.buildGui;
            end
        end
    end
end

