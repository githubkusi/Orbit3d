function toggleTransparency(hObj)
hPatch = findobj(hObj, Type='patch');

if ~isempty(hPatch)
    if hPatch(1).FaceAlpha == 1
        set(hPatch, "FaceAlpha", 0.3);
    else
        set(hPatch, "FaceAlpha", 1);
    end
end