hFigure = uifigure("Name", "Orbit3d (Press h for help)");
hAxes = uiaxes(hFigure);

% enable 3d orbit on the axis
gfx.orbit3d(hAxes);

% load & plot sample mesh
mesh = load('trimesh3d');
hPatch = patch("parent", hAxes, ...
    "Vertices", [mesh.x mesh.y mesh.z], ...
    "Faces", mesh.tri, ...
    "FaceColor", "y");
