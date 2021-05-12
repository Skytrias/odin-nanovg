# odin-nanovg
Bindings for [nanovg](https://github.com/memononen/nanovg)
Like the nanovg example you can use [odin-gl](https://github.com/vassvik/odin-gl) + [odin-glfw](https://github.com/vassvik/odin-glfw)

## Building
Before you use nanovg you have to build a nanovg library first. I'll give an example. The bindings expect a `nanovg.a` to exist on **linux**

```c
// main.c on linux
#include <stdio.h>
#include <math.h>
#include <GL/gl.h>
#include "stb_truetype.h"
#include "nanovg.h"
#include "nanovg.c"
#define NANOVG_GL3_IMPLEMENTATION
#include "nanovg_gl.h"
```
Look up how to compile a lib like on **linux** you'd do `gcc -c main.c` and `ar rcs nanovg.a main.o` 


