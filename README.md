# ShapeWizard

This script automates the generation of grids and/or database
entities for common, simple shapes - boxes, cones, spheres, and
sweeps.

![ShapeWizardTk](https://raw.github.com/pointwise/ShapeWizard/master/ShapeWizard-Tk.png)

# How It Works

## Attributes

Type: The basic entity type to be created - Box, Cone, Sphere, or Sweep

Surface Type: A Baffle will be open while a Farfield will be closed

Entity Type: The script can generate Grid entities, Database entities, or both

Grid Type: Any grids made will either be structured quads or unstructured triangles

Dimension: You can specify the I, J, and K dimensions of structured grids.

Average Ds: You can set the average spacing to be used for unstructured grids.

## Specifications

The inputs in this section vary depending on the setting of the Type 
attribute. Furthermore, you have the option to either set the specificationsexplicitly using the Explicit controls or select them Interactively from 
the Display window using Interactive Mode.

### Box

Size: The Length, Width, and Height of the box

Origin: The box is centered on this 3D coordinate

### Cone

Size: The Height, first Radius, and second Radius of the cone

Origin: The 3D coordinate of the circle at the center of the first Radius

### Sphere

Radius: The radius of the sphere

Origin: The center of the sphere

### Sweep

Size: the Length and Width of the sweep surface

Origin: The coordinates of the origin of the sweep

## Optional

The lower left frame offers options that vary per shape Type.

### Box

A box created as a baffle can be have two sides open along one axis direction.

### Cone

You can specify the axis along which the cone lies.

### Sphere

You can specify whether to make a full sphere, hemisphere or a quartersphere.

### Sweep

You can specify the plane in which the sweep surface lies.





## Disclaimer

Scripts are freely provided. They are not supported products of 
Pointwise, Inc. Some scripts have been written and contributed by 
third parties outside of Pointwise's control.

TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, WITH REGARD TO THESE SCRIPTS. TO THE MAXIMUM EXTENT PERMITTED
BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS
INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR
INABILITY TO USE THESE SCRIPTS EVEN IF POINTWISE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE FAULT OR NEGLIGENCE OF
POINTWISE.

