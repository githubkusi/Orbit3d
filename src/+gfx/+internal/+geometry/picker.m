function [pt, triangleId]=picker(hObj)
%GEOMETRY.PICKER
%  [pt, triangleId]=geometry.picker(hObj)
%
%IN
%  hObj: matlab.graphics.primitive.Patch
%        matlab.graphics.chart.primitive.Surface
%
%OUT
%  pt: [3x1], point under mouse cursor on object
%      Empty if not hit
%
%  triangleId: triangle id containing the clicked point on surface

triangleId=[];

if isa(hObj,'matlab.graphics.primitive.Patch')
    [pt, triangleId] = gfx.internal.geometry.pick.matlabPatch(hObj);

elseif isa(hObj,'matlab.graphics.chart.primitive.Surface')
    pt = gfx.internal.geometry.pick.matlabSurface(hObj);
else
    pt = [];
end