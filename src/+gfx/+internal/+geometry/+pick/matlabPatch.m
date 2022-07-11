function [pt, triangleId] = matlabPatch(hPatch, cursorline)
%GEOMETRY.PICK.MATLABPATCH picker on matlab patch
%
%  [pt, triangleId] = geometry.pick.matlabPatch(hPatch)
%  [pt, triangleId] = geometry.pick.matlabPatch(hPatch, cursorline)
%
%  IN
%     hPatch:     matlab.graphics.primitive.Patch
%     cursorline: Segment/Line/Ray. If omitted, the cursorline is taken
%                 from the parent axes of hPatch
%  OUT
%     pt:         [3x1] or [] if no hit
%     triangleId:
%
%  AUTHOR
%    Copyright 2022, Markus Leuthold, markus.leuthold@sonova.com
%
%  LICENSE
%    BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)

if nargin==1
    hAxis = ancestor(hPatch, 'axes');
    d = hAxis.CurrentPoint;
    rayP0 = d(1,:)';rayV = d(2,:)'-d(1,:)';
else
    rayP0 = cursorline.p0.p;
    rayV = cursorline.v.p;
end

try
    % embree based
    [isHit, pt, triangleId, t, u, v] = geometry.mexRayCast(hPatch.Vertices', hPatch.Faces, rayP0, rayV); %#ok<ASGLU>

catch err
    assert(err.identifier == "MATLAB:undefinedVarOrClass")
    % matlab based, 3rd party

    v1 = hPatch.Vertices(hPatch.Faces(:,1), :);
    v2 = hPatch.Vertices(hPatch.Faces(:,2), :);
    v3 = hPatch.Vertices(hPatch.Faces(:,3), :);

    [isHit, t, ~, ~, pts] = gfx.internal.geometry.TriangleRayIntersection(rayP0, rayV, v1, v2, v3);
    if any(isHit)
        idx = find(isHit);
        [~, triangleId] = min(t(isHit));
        pt = pts(idx(triangleId), :)';
    else
        pt = [];
    end
end
