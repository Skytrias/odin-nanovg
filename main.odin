package nanovg

import "core:os"
import "core:c"

//when os.OS == "windows" do foreign import msf_gif "msf_gif.lib"
when os.OS == "linux" do foreign import nvg { "nanovg.a", "system:GL" };

@(default_calling_convention="c", link_prefix="nvg")
foreign nvg {
	CreateGL2 :: proc(type: CreateFlags) -> ^Context ---;
	DeleteGL2 :: proc(ctx: ^Context) ---;
	
	CreateGL3 :: proc(type: CreateFlags) -> ^Context ---;
	DeleteGL3 :: proc(ctx: ^Context) ---;
	
	BeginFrame :: proc(ctx: ^Context, windowWidth, windowHeight, devicePixelRatio: c.float) ---;
	EndFrame :: proc(ctx: ^Context) ---;
	
	Stroke :: proc(ctx: ^Context) ---;
	StrokeColor :: proc(ctx: ^Context, color: Color) ---;
	StrokeWidth :: proc(ctx: ^Context, size: c.float) ---;
	MiterLimit :: proc(ctx: ^Context, limit: c.float) ---;
	
	LineCap :: proc(ctx: ^Context, cap: LineCapType) ---;
	LineJoin :: proc(ctx: ^Context, join: LineCapType) ---;
	GlobalAlpha :: proc(ctx: ^Context, alpha: c.float) ---;
	
	Fill :: proc(ctx: ^Context) ---;
	FillPaint :: proc(ctx: ^Context, paint: Paint) ---;
	FillColor :: proc(ctx: ^Context, color: Color) ---;
	
	// paths
	BeginPath :: proc(ctx: ^Context) ---;
	MoveTo :: proc(ctx: ^Context, x: c.float, y: c.float) ---;
	LineTo :: proc(ctx: ^Context, x: c.float, y: c.float) ---;
	BezierTo :: proc(ctx: ^Context, c1x: c.float, c1y: c.float, c2x: c.float, c2y: c.float, x: c.float, y: c.float) ---;
	QuadTo :: proc(ctx: ^Context, cx: c.float, cy: c.float, x: c.float, y: c.float) ---;
	ArcTo :: proc(ctx: ^Context, x1: c.float, y1: c.float, x2: c.float, y2: c.float, radius: c.float) ---;
	ClosePath :: proc(ctx: ^Context) ---;
	PathWinding :: proc(ctx: ^Context, dir: Winding) ---;
	Arc :: proc(ctx: ^Context, cx: c.float, cy: c.float, r: c.float, a0: c.float, a1: c.float, dir: Winding) ---;
	
	Rect :: proc(ctx: ^Context, x, y, w, h: c.float) ---;
	RoundedRect :: proc(ctx: ^Context, x, y, w, h, r: c.float) ---;
	Ellipse :: proc(ctx: ^Context, cx, cy, rx, ry: c.float) ---;
	Circle :: proc(ctx: ^Context, cx, cy, r: c.float) ---;
	
	// colors
	RGB :: proc(r, g, b: c.char) -> Color ---;
	RGBf :: proc(r, g, b: c.float) -> Color ---;
	RGBA :: proc(r, g, b, a: c.char) -> Color ---;
	RGBAf :: proc(r, g, b, a: c.float) -> Color ---;
	LerpRGBA :: proc(c0, c1: Color, u: c.float) -> Color ---;
	TransRGBA :: proc(c0: Color, a: c.char) -> Color ---;
	TransRGBAf :: proc(c0: Color, a: c.float) -> Color ---;
	HSL :: proc(h, s, l: c.float) -> Color ---;
	HSLA :: proc(h, s, l: c.float, a: c.char) -> Color ---;
}

INIT_FONTIMAGE_SIZE :: 512;
MAX_FONTIMAGE_SIZE :: 2048;
MAX_FONTIMAGES :: 4;

INIT_COMMANDS_SIZE :: 256;
INIT_POINTS_SIZE :: 128;
INIT_PATHS_SIZE :: 16;
INIT_VERTS_SIZE :: 256;
MAX_STATES :: 32;

// Length proportional to radius of a cubic bezier handle for 90deg arcs.
KAPPA90 :: 0.5522847493;	

