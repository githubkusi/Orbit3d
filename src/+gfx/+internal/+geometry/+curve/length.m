function len = length(p)
% LENGTH Full length of curve
%   len = geometry.curve.length(p)
%
%   INPUT
%     p: [DxN]
%
%   OUTPUT
%     len: [1x1]
len = sum(gfx.internal.geometry.curve.segmentsLength(p));
