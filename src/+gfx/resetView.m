function resetView(hAxes)
arguments
    hAxes = gca
end
hAxes.CameraViewAngleMode = 'auto';
hAxes.CameraTargetMode = 'auto';
hAxes.CameraPositionMode = 'auto';
drawnow;
hAxes.CameraViewAngleMode = 'manual';
hAxes.CameraTargetMode = 'manual';
hAxes.CameraPositionMode = 'manual';