hGrid = uigridlayout([1 2]);

hAxes1 = uiaxes("Parent", hGrid);
hAxes2 = uiaxes("Parent", hGrid);

gfx.orbit3d(hAxes1)
gfx.orbit3d(hAxes2)

mesh = load('trimesh3d');

hPatch1 = patch("parent", hAxes1, "Vertices", [mesh.x mesh.y mesh.z], "Faces", mesh.tri, "FaceColor", "y");
hPatch2 = patch("parent", hAxes2, "Vertices", [mesh.x mesh.y mesh.z], "Faces", mesh.tri, "FaceColor", "r");