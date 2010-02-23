//
//  JLMMatrixLibrary.h
//  HelloTeapot
//
//  Created by turner on 4/30/09.
//  Copyright 2009 Douglass Turner Consulting. All rights reserved.
//

#ifndef _JLM_MATRIX_LIBRARY_
#define _JLM_MATRIX_LIBRARY_

#ifdef __cplusplus
extern "C" {
#endif
		
typedef float JLMMatrix3D[16];
	
void JLMMatrix3DMultiply(JLMMatrix3D m1, JLMMatrix3D m2, JLMMatrix3D result);

void JLMMatrix3DSetIdentity(JLMMatrix3D matrix);

void JLMMatrix3DSetTranslation(JLMMatrix3D matrix, float xTranslate, float yTranslate, float zTranslate);

void JLMMatrix3DSetScaling(JLMMatrix3D matrix, float xScale, float yScale, float zScale);

void JLMMatrix3DSetUniformScaling(JLMMatrix3D matrix, float scale);

void JLMMatrix3DSetXRotationUsingRadians(JLMMatrix3D matrix, float degrees);
void JLMMatrix3DSetXRotationUsingDegrees(JLMMatrix3D matrix, float degrees);

void JLMMatrix3DSetYRotationUsingRadians(JLMMatrix3D matrix, float degrees);
void JLMMatrix3DSetYRotationUsingDegrees(JLMMatrix3D matrix, float degrees);

void JLMMatrix3DSetZRotationUsingRadians(JLMMatrix3D matrix, float degrees);
void JLMMatrix3DSetZRotationUsingDegrees(JLMMatrix3D matrix, float degrees);

void JLMMatrix3DSetRotationByRadians(JLMMatrix3D matrix, float angle, float x, float y, float z);
void JLMMatrix3DSetRotationByDegrees(JLMMatrix3D matrix, float angle, float x, float y, float z);
	
#ifdef __cplusplus
}
#endif

#endif
