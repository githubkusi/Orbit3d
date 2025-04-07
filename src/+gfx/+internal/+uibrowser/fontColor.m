function fontColor = fontColor(backgroundColor, fontColor)

% make text readable
if vecnorm(backgroundColor - fontColor) < 1.1
    fontColor = 1 - backgroundColor;
end