//Color :: distinct [4]c.float;
Color :: struct #packed {
r, g, b, a: c.float,
//a, b, g, r: c.float,

/*
a: c.float,
b: c.float,
g: c.float,
r: c.float,
*/

/*
r: c.float,
g: c.float,
b: c.float,
a: c.float,
*/
}

CreateFlags :: enum i32 {
	// Flag indicating if geometry based anti-aliasing is used (may not be needed when using MSAA).
	ANTIALIAS = 1<<0,
	// Flag indicating if strokes should be drawn using stencil buffer. The rendering will be a little
	// slower, but path overlaps (i.e. self-intersecting or sharp turns) will be drawn just once.
	STENCIL_STROKES = 1<<1,
	// Flag indicating that additional debug checks are done.
	DEBUG = 1<<2,
}

Paint :: struct {
	xform: [6]c.float,
	extent: [2]c.float,
	radius: c.float,
	feather: c.float,
	innerColor: Color,
	outerColor: Color,
	image: c.int,
}

Winding :: enum i32 {
	CCW = 1,			// Winding for solid shapes
	CW = 2,				// Winding for holes
}

Solidity :: enum i32 {
	SOLID = 1,			// CCW
	HOLE = 2,			// CW
}

LineCapType :: enum i32 {
	BUTT,
	ROUND,
	SQUARE,
	BEVEL,
	MITER,
}

Align :: enum i32 {
	// Horizontal align
	ALIGN_LEFT 		= 1<<0,	// Default, align text horizontally to left.
	ALIGN_CENTER 	= 1<<1,	// Align text horizontally to center.
	ALIGN_RIGHT 	= 1<<2,	// Align text horizontally to right.
	// Vertical align
	ALIGN_TOP 		= 1<<3,	// Align text vertically to top.
	ALIGN_MIDDLE	= 1<<4,	// Align text vertically to middle.
	ALIGN_BOTTOM	= 1<<5,	// Align text vertically to bottom.
	ALIGN_BASELINE	= 1<<6, // Default, align text vertically to baseline.
};

BlendFactor :: enum i32 {
	ZERO = 1<<0,
	ONE = 1<<1,
	SRC_COLOR = 1<<2,
	ONE_MINUS_SRC_COLOR = 1<<3,
	DST_COLOR = 1<<4,
	ONE_MINUS_DST_COLOR = 1<<5,
	SRC_ALPHA = 1<<6,
	ONE_MINUS_SRC_ALPHA = 1<<7,
	DST_ALPHA = 1<<8,
	ONE_MINUS_DST_ALPHA = 1<<9,
	SRC_ALPHA_SATURATE = 1<<10,
};

CompositeOperation :: enum i32 {
	SOURCE_OVER,
	SOURCE_IN,
	SOURCE_OUT,
	ATOP,
	DESTINATION_OVER,
	DESTINATION_IN,
	DESTINATION_OUT,
	DESTINATION_ATOP,
	LIGHTER,
	COPY,
	XOR,
};

CompositeOperationState :: struct {
	srcRGB: c.int,
	dstRGB: c.int,
	srcAlpha: c.int,
	dstAlpha: c.int,
}

GlyphPosition :: struct {
	// NOTE(Skytrias): might be bad
	str: ^c.char, // Position of the glyph in the input string.
	x: c.float,			// The x-coordinate of the logical glyph position.
	minx, maxx: c.float,	// The bounds of the glyph shape.
}

TextRow :: struct {
	start: ^c.char,	// Pointer to the input text where the row starts.
	end: ^c.char,	// Pointer to the input text where the row ends (one past the last character).
	next: ^c.char,	// Pointer to the beginning of the next row.
	width: c.float,		// Logical width of the row.
	minx, maxx: c.float,	// Actual bounds of the row. Logical with and bounds can differ because of kerning and some parts over extending.
}

ImageFlags :: enum i32 {
	IMAGE_GENERATE_MIPMAPS	= 1<<0,     // Generate mipmaps during creation of the image.
	IMAGE_REPEATX			= 1<<1,		// Repeat image in X direction.
	IMAGE_REPEATY			= 1<<2,		// Repeat image in Y direction.
	IMAGE_FLIPY				= 1<<3,		// Flips (inverses) image in Y direction when rendered.
	IMAGE_PREMULTIPLIED		= 1<<4,		// Image data has premultiplied alpha.
	IMAGE_NEAREST			= 1<<5,		// Image interpolation is Nearest instead Linear
}

