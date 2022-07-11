function [is, t] = linePlane(planeCoeff, linePoint, lineDir)
%  [is, t] = geometry.intersect.linePlane(planeCoeff, linePoint, lineDir)
%
%  INPUT
%    planeCoeff:  [1x4]           : plane coeffs
%    linePoint:   [3 x nLines]    : point on line
%    lineDir:     [3 x nLines]    : direction of line
%
%  OUTPUT
%    is:   [3 x nLines]    : intersection points
%    t:    [1 x nLines]    : is = linePoint + t*lineDir
%
%  AUTHOR
%    Copyright 2022, Markus Leuthold, markus.leuthold@sonova.com
%
%  LICENSE
%    BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)

nLines = size(linePoint, 2);
is = zeros(3, nLines);
t = zeros(1, nLines);

[m, u, v] = gfx.internal.geometry.plane.norm2parametric(planeCoeff);
planePoints = [m, m+u, m+v];

% mathworld.wolfram.com/Line-PlaneIntersection.html
% TODO: get rid of the forloop and do it matlab style
for k = 1:nLines
    A = [1 1 1 1;planePoints linePoint(:,k)];
    B = [1 1 1 0;planePoints lineDir(:,k)];
    t(k) = -det(A)/det(B);
    is(:,k) = linePoint(:,k) + t(k)*lineDir(:,k);
end