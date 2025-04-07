function txt = text(h, displayName)
arguments
    h matlab.graphics.chart.primitive.Line
    displayName = h.DisplayName
end

txt = displayName;
if strlength(txt) == 0
    if h.LineStyle == "none"
        txt = 'point';
    else
        txt = 'line';
    end
end