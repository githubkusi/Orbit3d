function d = segmentsLength(p)
%SEGMENTSLENGTH distance between curve points
%  d = geometry.distance.segmentsLength(c)
%
%  INPUT
%    c: [DxN] consecutive 2d or 3d points
%
%  OUTPUT
%    d: [1 x N-1] distances between the points
N = size(p, 2);
p_n = p(:,1:(N-1));
p_nplus1 = p(:,2:N);
d = gfx.internal.geometry.distance.pointPoint(p_n, p_nplus1);

