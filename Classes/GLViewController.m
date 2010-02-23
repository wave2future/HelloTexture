//
//  GLViewController.h
//  HelloTexture
//
//  Created by turner on 5/26/09.
//  Copyright Douglass Turner Consulting 2009. All rights reserved.
//

#import "GLViewController.h"
#import "GLView.h"
#import "TEITexture.h"
#import "ConstantsAndMacros.h"
#import "JLMMatrixLibrary.h"

static GLuint _vertexCount = 0;
static void _addVertex(GLfloat x, GLfloat y, GLfloat z,
					   GLubyte r, GLubyte g, GLubyte b, GLubyte a,
					   GLfloat s, GLfloat t);

typedef struct TEIVertex {
    GLfloat  xyz[3];
    GLubyte rgba[3];
    GLfloat   st[2];
} TEIVertex;

static TEIVertex _rectangle[4];

@implementation GLViewController

@synthesize over_texture = _over_texture;
@synthesize under_texture = _under_texture;

- (void) dealloc {
	
    [_over_texture	release], _over_texture		= nil;
    [_under_texture	release], _under_texture	= nil;
    [super			dealloc];
}

// The Stanford Pattern
- (void)loadView {
	
	CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
	
	GLView *glView = nil;
	glView = [[[GLView alloc] initWithFrame:applicationFrame] autorelease];
	
	glView.drawingDelegate = self;
		
	self.view = glView;
}

// The Stanford Pattern
- (void)viewDidLoad {
	
	// OpenGL defaults to CCW winding rule for triangles.
	// The patten is: V0 -> V1 -> V2 then V2 -> V1 -> V3 ... etc.
	// At draw time I use glDrawArrays(GL_TRIANGLE_STRIP, 0, _vertexCount)
	// addVertex(x,y,z r,g,b,a, s,t)
	
//	// V0
//	_addVertex(-1.0f, -1.0f, 0.0f, 255, 0, 0, 255, 0.0f, 0.0f);
//	
//	// V1
//	_addVertex( 1.0f, -1.0f, 0.0f, 255, 0, 0, 255, 1.0f, 0.0f);
//	
//	// V2
//	_addVertex(-1.0f,  1.0f, 0.0f, 255, 0, 0, 255, 0.0f, 1.0f);
//	
//	// V3
//	_addVertex( 1.0f,  1.0f, 0.0f, 255, 0, 0, 255, 1.0f, 1.0f);

	GLfloat n =  1.0f;
	GLfloat s = -1.0f;
	
	GLfloat w = -1.0f;
	GLfloat e =  1.0f;
	
	// V0
	_addVertex(w, s, 0.0f, 255, 0, 0, 255, 0.0f, 0.0f);
	
	// V1
	_addVertex(e, s, 0.0f, 255, 0, 0, 255, 1.0f, 0.0f);
	
	// V2
	_addVertex(w, n, 0.0f, 255, 0, 0, 255, 0.0f, 1.0f);
	
	// V3
	_addVertex(e, n, 0.0f, 255, 0, 0, 255, 1.0f, 1.0f);
	
	
	_over_texture	= [ [TEITexture alloc] initWithImageFile:@"candycane_scalar_disk" extension:@"png" mipmap:YES ];
//	_over_texture	= [ [TEITexture alloc] initWithImageFile:@"kids_grid_3x3_translucent" extension:@"png" mipmap:YES ];
//	_over_texture	= [ [TEITexture alloc] initWithImageFile:@"kids_grid_3x3" extension:@"png" mipmap:YES ];
	
//	_under_texture	= [ [TEITexture alloc] initWithImageFile:@"orientation_flipped_for_pvr_mip_4" extension:@"pvr" mipmap:YES ];
	_under_texture	= [ [TEITexture alloc] initWithImageFile:@"mandrill_flipped_for_pvr_mip_4" extension:@"pvr" mipmap:YES ];

}

