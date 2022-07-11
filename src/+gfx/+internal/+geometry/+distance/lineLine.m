function [pA, pB, tA, tB] = lineLine(lineAp0, lineAv, lineBp0, lineBv)
%LINELINE Distance between lines and one line
%  [pA, pB, tA, tB] = geometry.distance.lineLine(lineAp0, lineAv, lineBp0, lineBv)
%
%  INPUT
%    lineAp0, lineAv: [3xN], lines = lineAp0 + tA*lineAv
%    lineBp0, lineBv: [3x1], line = lineBp0 + tB*lineBv
%
%  OUTPUT
%    pA, pB:  [3xN]


assert(size(lineBp0, 2) == 1, 'LineLineDistance:NotSingleLine', 'Second line must be a single line')

%http://geomalgorithms.com/a07-_distance.html
u = lineAv;
v = lineBv + zeros(size(lineAv));
w0 = lineAp0-lineBp0;
a = dot(u,u);
b = dot(u,v);
c = dot(v,v);
d = dot(u,w0);
e = dot(v,w0);

tA = (b.*e-c.*d)./(a.*c-b.*b);
tB = (a.*e-b.*d)./(a.*c-b.*b);

pA = lineAp0 + tA.*u;
pB = lineBp0 + tB.*v;