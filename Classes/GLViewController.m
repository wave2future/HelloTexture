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
	
	
	_over_texture	= [ [TEITexture alloc] initWithImageFile:@"kids_grid_3x3_translucent" extension:@"png" mipmap:YES ];
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
	vertex->rgba[2] = a;
	
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

-(void)setupView:(GLView*)view {
	
	glEnable(GL_DEPTH_TEST);
	
	const GLfloat zNear			=    0.01; 
	const GLfloat zFar			= 1000.0; 
	const GLfloat fieldOfView	=   45.0; 
	
	GLfloat size	= zNear * tanf(m3dDegToRad(fieldOfView) / 2.0); 
	GLfloat w		= view.bounds.size.width;
	GLfloat h		= view.bounds.size.height;
	
	glMatrixMode(GL_PROJECTION);
	glFrustumf(-size, size, -size / (w / h), size / (w / h), zNear, zFar); 
	glViewport(0, 0, w, h);
	
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

	static GLfloat inc = 0.0f;	
	GLfloat angle = m3dRadToDeg(M_PI) * (1.0f - ((1.0f + cosf(m3dDegToRad(inc))) / 2.0f));
	
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
	glScalef(3.0f/1.0f, 3.0f/1.0f, 1.0f);
	
//	glRotatef(15.0f, 0.0f, 0.0f, 1.0f);
	
	glTranslatef( 1.0f/2.0f,  1.0f/2.0f, 1.0f);
	glRotatef(4.0 * angle, 0.0f, 0.0f, 1.0f);
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
	glRotatef(angle, 0.0f, 0.0f, 1.0f);
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
	glScalef(2.0f, 2.0f, 1.0f);
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
