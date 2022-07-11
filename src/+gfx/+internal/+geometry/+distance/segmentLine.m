function [dist, pSeg, pLine, tSeg, tLine] = segmentLine(segP0, segP1, lineP0, lineV)
[pSeg, pLine, tSeg, tLine] = gfx.internal.geometry.distance.lineLine(segP0, segP1-segP0, lineP0, lineV);

%crop at begin if necessary
[~, pLineNeg, tLineNeg] = gfx.internal.geometry.distance.linePoint(lineP0, lineV, segP0);
iNeg = tSeg<0;
pSeg(:,iNeg) = segP0(:,iNeg);
pLine(:,iNeg) = pLineNeg(:,iNeg);
tSeg(iNeg) = 0;
tLine(iNeg) = tLineNeg(iNeg);

%crop at end if necessary
[~, pLinePos, tLinePos] = gfx.internal.geometry.distance.linePoint(lineP0, lineV, segP1);
iPos = tSeg>1;
pSeg(:,iPos) = segP1(:,iPos);
pLine(:,iPos) = pLinePos(:,iPos);
tSeg(iPos) = 1;
tLine(iPos) = tLinePos(iPos);

dist = sqrt(sum(pSeg - pLine.^2));