static void _addVertex(GLfloat x, GLfloat y, GLfloat z,
					   GLubyte r, GLubyte g, GLubyte b, GLubyte a,
					   GLfloat s, GLfloat t) {
		
	TEIVertex *vertex = &_rectangle[_vertexCount];
	
	// xyz
    vertex->xyz[0] = x; 
	vertex->xyz[1] = y; 
	vertex->xyz[2] = z;
	
	// rgba
    vertex->rgba[0] = r; 
	vertex->rgba[1] = g; 
	vertex->rgba[2] = b; 
	vertex->rgba[3] = a;
	
	// st
    vertex->st[0] = s; 
	vertex->st[1] = t; 
	
    _vertexCount++;
}

// The Stanford Pattern
- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	// Do stuff
	GLView *glView = (GLView *)self.view;

	glView.animationInterval = 1.0 / kRenderingFrequency;
	[glView startAnimation];
	
//	[self beginLoadingDataFromWeb];
//	[self showLoadingProgress];

}

// The Stanford Pattern
- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
}

- (void)perspectiveProjectionWithFieldOfViewInDegreesY:(GLfloat)fieldOfViewInDegreesY 
							aspectRatioWidthOverHeight:(GLfloat)aspectRatioWidthOverHeight 
												  near:(GLfloat)near 
												   far:(GLfloat)far {
	
	GLfloat ymax = near * tanf(m3dDegToRad(fieldOfViewInDegreesY));
	GLfloat ymin = -ymax;
	GLfloat xmin = ymin * aspectRatioWidthOverHeight;
	GLfloat xmax = ymax * aspectRatioWidthOverHeight;
	
	glFrustumf(xmin, xmax, ymin, ymax, near, far);
	
}