// TODO(Skytrias): 
FONS_Context :: struct {
	
}

Context :: struct {
	params: Params,
	commands: ^c.float,
	ccommands: c.int,
	ncommands: c.int,
	commandx, commandy: c.float,
	states: [MAX_STATES]State,
	nstates: c.int,
	
	cache: ^PathCache,
	tessTol: c.float,
	distTol: c.float,
	fringeWidth: c.float,
	devicePxRatio: c.float,
	fs: ^FONS_Context,
	fontImages: [MAX_FONTIMAGES]int,
	fontImageIdx: int,
	drawCallCount: int,
	fillTriCount: int,
	strokeTriCount: int,
	textTriCount: int,
}

Commands :: enum i32 {
	MOVETO = 0,
	LINETO = 1,
	BEZIERTO = 2,
	CLOSE = 3,
	WINDING = 4,
}

PointFlags :: enum i32 {
	PT_CORNER = 0x01,
	PT_LEFT = 0x02,
	PT_BEVEL = 0x04,
	PR_INNERBEVEL = 0x08,
}

State :: struct {
	compositeOperation: CompositeOperationState,
	shapeAntiAlias: c.int,
	fill: Paint,
	stroke: Paint,
	strokeWidth: c.float,
	miterLimit: c.float,
	lineJoin: c.int,
	lineCap: c.int,
	alpha: c.float,
	xform: [6]c.float,
	scissor: Scissor,
	fontSize: c.float,
	letterSpacing: c.float,
	lineHeight: c.float,
	fontBlur: c.float,
	textAlign: c.int,
	fontId: c.int,
};

Point :: struct {
	x,y: c.float,
	dx, dy: c.float,
	len: c.float,
	dmx, dmy: c.float,
	// TODO(Skytrias): flags?
	flags: u8,
};

PathCache :: struct {
	points: ^Point,
	npoints: c.int,
	cpoints: c.int,
	paths: ^Path,
	npaths: c.int,
	cpaths: c.int,
	verts: ^Vertex,
	nverts: c.int,
	cverts: c.int,
	bounds: [4]c.float,
};

// internal 
Texture :: enum i32 {
	TEXTURE_ALPHA = 0x01,
	TEXTURE_RGBA = 0x02,
}

Scissor :: struct {
	xform: [6]c.float,
	extent: [2]c.float,
}

Vertex :: struct {
	x,y,u,v: c.float,
}

Path :: struct {
	first: c.int,
	count: c.int,
	closed: c.char,
	nbevel: c.int,
	fill: ^Vertex,
	nfill: c.int,
	stroke: ^Vertex,
	nstroke: c.int,
	winding: c.int,
	convex: c.int,
}

Params :: struct {
	userPtr: rawptr,
	edgeAntiAlias: c.int,
	renderCreate: proc(uptr: rawptr) -> int,
	renderCreateTexture: proc(uptr: rawptr, type, w, h: c.int, imageFlags: ImageFlags, data: ^byte) -> int,
	renderDeleteTexture: proc(uptr: rawptr, image: c.int) -> int,
	renderUpdateTexture: proc(uptr: rawptr, image: c.int, x, y, w, h: c.int, data: ^byte) -> int,
	renderGetTextureSize: proc(uptr: rawptr, image: c.int, w, h: ^c.int) -> int,
	
	renderViewport: proc(uptr: rawptr, width, height, devicePixelRatio: c.float),
	renderCancel: proc(uptr: rawptr),
	renderFlush: proc(uptr: rawptr),
	renderFill: proc(uptr: rawptr, paint: ^Paint, compositeOperation: CompositeOperationState, scissor: ^Scissor, fringe: c.float, bounds: ^c.float, paths: ^Path, path: c.int),
	
	renderStroke: proc(uptr: rawptr, paint: ^Paint, compositeOperation: CompositeOperationState, scissor: ^Scissor, fringe, strokeWidth: c.float, path: ^Path, npaths: c.int),
	
	renderTriangles: proc(uptr: rawptr, compositeOperation: CompositeOperationState, scissor: ^Scissor, verts: ^Vertex, nverts: c.int, fringe: c.float),
	
	renderDelete: proc(uptr: rawptr),
}
