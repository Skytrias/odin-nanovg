package nanovg

import "core:os"
import "core:c"

//when os.OS == "windows" do foreign import msf_gif "msf_gif.lib"
when os.OS == "linux" do foreign import nvg { "nanovg.a", "system:GL" };

@(default_calling_convention="c", link_prefix="nvg")
foreign nvg {
	// nvg_gl based and lib compilation based
	CreateGL2 :: proc(type: CreateFlags) -> ^Context ---;
	DeleteGL2 :: proc(ctx: ^Context) ---;
	
	CreateGL3 :: proc(type: CreateFlags) -> ^Context ---;
	DeleteGL3 :: proc(ctx: ^Context) ---;
	
	// Begin drawing a new frame
	// Calls to nanovg drawing API should be wrapped in nvgBeginFrame() & nvgEndFrame()
	// nvgBeginFrame() defines the size of the window to render to in relation currently
	// set viewport (i.e. glViewport on GL backends). Device pixel ration allows to
	// control the rendering on Hi-DPI devices.
	// For example, GLFW returns two dimension for an opened window: window size and
	// frame buffer size. In that case you would set windowWidth/Height to the window size
	// devicePixelRatio to: frameBufferWidth / windowWidth.
	BeginFrame :: proc(ctx: ^Context, windowWidth, windowHeight, devicePixelRatio: c.float) ---;
	
	// Cancels drawing the current frame.
	CancelFrame :: proc(ctx: ^Context) ---;
	
	// Ends drawing flushing remaining render state.
	EndFrame :: proc(ctx: ^Context) ---;
	
	
	//
	// Composite operation
	//
	// The composite operations in NanoVG are modeled after HTML Canvas API, and
	// the blend func is based on OpenGL (see corresponding manuals for more info).
	// The colors in the blending state have premultiplied alpha.
	
	// Sets the composite operation. The op parameter should be one of NVGcompositeOperation.
	GlobalCompositeOperation :: proc(ctx: ^Context, op: c.int) ---;
	
	// Sets the composite operation with custom pixel arithmetic. The parameters should be one of NVGblendFactor.
	GlobalCompositeBlendFunc :: proc(ctx: ^Context, sfactor, dfactor: c.int) ---;
	
	// Sets the composite operation with custom pixel arithmetic for RGB and alpha components separately. The parameters should be one of NVGblendFactor.
	GlobalCompositeBlendFuncSeparate :: proc(ctx: ^Context, srcRGB, dstRGB, srcAlpha, dstAlpha: c.int) ---;
	
	// NOTE(Skytrias): rest can be easily done via odin
	//
	// Color utils
	//
	// Colors in NanoVG are stored as unsigned ints in ABGR format.
	
	// Returns a color value from red, green, blue values. Alpha will be set to 255 (1.0f).
	RGB :: proc(r, g, b: c.char) -> Color ---;
	
	//RGBf :: proc(r, g, b: c.char, a: c.float) -> Color ---;
	
	// Linearly interpolates from color c0 to c1, and returns resulting color value.
	LerpRGBA :: proc(c0, c1: Color, u: c.float) -> Color ---;
	
	// Returns color value specified by hue, saturation and lightness.
	// HSL values are all in range [0..1], alpha will be set to 255.
	HSL :: proc(h, s, l: c.float) -> Color ---;
	
	// Returns color value specified by hue, saturation and lightness and alpha.
	// HSL values are all in range [0..1], alpha in range [0..255]
	HSLA :: proc(h, s, l: c.float, a: c.char) -> Color ---;
	
	//
	// State Handling
	//
	// NanoVG contains state which represents how paths will be rendered.
	// The state contains transform, fill and stroke styles, text and font styles,
	// and scissor clipping.
	
	// Pushes and saves the current render state into a state stack.
	// A matching nvgRestore() must be used to restore the state.
	Save :: proc(ctx: ^Context) ---;
	
	// Pops and restores current render state.
	Restore :: proc(ctx: ^Context) ---;
	
	// Resets current render state to default values. Does not affect the render state stack.
	Reset :: proc(ctx: ^Context) ---;
	
	//
	// Render styles
	//
	// Fill and stroke render style can be either a solid color or a paint which is a gradient or a pattern.
	// Solid color is simply defined as a color value, different kinds of paints can be created
	// using nvgLinearGradient(), nvgBoxGradient(), nvgRadialGradient() and nvgImagePattern().
	//
	// Current render style can be saved and restored using nvgSave() and nvgRestore().
	
	// Sets whether to draw antialias for nvgStroke() and nvgFill(). It's enabled by default.
	ShapeAntiAlias :: proc(ctx: ^Context, enabled: c.int) ---;
	
	// Sets current stroke style to a solid color.
	StrokeColor :: proc(ctx: ^Context, color: Color) ---;
	
	// Sets current stroke style to a paint, which can be a one of the gradients or a pattern.
	StrokePaint :: proc(ctx: ^Context, paint: Paint) ---;
	
	// Sets current fill style to a solid color.
	FillColor :: proc(ctx: ^Context, color: Color) ---;
	
	// Sets current fill style to a paint, which can be a one of the gradients or a pattern.
	FillPaint :: proc(ctx: ^Context, paint: Paint) ---;
	
	// Sets the miter limit of the stroke style.
	// Miter limit controls when a sharp corner is beveled.
	MiterLimit :: proc(ctx: ^Context, limit: c.float) ---;
	
	// Sets the stroke width of the stroke style.
	StrokeWidth :: proc(ctx: ^Context, size: c.float) ---;
	
	// Sets how the end of the line (cap) is drawn,
	// Can be one of: NVG_BUTT (default), NVG_ROUND, NVG_SQUARE.
	LineCap :: proc(ctx: ^Context, cap: LineCapType) ---;
	
	// Sets how sharp path corners are drawn.
	// Can be one of NVG_MITER (default), NVG_ROUND, NVG_BEVEL.
	LineJoin :: proc(ctx: ^Context, join: LineCapType) ---;
	
	// Sets the transparency applied to all rendered shapes.
	// Already transparent paths will get proportionally more transparent as well.
	GlobalAlpha :: proc(ctx: ^Context, alpha: c.float) ---;
	
	//
	// Transforms
	//
	// The paths, gradients, patterns and scissor region are transformed by an transformation
	// matrix at the time when they are passed to the API.
	// The current transformation matrix is a affine matrix:
	//   [sx kx tx]
	//   [ky sy ty]
	//   [ 0  0  1]
	// Where: sx,sy define scaling, kx,ky skewing, and tx,ty translation.
	// The last row is assumed to be 0,0,1 and is not stored.
	//
	// Apart from nvgResetTransform(), each transformation function first creates
	// specific transformation matrix and pre-multiplies the current transformation by it.
	//
	// Current coordinate system (transformation) can be saved and restored using nvgSave() and nvgRestore().
	
	// Resets current transform to a identity matrix.
	ResetTransform :: proc(ctx: ^Context) ---;
	
	// Premultiplies current coordinate system by specified matrix.
	// The parameters are interpreted as matrix as follows:
	//   [a c e]
	//   [b d f]
	//   [0 0 1]
	Transform :: proc(ctx: ^Context, a, b, c, d, e, f: c.float) ---;
	
	// Translates current coordinate system.
	Translate :: proc(ctx: ^Context, x, y: c.float) ---;
	
	// Rotates current coordinate system. Angle is specified in radians.
	Rotate :: proc(ctx: ^Context, angle: c.float) ---;
	
	// Skews the current coordinate system along X axis. Angle is specified in radians.
	SkewX :: proc(ctx: ^Context, angle: c.float) ---;
	
	// Skews the current coordinate system along Y axis. Angle is specified in radians.
	SkewY :: proc(ctx: ^Context, angle: c.float) ---;
	
	// Scales the current coordinate system.
	Scale :: proc(ctx: ^Context, x, y: c.float) ---;
	
	// Stores the top part proc(a-f) of the current transformation matrix in to the specified buffer.
	//   [a c e]
	//   [b d f]
	//   [0 0 1]
	// There should be space for 6 floats in the return buffer for the values a-f.
	CurrentTransform :: proc(ctx: ^Context, xform: ^c.float) ---;
	
	// The following functions can be used to make calculations on 2x3 transformation matrices.
	// A 2x3 matrix is represented as float[6].
	
	// Sets the transform to identity matrix.
	TransformIdentity :: proc(dst: ^c.float) ---;
	
	// Sets the transform to translation matrix matrix.
	TransformTranslate :: proc(dst: ^c.float, x, ty: c.float) ---;
	
	// Sets the transform to scale matrix.
	TransformScale :: proc(dst: ^c.float, sx, sy: c.float) ---;
	
	// Sets the transform to rotate matrix. Angle is specified in radians.
	TransformRotate :: proc(dst: ^c.float, a: c.float) ---;
	
	// Sets the transform to skew-x matrix. Angle is specified in radians.
	TransformSkewX :: proc(dst: ^c.float, a: c.float) ---;
	
	// Sets the transform to skew-y matrix. Angle is specified in radians.
	TransformSkewY :: proc(dst: ^c.float, a: c.float) ---;
	
	// Sets the transform to the result of multiplication of two transforms, of A = A*B.
	TransformMultiply :: proc(dst, src: ^c.float) ---;
	
	// Sets the transform to the result of multiplication of two transforms, of A = B*A.
	TransformPremultiply :: proc(dst, src: ^c.float) ---;
	
	// Sets the destination to inverse of specified transform.
	// Returns 1 if the inverse could be calculated, else 0.
	TransformInverse :: proc(dst, src: ^c.float) -> c.int ---;
	
	// Transform a point by given transform.
	TransformPoint :: proc(dstx, dsty, xform: ^c.float, srcx, srcy: c.float) ---;
	
	// Converts degrees to radians and vice versa.
	DegToRad :: proc(deg: c.float) -> c.float ---;
	RadToDeg :: proc(rad: c.float) -> c.float ---;
	
	//
	// Images
	//
	// NanoVG allows you to load jpg, png, psd, tga, pic and gif files to be used for rendering.
	// In addition you can upload your own image. The image loading is provided by stb_image.
	// The parameter imageFlags is combination of flags defined in NVGimageFlags.
	
	// Creates image by loading it from the disk from specified file name.
	// Returns handle to the image.
	CreateImage :: proc(ctx: ^Context, filename: cstring, imageFlags: ImageFlags) -> c.int ---; 
	
	// Creates image by loading it from the specified chunk of memory.
	// Returns handle to the image.
	CreateImageMem :: proc(ctx: ^Context, imageFlags: ImageFlags, data: ^byte, ndtata: c.int) -> c.int ---; 
	
	// Creates image from specified image data.
	// Returns handle to the image.
	CreateImageRGBA :: proc(ctx: ^Context, w, h: c.int, imageFlags: ImageFlags, data: ^byte) -> c.int ---; 
	
	// Updates image data specified by image handle.
	UpdateImage :: proc(ctx: ^Context, image: c.int, data: ^byte) ---;
	
	// Returns the dimensions of a created image.
	ImageSize :: proc(ctx: ^Context, image: c.int, w, h: ^c.int) ---;
	
	// Deletes created image.
	DeleteImage :: proc(ctx: ^Context, image: c.int) ---;
	
	//
	// Paints
	//
	// NanoVG supports four types of paints: linear gradient, box gradient, radial gradient and image pattern.
	// These can be used as paints for strokes and fills.
	
	// Creates and returns a linear gradient. Parameters (sx,sy)-(ex,ey) specify the start and end coordinates
	// of the linear gradient, icol specifies the start color and ocol the end color.
	// The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
	LinearGradient :: proc(ctx: ^Context, sx, sy, ex, ey: c.float, icol, ocol: Color) -> Paint ---;
	
	// Creates and returns a box gradient. Box gradient is a feathered rounded rectangle, it is useful for rendering
	// drop shadows or highlights for boxes. Parameters (x,y) define the top-left corner of the rectangle,
	// (w,h) define the size of the rectangle, r defines the corner radius, and f feather. Feather defines how blurry
	// the border of the rectangle is. Parameter icol specifies the inner color and ocol the outer color of the gradient.
	// The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
	BoxGradient :: proc(ctx: ^Context, x, y, w, h, r, f: c.float, icol, ocol: Color) -> Paint ---;
	
	// Creates and returns a radial gradient. Parameters (cx,cy) specify the center, inr and outr specify
	// the inner and outer radius of the gradient, icol specifies the start color and ocol the end color.
	// The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
	RadialGradient :: proc(ctx: ^Context, cx, cy, inr, outr: c.float, icol, ocol: Color) -> Paint ---;
	
	// Creates and returns an image pattern. Parameters (ox,oy) specify the left-top location of the image pattern,
	// (ex,ey) the size of one image, angle rotation around the top-left corner, image is handle to the image to render.
	// The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
	ImagePattern :: proc(ctx: ^Context, ox, oy, ex, ey, angle: c.float, image: c.int, alpha: c.float) -> Paint ---;
	
	//
	// Scissoring
	//
	// Scissoring allows you to clip the rendering into a rectangle. This is useful for various
	// user interface cases like rendering a text edit or a timeline.
	
	// Sets the current scissor rectangle.
	// The scissor rectangle is transformed by the current transform.
	@(link_name="nvgScissor")
		RectScissor :: proc(ctx: ^Context, x, y, w, h: c.float) ---;
	
	// Intersects current scissor rectangle with the specified rectangle.
	// The scissor rectangle is transformed by the current transform.
	// Note: in case the rotation of previous scissor rect differs from
	// the current one, the intersection will be done between the specified
	// rectangle and the previous scissor rectangle transformed in the current
	// transform space. The resulting shape is always rectangle.
	IntersectScissor :: proc(ctx: ^Context, x, y, w, h: c.float) ---;
	
	// Reset and disables scissoring.
	ResetScissor :: proc(ctx: ^Context) ---;
	
	//
	// Paths
	//
	// Drawing a new shape starts with nvgBeginPath(), it clears all the currently defined paths.
	// Then you define one or more paths and sub-paths which describe the shape. The are functions
	// to draw common shapes like rectangles and circles, and lower level step-by-step functions,
	// which allow to define a path curve by curve.
	//
	// NanoVG uses even-odd fill rule to draw the shapes. Solid shapes should have counter clockwise
	// winding and holes should have counter clockwise order. To specify winding of a path you can
	// call nvgPathWinding(). This is useful especially for the common shapes, which are drawn CCW.
	//
	// Finally you can fill the path using current fill style by calling nvgFill(), and stroke it
	// with current stroke style by calling nvgStroke().
	//
	// The curve segments and sub-paths are transformed by the current transform.
	
	// Clears the current path and sub-paths.
	BeginPath :: proc(ctx: ^Context) ---;
	
	// Starts new sub-path with specified point as first point.
	MoveTo :: proc(ctx: ^Context, x, y: c.float) ---;
	
	// Adds line segment from the last point in the path to the specified point.
	LineTo :: proc(ctx: ^Context, x, y: c.float) ---;
	
	// Adds cubic bezier segment from last point in the path via two control points to the specified point.
	BezierTo :: proc(ctx: ^Context, c1x, c1y, c2x, c2y, x, y: c.float) ---;
	
	// Adds quadratic bezier segment from last point in the path via a control point to the specified point.
	QuadTo :: proc(ctx: ^Context, cx, cy, x, y: c.float) ---;
	// Adds an arc segment at the corner defined by the last path point, and two specified points.
	ArcTo :: proc(ctx: ^Context, x1, y1, x2, y2, radius: c.float) ---;
	
	// Closes current sub-path with a line segment.
	ClosePath :: proc(ctx: ^Context) ---;
	
	// Sets the current sub-path winding, see NVGwinding and NVGsolidity.
	PathWinding :: proc(ctx: ^Context, dir: Winding) ---;
	
	// Creates new circle arc shaped sub-path. The arc center is at cx,cy, the arc radius is r,
	// and the arc is drawn from angle a0 to a1, and swept in direction dir (NVG_CCW, or NVG_CW).
	// Angles are specified in radians.
	Arc :: proc(ctx: ^Context, cx, cy, r, a0, a1: c.float, dir: Winding) ---;
	
	
	// Creates new rectangle shaped sub-path.
	Rect :: proc(ctx: ^Context, x, y, w, h: c.float) ---;
	
	// Creates new rounded rectangle shaped sub-path.
	RoundedRect :: proc(ctx: ^Context, x, y, w, h, r: c.float) ---;
	
	// Creates new rounded rectangle shaped sub-path with varying radii for each corner.
	RoundedRectVarying :: proc(ctx: ^Context, x, y, w, h, radTopLeft, radTopRight, radBottomRight, radBottomLeft: c.float) ---;
	
	// Creates new ellipse shaped sub-path.
	Ellipse :: proc(ctx: ^Context, cx, cy, rx, ry: c.float) ---;
	
	// Creates new circle shaped sub-path.
	Circle :: proc(ctx: ^Context, cx, cy, r: c.float) ---;
	
	// Fills the current path with current fill style.
	Fill :: proc(ctx: ^Context) ---;
	
	// Fills the current path with current stroke style.
	Stroke :: proc(ctx: ^Context) ---;
	
	//
	// Text
	//
	// NanoVG allows you to load .ttf files and use the font to render text.
	//
	// The appearance of the text can be defined by setting the current text style
	// and by specifying the fill color. Common text and font settings such as
	// font size, letter spacing and text align are supported. Font blur allows you
	// to create simple text effects such as drop shadows.
	//
	// At render time the font face can be set based on the font handles or name.
	//
	// Font measure functions return values in local space, the calculations are
	// carried in the same resolution as the final rendering. This is done because
	// the text glyph positions are snapped to the nearest pixels sharp rendering.
	//
	// The local space means that values are not rotated or scale as per the current
	// transformation. For example if you set font size to 12, which would mean that
	// line height is 16, then regardless of the current scaling and rotation, the
	// returned line height is always 16. Some measures may vary because of the scaling
	// since aforementioned pixel snapping.
	//
	// While this may sound a little odd, the setup allows you to always render the
	// same way regardless of scaling. I.e. following works regardless of scaling:
	//
	//		const char* txt = "Text me up.";
	//		nvgTextBounds :: proc(vg, x,y, txt, NULL, bounds) ---;
	//		nvgBeginPath :: proc(vg) ---;
	//		nvgRoundedRect :: proc(vg, bounds[0],bounds[1], bounds[2]-bounds[0], bounds[3]-bounds[1]) ---;
	//		nvgFill :: proc(vg) ---;
	//
	// Note: currently only solid color fill is supported for text.
	
	// Creates font by loading it from the disk from specified file name.
	// Returns handle to the font.
	CreateFont :: proc(ctx: ^Context, name, filename: cstring) -> c.int ---;
	
	// fontIndex specifies which font face to load from a .ttf/.ttc file.
	CreateFontAtIndex :: proc(ctx: ^Context, name, filename: cstring, fontIndex: c.int) -> c.int ---;
	
	// Creates font by loading it from the specified memory chunk.
	// Returns handle to the font.
	CreateFontMem :: proc(ctx: ^Context, name: cstring, data: ^byte, ndata, freeData: c.int) -> c.int ---;
	
	// fontIndex specifies which font face to load from a .ttf/.ttc file.
	CreateFontMemAtIndex :: proc(ctx: ^Context, name: cstring, data: ^byte, ndata, freeData, fontIndex: c.int) -> c.int ---;
	
	// Finds a loaded font of specified name, and returns handle to it, or -1 if the font is not found.
	FindFont :: proc(ctx: ^Context, name: cstring) -> c.int ---;
	
	// Adds a fallback font by handle.
	AddFallbackFontId :: proc(ctx: ^Context, baseFont, fallbackFont: c.int) -> c.int ---;
	
	// Adds a fallback font by name.
	AddFallbackFont :: proc(ctx: ^Context, baseFont, fallbackFont: cstring) ---;
	
	// Resets fallback fonts by handle.
	ResetFallbackFontsId :: proc(ctx: ^Context, baseFont: c.int) ---;
	
	// Resets fallback fonts by name.
	ResetFallbackFonts :: proc(ctx: ^Context, baseFont: cstring) ---;
	
	// Sets the font size of current text style.
	FontSize :: proc(ctx: ^Context, size: c.float) ---;
	
	// Sets the blur of current text style.
	FontBlur :: proc(ctx: ^Context, blur: c.float) ---;
	
	// Sets the letter spacing of current text style.
	TextLetterSpacing :: proc(ctx: ^Context, spacing: c.float) ---;
	
	// Sets the proportional line height of current text style. The line height is specified as multiple of font size.
	TextLineHeight :: proc(ctx: ^Context, lineHeight: c.float) ---;
	
	// Sets the text align of current text style, see NVGalign for options.
	TextAlign :: proc(ctx: ^Context, align: Align) ---;
	
	// Sets the font face based on specified id of current text style.
	FontFaceId :: proc(ctx: ^Context, font: c.int) ---;
	
	// Sets the font face based on specified name of current text style.
	FontFace :: proc(ctx: ^Context, font: cstring) ---;
	
	// Draws text string at specified location. If end is specified only the sub-string up to the end is drawn.
	Text :: proc(ctx: ^Context, x, y: c.float, str, end: ^byte) -> c.float ---;
	
	// Draws multi-line text string at specified location wrapped at the specified width. If end is specified only the sub-string up to the end is drawn.
	// White space is stripped at the beginning of the rows, the text is split at word boundaries or when new-line characters are encountered.
	// Words longer than the max width are slit at nearest character  :: proc(i.e. no hyphenation).
	TextBox :: proc(ctx: ^Context, x, y, breakRowWidth: c.float, str, end: cstring) ---;
	
	// Measures the specified text string. Parameter bounds should be a pointer to float[4],
	// if the bounding box of the text should be returned. The bounds value are [xmin,ymin, xmax,ymax]
	// Returns the horizontal advance of the measured text  :: proc(i.e. where the next character should drawn).
	// Measured values are returned in local coordinate space.
	TextBounds :: proc(ctx: ^Context, x, y: c.float, str, end: ^byte, bounds: ^c.float) -> c.float ---;
	
	// Measures the specified multi-text string. Parameter bounds should be a pointer to float[4],
	// if the bounding box of the text should be returned. The bounds value are [xmin,ymin, xmax,ymax]
	// Measured values are returned in local coordinate space.
	TextBoxBounds :: proc(ctx: ^Context, x, y, breakRowWidth: c.float, str, end: cstring, bounds: ^c.float) ---;
	
	// Calculates the glyph x positions of the specified text. If end is specified only the sub-string will be used.
	// Measured values are returned in local coordinate space.
	TextGlyphPositions :: proc(ctx: ^Context, x, y: c.float, str, end: ^byte, positions: ^GlyphPosition, maxPositions: c.int) -> c.int ---;
	
	// Returns the vertical metrics based on the current text style.
	// Measured values are returned in local coordinate space.
	TextMetrics :: proc(ctx: ^Context, ascender, descender, lineh: ^c.float) ---;
	
	// Breaks the specified text into lines. If end is specified only the sub-string will be used.
	// White space is stripped at the beginning of the rows, the text is split at word boundaries or when new-line characters are encountered.
	// Words longer than the max width are slit at nearest character  :: proc(i.e. no hyphenation).
	TextBreakLines :: proc(ctx: ^Context, str, end: cstring, breakRowWidth: c.float, rows: ^TextRow, maxRows: c.int) -> c.int ---;
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

Color :: distinct [4]c.float;
/*
Color :: struct {
	r, g, b, a: c.float,
}*/

RED :: Color { 1, 0, 0, 1 };
GREEN :: Color { 0, 1, 0, 1 };
BLUE :: Color { 0, 0, 1, 1 };
WHITE :: Color { 1, 1, 1, 1 };
BLACK :: Color { 0, 0, 0, 1 };

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
	LEFT 		= 1<<0,	// Default, align text horizontally to left.
	CENTER 	= 1<<1,	// Align text horizontally to center.
	RIGHT 	= 1<<2,	// Align text horizontally to right.
	// Vertical align
	TOP 		= 1<<3,	// Align text vertically to top.
	MIDDLE	= 1<<4,	// Align text vertically to middle.
	BOTTOM	= 1<<5,	// Align text vertically to bottom.
	BASELINE	= 1<<6, // Default, align text vertically to baseline.
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
	GENERATE_MIPMAPS	= 1<<0,     // Generate mipmaps during creation of the image.
	REPEATX			= 1<<1,		// Repeat image in X direction.
	REPEATY			= 1<<2,		// Repeat image in Y direction.
	FLIPY				= 1<<3,		// Flips (inverses) image in Y direction when rendered.
	PREMULTIPLIED		= 1<<4,		// Image data has premultiplied alpha.
	NEAREST			= 1<<5,		// Image interpolation is Nearest instead Linear
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
