classdef Orbit3d < handle
    %ORBIT3D Interactive axes for rotateable and editable 3d objects
    %   o3d = gfx.internal.Orbit3d;
    %
    %   USER INTERACTIONS
    %     Right mouse click & move: Rotate objects
    %     Right double-click:       Set rotation center
    %     Left click:               User defined callback
    %     Scroll wheel:             Zoom towards to/away from mouse pointer
    %     Key r:                    Reset view
    %     Key t:                    Toggle transparency of selected obj
    %     Key w:                    Toggle wireframe of selected patch
    %     Key c:                    Toggle color of selected obj
    %     Key h:                    Show help
    %
    %   USER DEFINED RIGHT-CLICK
    %     hFig.UserData.RightButtonDownFcn is called on right mouse down with
    %     hFig.CurrentObject as parameter
    %     hFig.UserData.RightButtonUpFcn is called on right mouse up with
    %     hFig.CurrentObject as parameter
    %
    %   USAGE
    %     Instance of Orbit3d needs to be kept in memory
    %
    %   NOTES
    %     Orbit3d works for both the old java-based axes and the new web-based
    %     uiaxes()
    %
    %   AUTHOR
    %     Copyright 2022, Markus Leuthold, markus.leuthold@sonova.com
    %
    %   LICENSE
    %     BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)

    properties
        currentPoint % xy
    end

    methods
        function self = Orbit3d(hAxes)
            hFig = ancestor(hAxes, 'figure');
            hFig.WindowButtonDownFcn = @self.buttonDownCallback;
            hFig.WindowButtonUpFcn = @self.buttonUpCallback;
            hFig.WindowScrollWheelFcn = @self.scrollWheelCallback;
            hFig.KeyPressFcn = @self.keyPressCallback;
            hAxes.DataAspectRatio = [1 1 1];
            hAxes.CameraTargetMode = 'auto';
            hAxes.CameraViewAngleMode = 'auto';
            hAxes.CameraPositionMode = 'auto';
            hAxes.CameraUpVectorMode = 'auto';
            axis(hAxes, 'off');
            hold(hAxes, 'on');
            self.getOrNewLight(hAxes);
        end

        function hLight = getOrNewLight(~, hAxes)
            hLight = findobj(hAxes, 'type', 'Light');
            if isempty(hLight)
                hLight = light('parent', hAxes);
                hLight.Position = hAxes.CameraPosition;
            end
        end

        function hAxes = findAxesOfCurrentObject(~, hFig)
            hAxes = ancestor(hFig.CurrentObject, 'axes');
            if isempty(hAxes)
                % user didn't click on object. If there is only one axes,
                % the intention of the user is unambigous, return the only
                % axes
                h = findobj(hFig, 'type', 'axes');
                if isa(h, 'matlab.ui.control.UIAxes') && numel(h) == 1
                    hAxes = h;
                end
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
            hAxes = self.findAxesOfCurrentObject(hFig); %#ok<*PROPLC>
            if isempty(hAxes)
                return
            end

            hAxes.CameraPositionMode = 'manual';
            hAxes.CameraUpVectorMode = 'manual';
            hAxes.CameraViewAngleMode = 'manual';
            hAxes.CameraTargetMode = 'manual';

            switch hFig.SelectionType
                case 'normal'
                    self.getOrNewLight(hAxes);
                    hFig = ancestor(hAxes, 'figure');
                    hFig.WindowButtonMotionFcn = @self.buttonMotionCallback;
                    self.currentPoint = hFig.CurrentPoint;

                case 'open'
                    pickedPoint = gfx.internal.geometry.picker(hFig.CurrentObject);
                    if ~isempty(pickedPoint)
                        hAxes.CameraTarget = pickedPoint';
                    end

                case 'alt'
                    if isfield(hFig.UserData, 'RightButtonDownFcn')
                        hFig.UserData.RightButtonDownFcn(hFig.CurrentObject)
                    end
            end
        end

        function buttonMotionCallback(self, hFig, ~)
            hAxes = self.findAxesOfCurrentObject(hFig);
            cpDelta = hFig.CurrentPoint - self.currentPoint;
            self.currentPoint = hFig.CurrentPoint;

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
            hLight.Position = xfNewCam(1:3, 4)';
        end

        function buttonUpCallback(~, hFig, ~)
            hFig.WindowButtonMotionFcn = [];
            if isfield(hFig.UserData, 'RightButtonUpFcn')
                hFig.UserData.RightButtonUpFcn(hFig.CurrentObject)
            end
        end

        function scrollWheelCallback(self, hFig, scrollWheelData)
            hAxes = self.findAxesOfCurrentObject(hFig);
            oldPoints = hAxes.CurrentPoint';

            %ds =  3: scrollwheel up (away from user)
            %ds = -3: scrollwheel down (towards user)
            ds = scrollWheelData.VerticalScrollCount * scrollWheelData.VerticalScrollAmount;

            %setup
            %w: viewing angle
            %s: subjective size, seems to have quadratic relation with w
            %   s = 0 -> nearest position
            %   s = r -> furthest position
            %   w(s)=a*s^2 + c
            wFar = 30;  %angle far
            wNear = 0.01; %angle near
            r = 35;   %range: go in r clicks from near to far
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
            if isempty(hFig.CurrentObject) && keyData.Character ~= 'h'
                disp('Click first on an object')
            end

            switch keyData.Character
                case 'r'
                    hAxes = self.findAxesOfCurrentObject(hFig);
                    self.resetView(hAxes)

                case 'w'
                    self.toggleWireframe(hFig.CurrentObject)

                case 't'
                    self.toggleTransparency(hFig.CurrentObject)

                case 'c'
                    self.toggleColor(hFig.CurrentObject)

                case 'h'
                    self.toggleHelp(hFig)
            end
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

        function toggleColor(~, hObj)
            [r, g, b] = meshgrid(0:1,0:1,0:1);
            rgb = [r(:) g(:) b(:)];

            switch class(hObj)
                case 'matlab.graphics.primitive.Patch'
                    [~, idx] = min(sum(abs(rgb - hObj.FaceColor), 2));
                    hObj.FaceColor = rgb(gfx.internal.math.mod1(idx + 1, 8), :);

                case 'matlab.graphics.chart.primitive.Line'
                    [~, idx] = min(sum(abs(rgb - hObj.Color), 2));
                    hObj.Color = rgb(gfx.internal.math.mod1(idx + 1, 8), :);
            end
        end

        function toggleHelp(~, hFig)
            hHelp = findobj(hFig, "Tag", "help");
            if isempty(hHelp)
                uilabel("Parent",hFig,"Text","right click: rotate obj",                     "Position", [10 10 200 20], "Tag","help");
                uilabel("Parent",hFig,"Text","double right click: set new rotation center", "Position", [10 30 300 20], "Tag","help");
                uilabel("Parent",hFig,"Text","r: reset view",                               "Position", [10 50 200 20], "Tag","help");
                uilabel("Parent",hFig,"Text","w: wireframe",                                "Position", [10 70 200 20], "Tag","help");
                uilabel("Parent",hFig,"Text","c: next color",                               "Position", [10 90 200 20], "Tag","help");
                uilabel("Parent",hFig,"Text","t: transparency",                             "Position", [10 110 200 20], "Tag","help");
            else
                delete(hHelp)
            end
        end
    end
end

