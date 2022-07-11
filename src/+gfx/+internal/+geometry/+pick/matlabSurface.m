function pt = matlabSurface(hSurface, cursorline)
%GEOMETRY.PICK.MATLABSURFACE
%
%  pt = geometry.pick.matlabSurface(surf)
%
%  IN
%    surf: matlab.graphics.chart.primitive.Surface
%  OUT
%    pt:   primitives.Point
%
%  surf perpendicular to screen plane is not supported

n = hSurface.FaceNormals(:,:)';
assert(all(size(n)==[3 1]),'unknown case, needs investigation');
p = [hSurface.XData(1);hSurface.YData(1);hSurface.ZData(1)];

coeff = gfx.internal.geometry.plane.coeffsFromPointAndNormal(p, n);

if nargin==1
    hAxis = ancestor(hSurface,'axes');
    d = hAxis.CurrentPoint;
    p0 = d(1,:)';
    v = d(2,:)'-d(1,:)';
else
    p0 = cursorline.p0.p;
    v = cursorline.v.p;
end

pt = gfx.internal.geometry.intersect.linePlane(coeff, p0, v);