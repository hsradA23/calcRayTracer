# calcRayTracer
A ray tracer written in lua for the Ti Nspire CX - II

## The Engine

The scene has to be edited by changing the source code. The default example has 2 spheres placed on a plane, illuminated by
a point source of light above them.

![1abfc18a-9087-42c7-9f3c-534679c5c44b](https://user-images.githubusercontent.com/86849857/227121781-530733a9-e856-48a6-a493-70c93dfb02ed.jpeg)

the `objects` global variable contains a list of all the objects present in the scene. Each object has its own properties,
described in the beginning of each class decleration.

The program checks whether it is being run on a calculator by checking the `platform` environment variable. If it is on the calculator, the output is painted on the display, otherwise a bitmap image called `p6.bpm` is saved in the current working directory.

The `b2m.lua` file is used from [rosettacode.org](https://rosettacode.org/wiki/Bitmap#Alternate) and is only used to check the the image generated on a computer, it is only used for debugging.

## Shapes
The following shapes are supported by the renderer:
- 2D Plane
- Sphere

## Colours
The colours are stored as vectors, as it was necessary to save on the little memory that we have on the calculator.
instead of the object being interpreted as `{x,y,z}` for coordinated, it is interpreted as `{R,G,B}` for colour values.
