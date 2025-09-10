function txt = text(displayName)
arguments
    displayName
end

if strlength(displayName) > 0
    txt = displayName;
else
    txt = "patch";
end
