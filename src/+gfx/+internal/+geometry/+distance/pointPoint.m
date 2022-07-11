function dst = pointPoint(a, b)
%POINTPOINT geometric length of each column vector
%  d  = geometry.distance.pointPoint(a, b)
%
%  IN
%    a,b: [dxN] where d = dimensionality
%
%  OUT
%    l = geometric length of each column [1xN]
dst = sqrt(sum((a-b).^2));