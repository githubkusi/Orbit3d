function [pt, dst] = matlabLine(hLine)
%GEOMETRY.PICK.MATLABLINE picker on matlab.graphics.primitive.Line
%
%  [pt, distance] = geometry.pick.matlabLine(line)
%
%  IN
%     line:       matlab.graphics.primitive.Line
%                 matlab.graphics.chart.primitive.Line
%  OUT
%     pt:         primitives.Point on the line
%     dist:       Distance from the picked point to the line
%
%  AUTHOR
%    Copyright 2022, Markus Leuthold, markus.leuthold@sonova.com
%
%  LICENSE
%    BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)

hAxis = ancestor(hLine, 'axes');
d = hAxis.CurrentPoint;
lineP0 = d(1,:)';
lineV = d(2,:)'-d(1,:)';
ptsCurve = [hLine.XData;hLine.YData;hLine.ZData];
[dst, ~, ~, ~, pt] = gfx.internal.geometry.distance.curveLine(ptsCurve, lineP0, lineV);