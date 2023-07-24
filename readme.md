# Orbit3d for Matlab
User-friendly, feature rich replacement of Matlab's `cameratoolbar`

Matlab lacks a powerful and user friendly interactive tool to handle 3d objects in a plot. Matlab's own `cameratoolbar` doesn't allow to zoom in/out with the scroll wheel, does not set the light properly and has a quite esoteric orbit function. Furthermore, as of Matlab 2022a, `cameratoolbar` does not support the new web-based `uiaxes`

This toolbox implements a quaternion based 3d orbit. Multiple axes are supported, thanks to a newly implemented per-axes (rather than Matlab's own per-figure) event handler.

## Features
|Event|Action  |
|--|--|
|Right click & move  | Rotate objects |
|Right double-click| Set rotation center|
|Left click |User defined callback |
|Scroll wheel |Zoom towards to/away from mouse pointer |
|Key r |Reset view |
|Key t |Toggle transparency of selected obj |
|Key w |Toggle wireframe of selected patch |
|Key c|Toggle color of selected obj |
|Key h |Show help |

## Example code

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

Please find more examples in the folder `examples`

## Installation

    addpath('src')
or, if you use [ToolboxToolbox](https://github.com/ToolboxHub/ToolboxToolbox)

    tbUse('Orbit3d')

## Keywords
Matlab, interactive, orbit, orbit3d, 3d, quaternion, geometry, rotation, axes, uiaxes, figure, plot, visualization, patch, mesh, graphics

## Author
Copyright 2022-2023, Markus Leuthold, markus.leuthold@sonova.com

## License
BSD-3-Clause (https://opensource.org/licenses/BSD-3-Clause)
