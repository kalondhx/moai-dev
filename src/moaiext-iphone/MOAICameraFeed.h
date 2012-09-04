//
//  MOAICameraFeed.h
//  libmoai
//
//  Created by Julian Spillane on 12-08-21.
//  Copyright (c) 2012 DHX Media Ltd. All rights reserved.
//

#ifndef	MOAICAMERAFEEDIOS_H
#define	MOAICAMERAFEEDIOS_H

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#include <moaicore/moaicore.h>
#include <moaicore/MOAILua.h>

#include <moaicore/MOAITexture.h>

@interface MOAICameraFeedController : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
{
	AVCaptureVideoPreviewLayer* _videoPreviewLayer;
	AVCaptureSession*           _captureSession;
	AVCaptureDeviceInput*       _videoInput;
	AVCaptureVideoDataOutput*   _videoOutput;
	
	MOAIImage* _cameraImage;
@public
	MOAITexture* cameraTexture;
}

- (void)cameraHasConnected;
- (void)processNewCameraFrame:(CVImageBufferRef)cameraFrame;

@property(readonly) AVCaptureVideoPreviewLayer* videoPreviewLayer;

@end

class MOAICameraFeed : public MOAIGlobalClass <MOAICameraFeed, MOAILuaObject>
{
private:
	MOAICameraFeedController* m_pCameraController;
	MOAITexture*              m_pTexture;
	
	// lua methods
	static int _initialize( lua_State* L );
	static int _destroy( lua_State* L );
	static int _getTexture( lua_State* L );
public:
	DECL_LUA_SINGLETON( MOAICameraFeed );
	
	// --------------------------------------------------------------- //
	MOAICameraFeed();
	~MOAICameraFeed();
	
	void Initialize( BOOL bUseFrontCam );	
	void Destroy();
	void RegisterLuaClass( MOAILuaState& state );
	
	inline MOAITexture* GetTexture() { return m_pCameraController->cameraTexture; }
};

#endif