//
//	Aiming the OpenGL camera involves a matrix inversion. 
//
//	On p. 25 of Robot Manipulators: Mathematics, Programming, and Control by Richard Paul (old reliable) there is a
// simple and computationally cheap way to do the inversion. On Google Books here: http://bit.ly/39QfMr
//
//	We must represent the camera frame in eye space, the space within which OpenGL rendering is done.
//
//	Given C - the camera transformation in world space we need C' it's inverse. We needn't do a full 
// blown matrix inverse because of the special case of this frame. It has an orthonormal upper 3x3. 
// So C' can be calculated thusly:
//
//	C =
//	nx ox ax px
//	ny oy ay py
//	nz oz az pz
//
//	C' =
//	nx ny nz -p.n
//	ox oy oz -p.o
//	ax ay az -p.a
//
- (void)placeCameraAtLocation:(M3DVector3f)location 
					   target:(M3DVector3f)target 
						   up:(M3DVector3f)up {
	
	// We use the Richard Paul matrix notation of n, o, a, and p 
	// for x, y, z axes of orientation and p as translation
	
	M3DVector3f n; // x-axis
	M3DVector3f o; // y-axis
	M3DVector3f a; // z-axis
	M3DVector3f p; // translation vector
	
	// The camera is always pointed along the -z axis. So the "a" vector = -(target - eye)
	m3dLoadVector3f(a, -(target[0] - location[0]), -(target[1] - location[1]), -(target[2] - location[2]));
	m3dNormalizeVectorf(a);
	
	// The up parameter is assumed approximate. It corresponds to the y-axis or "o" vector.
	M3DVector3f o_approximate;
	m3dCopyVector3f(o_approximate, up);
	m3dNormalizeVectorf(o_approximate);
	
	//	n = o_approximate X a
	m3dCrossProductf(n, o_approximate, a);
	m3dNormalizeVectorf(n);
	
	// Calculate the exact up vector from the cross product
	// of the other basis vectors which are indeed orthogonal:
	//
	// o = a X n
	//
	m3dCrossProductf(o, a, n);
	
	// The translation vector - location - is the eye location.
	// It is the where the camera is positioned in world space.
	// Copy it into the "p" vector
	m3dCopyVector3f(p, location);
	
	// Build camera transform matrix from column vectors: n, o, a, p
	m3dLoadIdentity44f(_cameraTransform);
	MatrixElement(_cameraTransform, 0, 0) = n[0];
	MatrixElement(_cameraTransform, 1, 0) = n[1];
	MatrixElement(_cameraTransform, 2, 0) = n[2];
	
	MatrixElement(_cameraTransform, 0, 1) = o[0];
	MatrixElement(_cameraTransform, 1, 1) = o[1];
	MatrixElement(_cameraTransform, 2, 1) = o[2];
	
	MatrixElement(_cameraTransform, 0, 2) = a[0];
	MatrixElement(_cameraTransform, 1, 2) = a[1];
	MatrixElement(_cameraTransform, 2, 2) = a[2];
	
	MatrixElement(_cameraTransform, 0, 3) = p[0];
	MatrixElement(_cameraTransform, 1, 3) = p[1];
	MatrixElement(_cameraTransform, 2, 3) = p[2];
	
	// echo the camera transformation frame
	//	nx ox ax px
	//	ny oy ay py
	//	nz oz az pz
	//	NSLog(@"Camera Transformation");
	//	NSLog(@"nx ox ax px %.2f %.2f %.2f %.2f",
	//		  MatrixElement(_cameraTransform, 0, 0),
	//		  MatrixElement(_cameraTransform, 0, 1),
	//		  MatrixElement(_cameraTransform, 0, 2),
	//		  MatrixElement(_cameraTransform, 0, 3));
	//	
	//	NSLog(@"ny oy ay py %.2f %.2f %.2f %.2f",
	//		  MatrixElement(_cameraTransform, 1, 0),
	//		  MatrixElement(_cameraTransform, 1, 1),
	//		  MatrixElement(_cameraTransform, 1, 2),
	//		  MatrixElement(_cameraTransform, 1, 3));
	//	
	//	NSLog(@"nz oz az pz %.2f %.2f %.2f %.2f",
	//		  MatrixElement(_cameraTransform, 2, 0),
	//		  MatrixElement(_cameraTransform, 2, 1),
	//		  MatrixElement(_cameraTransform, 2, 2),
	//		  MatrixElement(_cameraTransform, 2, 3));
	//
	//	NSLog(@".");
	
	
	// Build upper 3x3 of OpenGL style "view" transformation from transpose of camera orientation
	// This is the inversion process. Since these 3x3 matrices are orthonormal a transpose is 
	// sufficient to invert
	m3dLoadIdentity44f(_openGLCameraInverseTransform);	
	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 3; j++) {
			MatrixElement(_openGLCameraInverseTransform, i, j) = MatrixElement(_cameraTransform, j, i);
		}
	}
	
	// Complete building OpenGL camera transform by inserting the translation vector
	// as described in Richard Paul.
	MatrixElement(_openGLCameraInverseTransform, 0, 3) = -m3dDotProductf(p, n);
	MatrixElement(_openGLCameraInverseTransform, 1, 3) = -m3dDotProductf(p, o);
	MatrixElement(_openGLCameraInverseTransform, 2, 3) = -m3dDotProductf(p, a);
	
	// Use this to inspect current transform in the debugger
	//	GLfloat crapola[16];
	
	// Set the camera transformation in OpenGL
	glMatrixMode(GL_MODELVIEW);
	
	glLoadIdentity(); 
	//	glGetFloatv(GL_MODELVIEW_MATRIX, crapola);
	
	glLoadMatrixf(_openGLCameraInverseTransform);
	//	glGetFloatv(GL_MODELVIEW_MATRIX, crapola);
	
}

-(void)setupView:(GLView*)view {
	
	glEnable(GL_DEPTH_TEST);
	
	const GLfloat zNear			=    0.01; 
	const GLfloat zFar			= 1000.0; 
	const GLfloat fieldOfView	=   45.0; 
		
	glMatrixMode(GL_PROJECTION);
	[self perspectiveProjectionWithFieldOfViewInDegreesY:fieldOfView aspectRatioWidthOverHeight:view.bounds.size.width/view.bounds.size.height near:zNear far:zFar];
	glViewport(0, 0, view.bounds.size.width, view.bounds.size.height);  
	
	glFrontFace(GL_CCW);	
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glEnable (GL_BLEND);
//	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	// This is the classic Porter-Duff "over" operation
	// used with pre-multiplied images.
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	
	glClearColor(1.0f, 1.0f, 1.0f, 1.0f); 
	
}

