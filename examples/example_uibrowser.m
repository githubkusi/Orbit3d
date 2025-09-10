gfx.clearUiAxes3d;
mesh = load('trimesh3d');
hPatch = patch("Vertices", [mesh.x mesh.y mesh.z], "Faces", mesh.tri);
hPatch.FaceColor = "y";
hPatch.DisplayName = "3d model";

hLine = plot3([0;0],[0;0], [-10;100]);
hLine.DisplayName = "line";

gfx.uibrowser;
