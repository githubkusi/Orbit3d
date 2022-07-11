function [dist, segIdx, pCurve, tCurve, pLine, tLine] = curveLine(ptsCurve, p0Line, vLine)
%CURVELINE distance between line and interpolated curve
%  [dist, segIdx, pCurve, tCurve, pLine, tLine] = geometry.distance.curveLine(ptsCurve, p0Line, vLine)
%
%  OUTPUT
%    dist     [1x1] distance of line to closest interpolated point of curve
%    segIdx   [1x1] Interpolated closest point lies on segment <segIdx>
%    pCurve   [3x1] Closest interpolated point
%    tCurve   [1x1] pCurve = normalized length from begin to pCurve
%    pLine    [1x1] Closest point on line
%    tLine    [1x1] pLine = p0Line + tLine * vLine

segP0 = ptsCurve(:, 1:end-1);
segP1 = ptsCurve(:, 2:end);
[dists, pSegs, pLines, ~, tLines] = gfx.internal.geometry.distance.segmentLine(segP0, segP1, p0Line, vLine);

[~, segIdx] = min(sqrt(sum(pSegs - pLines.^2)));
pCurve = pSegs(:, segIdx);
pLine = pLines(:, segIdx);
tLine = tLines(segIdx);
dist = dists(segIdx);

lenghtToClosestPoint = gfx.internal.geometry.curve.length([ptsCurve(:, 1:segIdx) pCurve]);
tCurve = lenghtToClosestPoint / gfx.internal.geometry.curve.length(ptsCurve);


%% alternative algo: 
% %First get the closest point rather than checking distance to each segment.
% %This performs better for many points than the algo above, but has more
% %function calls.
% % 
% % Get closest real point. Closest point is either on the previous or next
% % segment
% distLinePoints = geometry.distance.linePoint(p0Line, vLine, ptsCurve);
% [~, idxClosest] = min(distLinePoints);
% 
% % Get previous/next segment of real point
% [idx0, idx1] = geometry.curve.surroundingSegmentIdxOfPointIdx(ptsCurve, idxClosest);
% p0 = ptsCurve(:, idx0);
% p1 = ptsCurve(:, idx1);
% 
% % distance of pre/post-segment to line
% [dists, pSegs, pLines, ~, tLines] = geometry.distance.segmentLine(p0, p1, p0Line, vLine);
% 
% % choose between pre and post
% [~, idxPrePost] = min(math.length(pSegs - pLines));
% pCurve = pSegs(:, idxPrePost);
% pLine = pLines(:, idxPrePost);
% tLine = tLines(idxPrePost);
% segIdx = idx0(idxPrePost);
% dist = dists(idxPrePost);
% 
% lenghtToClosestPoint = geometry.curve.length([ptsCurve(:, 1:segIdx) pCurve]);
% tCurve = lenghtToClosestPoint / geometry.curve.length(ptsCurve);