- (void)drawView:(GLView*)view {
	
	// angle wangle.
	static GLfloat inc = 0.0f;	
	GLfloat angle = m3dRadToDeg(M_PI) * (1.0f - ((1.0f + cosf(m3dDegToRad(inc))) / 2.0f));
	
	// !! NOTE !! Clearing is expensive. Avoid it if possible!
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glEnable(GL_TEXTURE_2D);
	
//	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);	
//	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);	
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	
	// Select model-view matrix prior to push
	glMatrixMode(GL_MODELVIEW);
	
	// Push model-view matrix and place in sane state
	glPushMatrix();
	glLoadIdentity();
	// Push model-view matrix and place in sane state
	
	// Futz with background rectangle
	glTranslatef(0.0f, 0.0f, -7.0f);
	glScalef(5.0f, 5.0f, 1.0f);
	// Futz with background rectangle

	// Select texture matrix prior to push
	glMatrixMode(GL_TEXTURE);
	
	// Push texture matrix and place in sane state
	glPushMatrix();
	glLoadIdentity();
	// Push texture matrix and place in sane state

	// Futz with texture attached to background rectangle
	glScalef(4.0f/1.0f, 4.0f/1.0f, 1.0f);
	
	glTranslatef( 1.0f/2.0f,  1.0f/2.0f, 1.0f);
	glRotatef((1.0/1.0)* angle, 0.0f, 0.0f, 1.0f);
	glTranslatef(-1.0f/2.0f, -1.0f/2.0f, 1.0f);
	// Futz with texture attached to background rectangle

	glBindTexture(GL_TEXTURE_2D, self.under_texture.name);
	glVertexPointer(  3, GL_FLOAT,         sizeof(TEIVertex), &_rectangle[0].xyz );
	glTexCoordPointer(2, GL_FLOAT,         sizeof(TEIVertex), &_rectangle[0].st  );
	glColorPointer(   4, GL_UNSIGNED_BYTE, sizeof(TEIVertex), &_rectangle[0].rgba);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, _vertexCount);
		
	// Pop texture matrix
	glPopMatrix();
	// Pop texture matrix
	
	// Select model-view matrix following pop
	glMatrixMode(GL_MODELVIEW);
	
	// Pop model-view matrix
	glPopMatrix();
	// Pop model-view matrix

	
	
	// Select model-view matrix prior to push
	glMatrixMode(GL_MODELVIEW);
	
	// Push model-view matrix and place in sane state
	glPushMatrix();
	glLoadIdentity();
	// Push model-view matrix and place in sane state

	// Futz with foreground rectangle
	glRotatef(10.0f * angle, 0.0f, 0.0f, 1.0f);
	glTranslatef(0.0f, 0.0f, -6.0f);
	glScalef(3.0f, 3.0f, 1.0f);
	// Futz with foreground rectangle
	

	
	// Select texture matrix prior to push
	glMatrixMode(GL_TEXTURE);
	
	// Push texture matrix and place in sane state
	glPushMatrix();
	glLoadIdentity();
	// Push texture matrix and place in sane state
	
	
	// Futz with texture attached to foreground rectangle
//	glScalef(2.0f, 2.0f, 1.0f);
	glScalef(1.0f, 1.0f, 1.0f);
	// Futz with texture attached to foreground rectangle
	
	glBindTexture(GL_TEXTURE_2D, self.over_texture.name);
    glVertexPointer(  3, GL_FLOAT,         sizeof(TEIVertex), &_rectangle[0].xyz );
    glTexCoordPointer(2, GL_FLOAT,         sizeof(TEIVertex), &_rectangle[0].st  );
    glColorPointer(   4, GL_UNSIGNED_BYTE, sizeof(TEIVertex), &_rectangle[0].rgba);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, _vertexCount);

	// Pop texture matrix
	glPopMatrix();
	// Pop texture matrix
	
	// Select model-view matrix following pop
	glMatrixMode(GL_MODELVIEW);

	
	
	// Futz with foreground rectangle	
	inc += 5.0/10.0;
	// Futz with foreground rectangle
		
	// Pop model-view matrix
	glPopMatrix();
	// Pop model-view matrix

	
	
	
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning]; 
}

@end
