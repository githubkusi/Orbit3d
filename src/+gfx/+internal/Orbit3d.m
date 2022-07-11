classdef Orbit3d < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        currentPoint % xy
    end

    methods
        function self = Orbit3d(hAxes)
            hFig = ancestor(hAxes, 'figure');
            hFig.WindowButtonDownFcn = @self.buttonDownCallback;
            hFig.WindowScrollWheelFcn = @self.scrollWheelCallback;
            hFig.KeyPressFcn = @self.keyPressCallback;
            hAxes.DataAspectRatio = [1 1 1];
            hAxes.CameraTargetMode = 'manual';
            hAxes.CameraViewAngleMode = 'manual';
            axis(hAxes, 'off')
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

            switch hFig.SelectionType
                case 'normal'
                    self.getOrNewLight(hAxes);
                    hFig = ancestor(hAxes, 'figure');
                    hFig.WindowButtonMotionFcn = @self.buttonMotionCallback;
                    hFig.WindowButtonUpFcn = @self.buttonUpCallback;
                    self.currentPoint = hFig.CurrentPoint;

                case 'alt'
                    pickedPoint = gfx.internal.geometry.picker(hFig.CurrentObject);
                    if ~isempty(pickedPoint)
                        hAxes.CameraTarget = pickedPoint';
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
            hAxes = self.findAxesOfCurrentObject(hFig);
            switch keyData.Character
                case 'r'
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
            hAxes.CameraViewAngleMode = 'auto';
            hAxes.CameraTargetMode = 'auto';
            drawnow;
            hAxes.CameraViewAngleMode = 'manual';
            hAxes.CameraTargetMode = 'manual';
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
            if isa(hObj, 'matlab.graphics.primitive.Patch')
                [r, g, b] = meshgrid(0:1,0:1,0:1);
                rgb = [r(:) g(:) b(:)];
                [~, idx] = min(sum(abs(rgb - hObj.FaceColor), 2));
                hObj.FaceColor = rgb(gfx.internal.math.mod1(idx + 1, 8), :);
            end
        end

        function toggleHelp(~, hFig)
            
        end
    end
end

