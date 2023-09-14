mesh = load('trimesh3d');

%% equivalent to cla(): create a new figure with a new axes if no figure exists yet
gfx.clearUiAxes3d;
patch("Vertices", [mesh.x mesh.y mesh.z], "Faces", mesh.tri, "FaceColor", "y");

%% equivalent to figure(): always create a new figure
gfx.newUiFigure3d;
patch("Vertices", [mesh.x mesh.y mesh.z], "Faces", mesh.tri, "FaceColor", "r");

%% equivalent to cla(): clear the red mesh of the current figure and plot a new blue one
gfx.clearUiAxes3d;
patch("Vertices", [mesh.x mesh.y mesh.z], "Faces", mesh.tri, "FaceColor", "b");
