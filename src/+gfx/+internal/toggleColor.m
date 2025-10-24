function col = toggleColor(hObj)
[r, g, b] = meshgrid(0:1,0:1,0:1);
rgb = [r(:) g(:) b(:)];
col = [];

hPatch = findobj(hObj, Type='patch');
if ~isempty(hPatch)
    if ischar(hPatch(1).FaceColor)
        idx = 1;
    else
        [~, idx] = min(sum(abs(rgb - hPatch(1).FaceColor), 2));
    end
    col = rgb(gfx.internal.math.mod1(idx + 1, 8), :);
    set(hPatch, "FaceColor", col);
end

hLine = findobj(hObj, Type='line');
if ~isempty(hLine)
    [~, idx] = min(sum(abs(rgb - hLine(1).Color), 2));
    col = rgb(gfx.internal.math.mod1(idx + 1, 8), :);
    set(hLine, "Color", col);
end
