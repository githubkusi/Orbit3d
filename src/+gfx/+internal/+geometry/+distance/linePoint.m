function [dist, closestPts, t] = linePoint(lineP0, lineV, pts)
%POINTLINE distance between line(s) and point(s)
%   [dist, closestPts, t] = geometry.distance.linePoint(lineP0, lineV, pts)
%
%   Calculate shortest distance of points p to line l
%
%   INPUT
%     lineP0, lineV: [3xN] Line = lineP0 + t*lineV (may be not normalized)
%     pts:           [3xM] Points
%
%   OUTPUT
%     dist:       [1xQ] Distance between point and line
%     closestPts: [3xQ] Closest point on the line
%                       closestPts = lineP0 + lineV*t
%     t           [1xQ] Line parameter
%
%   One of the following conditions must be met:
%     M==1,  Q=N
%     N==1,  Q=M
%     M==N,  Q=M=N
%
%   copied from
%   http://softsurfer.com/Archive/algorithm_0102/algorithm_0102.htm#dist_Point_to_Line()


sp = size(pts,2);
sl0 = size(lineP0,2);
sl1 = size(lineV,2);
assert(sl0 == sl1,'inconsistent line');

if sp ~= sl0
    assert(sp==1 || sl0==1,'only one of line,point can have more than one element')
    lineP0 = repmat(lineP0, 1, sp);
    lineV = repmat(lineV, 1, sp);
    pts = repmat(pts, 1, sl0);
end

w = pts - lineP0;

c1 = dot(w, lineV);
c2 = dot(lineV, lineV);
t = c1./c2;
closestPts = lineP0 + repmat(t, size(lineP0, 1), 1).*lineV;
dist = sqrt(sum(pts-closestPts.^2));


