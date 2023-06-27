function col = color(h)
arguments
    h matlab.graphics.primitive.Patch
end
if ischar(h.FaceColor) && ismember(h.FaceColor, {'interp', 'flat'})
    col = mean(h.FaceVertexCData, 1);
else
    col = h.FaceColor;
end