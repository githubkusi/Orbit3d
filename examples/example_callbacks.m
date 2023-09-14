hGrid = uigridlayout([1 2]);
hGrid.Parent.Name = "Orbit3d for multiple axes (Press h for help)";

hAxes1 = uiaxes("Parent", hGrid);
hAxes2 = uiaxes("Parent", hGrid);

gfx.orbit3d(hAxes1);
gfx.orbit3d(hAxes2);

mesh = load('trimesh3d');

hPatch1 = patch("parent", hAxes1, "Vertices", [mesh.x mesh.y mesh.z], "Faces", mesh.tri, "FaceColor", "y");
hPatch2 = patch("parent", hAxes2, "Vertices", [mesh.x mesh.y mesh.z], "Faces", mesh.tri, "FaceColor", "r");

% right click on first axes changes mesh color
gfx.FigureEventDispatcher.addAxesEvent(...
    "WindowMousePress", @(~,~)set(hPatch1, 'FaceColor', rand(1, 3)), ...
    hAxes1, @(f,~)f.SelectionType == "alt");

% pressing v toggles hAxes1 visibility, no matter what is the current object
gfx.FigureEventDispatcher.addFigureEvent(...
    "KeyPress", @(~,ev)toggleAxesVisibility(hAxes1, ev.Key), hGrid.Parent);

function toggleAxesVisibility(hAxes, key)
if isequal(key, 'v')
    hAxes.Visible = ~ hAxes.Visible;
end
end