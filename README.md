# ShapeWizard
Copyright 2021 Cadence Design Systems, Inc. All rights reserved worldwide.

This script automates the generation of grids and/or database
entities for common, simple shapes - boxes, cones, spheres, and
sweeps.

![ShapeWizardTk](https://raw.github.com/pointwise/ShapeWizard/master/ShapeWizaard-Tk.png)

# How It Works

## Attributes

Type: The basic entity type to be created - Box, Cone, Sphere, or Sweep

Surface Type: A Baffle will be open while a Farfield will be closed

Entity Type: The script can generate Grid entities, Database entities, or both

Grid Type: Any grids made will either be structured quads or unstructured triangles

Dimension: You can specify the I, J, and K dimensions of structured grids.

Average Ds: You can set the average spacing to be used for unstructured grids.

## Specifications and Type-Specific Data

The inputs in this section vary depending on the Type of shape being 
created.  Furthermore, you have the option to either set the 
specifications Explicitly or set them Interactively by selection
locations in the Display wondow.

The bottom frame of the GUI includes Type-specific information.

### Box

Size: The Length, Width, and Height of the box

Origin: The box is centered on this 3D coordinate

Orientation: A box created as a baffle can be have two sides open 
along one axis direction.

### Cone

Size: The Height, first Radius, and second Radius of the cone

Origin: The 3D coordinate of the circle at the center of the first Radius

Orientation: The axis along which the cone lies.

### Sphere

Radius: The radius of the sphere

Origin: The center of the sphere

Portion: You can specify whether to make a full sphere, hemisphere 
or a quarter sphere.

### Sweep

Size: the Length and Width of the sweep surface

Origin: The coordinates of the origin of the sweep

Plane: You can specify the plane in which the sweep surface lies.

## Script Files

- ShapeWizard.glf is the main script, the one you execute from Pointwise.
- sw_Box.glf consists of the functions used for Box shapes
- sw_Cone.glf consists of the functions used for Cone shapes
- sw_Sphere.glf consists of the functions used for Sphere shapes
- sw_Sweep.glf consists of the functions used for Sweep shapes

## Disclaimer
This file is licensed under the Cadence Public License Version 1.0 (the "License"), a copy of which is found in the LICENSE file, and is distributed "AS IS." 
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE. 
Please see the License for the full text of applicable terms.
