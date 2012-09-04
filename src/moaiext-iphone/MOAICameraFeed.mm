

//
//  MOAICameraFeed.m
//  libmoai
//
//  Created by Julian Spillane on 12-08-21.
//  Copyright (c) 2012 DHX Media Ltd. All rights reserved.
//

#include "pch.h"

#import <moaiext-iphone/MOAICameraFeed.h>
#import <moaiext-iphone/NSDate+MOAILib.h>

#import <UIKit/UIKit.h>

#include <moaicore/MOAIImage.h>

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXTUREPOSITON,
    NUM_ATTRIBUTES
};

@implementation MOAICameraFeedController

#pragma mark -
#pragma mark Init and Destroy

- (id)init:(bool)frontFacing;
{
	if( !(self = [super init]) )
		return nil;
	
	_cameraImage = nil;
	cameraTexture= nil;
	
	// are we using the front facing camera or rear?
	AVCaptureDevice* camera = nil;
	
	NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for( AVCaptureDevice* device in devices )
	{
		if( frontFacing && [device position] == AVCaptureDevicePositionFront )
		{
			camera = device;
			break;
		}
		else if( !frontFacing && [device position] == AVCaptureDevicePositionBack )
		{
			camera = device;
			break;
		}
	}
	
	// initialize the capture session
	_captureSession = [[AVCaptureSession alloc] init];
	
	// add the video input
	NSError* error = nil;

	_videoInput = [[[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error] autorelease];
	
	if( [_captureSession canAddInput:_videoInput] )
		[_captureSession addInput:_videoInput];
		
	//[self videoPreviewLayer];
	
	// add the video frame output
	_videoOutput = [[AVCaptureVideoDataOutput alloc] init];
	[_videoOutput setAlwaysDiscardsLateVideoFrames:YES];
	
	// set to use RGB instead of YUV
	[_videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
	
	[_videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	
	if( [_captureSession canAddOutput:_videoOutput] )
	{
		[_captureSession addOutput:_videoOutput];
	}
	else
	{
		NSLog(@"Couldn't add video output. :(");
	}
	
	// make sure it's oriented properly
	AVCaptureConnection* videoConnection = nil;
	
	for ( AVCaptureConnection *connection in [_videoOutput connections] ) 
	{
		for ( AVCaptureInputPort *port in [connection inputPorts] ) 
		{
			if ( [[port mediaType] isEqual:AVMediaTypeVideo] ) 
			{
				videoConnection = connection;
				break;
			}
		}
	}
	
    if([videoConnection isVideoOrientationSupported]) 
	{
		[videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
	}

	// begin capturing
	[_captureSession setSessionPreset:AVCaptureSessionPreset352x288];
	
	if( ![_captureSession isRunning] )
	{
		[_captureSession startRunning];
	}
	
	return self;
}

- (void)dealloc
{
	[_captureSession stopRunning];
	[_captureSession release];
	
	[_videoPreviewLayer release];
	[_videoOutput release];
	[_videoInput release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection*)connection
{
	CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	//[self processNewCameraFrame:pixelBuffer];
	
	CVPixelBufferLockBaseAddress(pixelBuffer, 0);
	int bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
	int bufferWidth  = CVPixelBufferGetWidth(pixelBuffer);
	
	// Create a new texture from the camera frame data, display that using the shaders
	if( _cameraImage == nil )
	{
		_cameraImage = new MOAIImage();
	}

	_cameraImage->Init(CVPixelBufferGetBaseAddress(pixelBuffer), bufferWidth, bufferHeight, USColor::RGBA_8888);
		
	if( cameraTexture == nil )
	{
		cameraTexture = new MOAITexture();
	}
	
	cameraTexture->Init(*_cameraImage, "camtex", true);
	
	CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

#pragma mark -
#pragma mark Accessor Methods
@synthesize videoPreviewLayer;

- (AVCaptureVideoPreviewLayer*)videoPreviewLayer
{
	if( _videoPreviewLayer == nil )
	{
		_videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
		
		if( [_videoPreviewLayer isOrientationSupported] )
		{
			[_videoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
		}
		
		[_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	}
	
	return _videoPreviewLayer;
}

@end

// ------------
// LUA 
// ------------
int MOAICameraFeed::_initialize(lua_State *L)
{
	MOAILuaState state( L );
	
	bool bFront = state.GetValue<bool>(1, true);
	MOAICameraFeed::Get().Initialize(bFront);
	return 0;
}

int MOAICameraFeed::_destroy( lua_State* L )
{
	MOAILuaState state( L );
	
	MOAICameraFeed::Get().Destroy();
	return 0;
}

int MOAICameraFeed::_getTexture(lua_State *L)
{
	MOAILuaState state ( L );
	
	MOAITexture* pTex = MOAICameraFeed::Get().GetTexture();
	
	int nAddress = (int)pTex;
	lua_pushnumber(state, nAddress );
	
	return 1;
}

//---------------------------------------------------
MOAICameraFeed::MOAICameraFeed()
{
	RTTI_SINGLE( MOAILuaObject )
}

MOAICameraFeed::~MOAICameraFeed()
{
	[m_pCameraController release];
}

void MOAICameraFeed::Initialize( BOOL bUseFrontCamera )
{
	m_pCameraController = [[MOAICameraFeedController alloc] init:bUseFrontCamera];
}

void MOAICameraFeed::Destroy()
{
	if( m_pCameraController != nil )
	{
		[m_pCameraController release];
		m_pCameraController = nil;
	}
}

void MOAICameraFeed::RegisterLuaClass(MOAILuaState &state)
{
	luaL_Reg regTable[] =
	{
		{ "initialize", _initialize },
		{ "getTexture", _getTexture },
		{ "destroy", _destroy },
		{ NULL, NULL }
	};
	
	luaL_register( state, 0, regTable );
}