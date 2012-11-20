// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#include "pch.h"

#import <moaiext-iphone/MoaiVideoPlayer.h>
#import <moaiext-iphone/NSDate+MOAILib.h>
#import <MediaPlayer/MPMusicPlayerController.h>


@implementation MovieObserver


/*---------------------------------------------------------------------------
 * Notifications of data downloads 
 *--------------------------------------------------------------------------*/
- (void)myMovieFinished:(NSNotification *)notif 
{
	MOAIVideoPlayer::Get ().VideoDone();
}
- (void)onStatusChanged:(NSNotification *)notif 
{

	MOAIVideoPlayer::Get ().PushVideoState();
}


@end

//================================================================//
// lua
//================================================================//

//----------------------------------------------------------------//
/**	@name	authenticatePlayer
	@text	Makes sure a Game Center is supported and an account is 
			logged in. If none are logged in, will prompt the user 
			to log in. This must be	called before any other 
			MOAIGameCenter functions.
			
	@in		nil
	@out	nil
*/
int MOAIVideoPlayer::_initVideoWithFrameSize ( lua_State* L ) {
	MOAILuaState state ( L );
	int left = lua_tointeger ( state, 1 );
	int top = lua_tointeger ( state, 2 );
	int width = lua_tointeger ( state, 3 );
	int height = lua_tointeger ( state, 4 );	
	MOAIVideoPlayer::Get ().InitVideoWithFrameSize(left, top, width, height);
	return 0;
}
//----------------------------------------------------------------//
int MOAIVideoPlayer::_loadVideo ( lua_State* L ) {
	MOAILuaState state ( L );
	
	return 0;
}
//----------------------------------------------------------------//
int MOAIVideoPlayer::_playVideo ( lua_State* L ) {
	MOAILuaState state ( L );
	cc8* videoName = lua_tostring ( state, 1 );
	int stream = lua_tointeger ( state, 2 );
	MOAIVideoPlayer::Get ().PlayVideo(videoName, stream);
	return 0;
}
//----------------------------------------------------------------//
int MOAIVideoPlayer::_setVolume ( lua_State* L ) {
	MOAILuaState state ( L );
	float vol = lua_tonumber ( state, 2 );
	printf("Set Volume %f\n", vol);
	MOAIVideoPlayer::Get ().SetVolume(vol);
	return 0;
}
//----------------------------------------------------------------//
int MOAIVideoPlayer::_stop ( lua_State* L ) {
	MOAILuaState state ( L );
	MOAIVideoPlayer::Get ().Stop();
	
	return 0;
}
//----------------------------------------------------------------//
int MOAIVideoPlayer::_pause ( lua_State* L ) {
	MOAILuaState state ( L );
	
	MOAIVideoPlayer::Get ().Pause();
	return 0;
}
//----------------------------------------------------------------//
int MOAIVideoPlayer::_unpause ( lua_State* L ) {
	MOAILuaState state ( L );
	
	MOAIVideoPlayer::Get ().Unpause();
	return 0;
}
//----------------------------------------------------------------//
int MOAIVideoPlayer::_hideVideo ( lua_State* L ) {
	MOAILuaState state ( L );
	
	
	return 0;
}
//----------------------------------------------------------------//
int MOAIVideoPlayer::_showVideo ( lua_State* L ) {
	MOAILuaState state ( L );
	
	
	return 0;
}
//----------------------------------------------------------------//
int MOAIVideoPlayer::_fullscreen ( lua_State* L ) {
	MOAILuaState state ( L );
	MOAIVideoPlayer::Get ().FullScreen();	
	return 0;
}
//----------------------------------------------------------------//
int	MOAIVideoPlayer::_scaleDown	( lua_State* L )
{
	MOAILuaState state ( L );
	MOAIVideoPlayer::Get ().ScaleDown();
	return 0;
}
//----------------------------------------------------------------//
int	MOAIVideoPlayer::_currentTime( lua_State* L )
{
	MOAILuaState state ( L );
	lua_pushnumber(L, MOAIVideoPlayer::Get ().CurrentTime());
	return 1;	
}


int MOAIVideoPlayer::_setMovieCallback ( lua_State* L ) {
	//MOAI_LUA_SETUP ( MOAIVideoPlayer, "F" )
	MOAILuaState state ( L );
	//self->mCallback.SetStrongRef ( state, 2 );
	MOAIVideoPlayer::Get ().SetCallback(state);
	return 0;
}
int MOAIVideoPlayer::_setStateCallback ( lua_State* L ){
	MOAILuaState state ( L );
	MOAIVideoPlayer::Get ().SetStateCallback(state);
	return 0;
}
//----------------------------------------------------------------//
MOAIVideoPlayer::MOAIVideoPlayer () {

	RTTI_SINGLE ( MOAILuaObject )		
	movieContainer = 0;
	observer = [[MovieObserver alloc] init];
}

//----------------------------------------------------------------//
MOAIVideoPlayer::~MOAIVideoPlayer () {
	
}

//----------------------------------------------------------------//
void MOAIVideoPlayer::RegisterLuaClass ( MOAILuaState& state ) {

	luaL_Reg regTable[] = {
		{ "initVideoWithFrameSize",			_initVideoWithFrameSize },
		{ "loadVideo",					_loadVideo },
		{ "playVideo",					_playVideo },
		{ "stop",				_stop },
		{ "pause",	_pause },
		{ "unpause",	_unpause },
		{ "hideVideo",		_hideVideo },
		{ "showVideo",	_showVideo },
		{ "fullscreen",		_fullscreen },
		{ "scaleDown",		_scaleDown },
		{ "currentTime",		_currentTime },
		{ "setVolume",		_setVolume },
		{ "setMovieCallback",		_setMovieCallback },
		{ "setStateCallback",		_setStateCallback },
		{ NULL, NULL }
	};

	luaL_register( state, 0, regTable );
}

void MOAIVideoPlayer::InitVideoWithFrameSize(int x, int y, int w, int h)
{
	if(movieContainer == 0)
	{
	UIWindow* mWindow = [[ UIApplication sharedApplication ] keyWindow ];
	[[mWindow.subviews objectAtIndex:0] setBackgroundColor:[UIColor clearColor]];
	UIViewController* rootVC = [ mWindow rootViewController ];	
	originalSize = CGRectMake(0, 0, w, h);
	// I dont know what the hell I'm doing
	originalOffset = CGPointMake(x, y);
	
	 if( rootVC.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		//NSLog(@"LANDSCAPE RIGHT\n");
		float yout = originalOffset.x;
		float xout = -originalOffset.y + [mWindow bounds].size.width;
		originalOffset.x = xout - h/2;
		originalOffset.y = yout + w/2;
		
	}
	else if (rootVC.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		//NSLog(@"LANDSCAPE LEFT\n");
		float yout = -originalOffset.x + [mWindow bounds].size.height;
		float xout = originalOffset.y;
		originalOffset.x = xout + h/2;
		originalOffset.y = yout - w/2;
		
	}
	else if (rootVC.interfaceOrientation == UIInterfaceOrientationPortrait) {
		//NSLog(@"PORTRAIT\n");
		float xout = originalOffset.x;
		float yout = originalOffset.y;
		originalOffset.x = xout + w/2;
		originalOffset.y = yout + h/2;
		
	}
	//printf("(%f, %f)\n", originalOffset.x, originalOffset.y); 
	movieContainer = [[UIView alloc] init];
	[movieContainer setFrame:originalSize];
	
	//mpviewController = [[MPMoviePlayerViewController alloc] init];
	mpPlayerController = [[MPMoviePlayerController alloc] init ];
	//MPMoviePlayerController *mp = [mpviewController moviePlayer];
	[mpPlayerController.view setFrame:movieContainer.frame];       
	//mpviewController.wantsFullScreenLayout = false;
	mpPlayerController.scalingMode = MPMovieScalingModeAspectFit;
	mpPlayerController.controlStyle = MPMovieControlStyleNone;
	//mWindow.autoresizesSubviews = NO;
	[movieContainer addSubview:mpPlayerController.view];    	
	[mWindow addSubview:movieContainer ];
	[mWindow sendSubviewToBack:movieContainer];
	baseController = [mWindow rootViewController];
	
	CGAffineTransform t = [rootVC.view transform];
	movieContainer.transform = t;
	movieContainer.center = CGPointMake(originalOffset.x, originalOffset.y);
	//printf("precenters1 (%f, %f)\n", movieContainer.center.x, movieContainer.center.y);
	//printf("precenters2 (%f, %f)\n", mpPlayerController.view.center.x, mpPlayerController.view.center.y);
	//printf("preSize (%f, %f)\n", originalSize.size.width, originalSize.size.height);
	originalSize = movieContainer.frame;
		
		[[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(myMovieFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:mpPlayerController];
		[[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(onStatusChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:mpPlayerController];
		
	}

}

void MOAIVideoPlayer::PlayVideo(const char* video, bool stream)
{
	MPMoviePlayerController *mp = mpPlayerController;
	NSString *movpath;
	NSURL * url;
	if(stream)
	{
		movpath = [[NSString alloc] initWithUTF8String:video];
		url = [NSURL URLWithString:movpath];
	}
	else
	{
		movpath = [[NSBundle mainBundle] pathForResource:[[NSString alloc] initWithUTF8String:video] ofType:@"mp4"];
		url = [NSURL fileURLWithPath:movpath];
	}
	[mp setContentURL:url]; 
	
	if(stream)
	{
		[mp setMovieSourceType:MPMovieSourceTypeStreaming];
	}	
	[mp play];
}


void MOAIVideoPlayer::Stop()
{
	[mpPlayerController stop];
	UIWindow* mWindow = [[ UIApplication sharedApplication ] keyWindow ];
	[[mWindow.subviews objectAtIndex:0] setBackgroundColor:[UIColor blackColor]];
	
}

void MOAIVideoPlayer::FullScreen()
{
	MPMoviePlayerController *mp = mpPlayerController;	
	     
	UIWindow* window = [[ UIApplication sharedApplication ] keyWindow ];
	
	UIViewController* rootVC = [ window rootViewController ];		
	movieContainer.transform = CGAffineTransformIdentity;
	[movieContainer setFrame:CGRectMake(0, 0, [window bounds].size.width, [window bounds].size.height)];
	if (rootVC.interfaceOrientation == UIInterfaceOrientationPortrait) 
	{
		[mpPlayerController.view setFrame:CGRectMake(0, 0, [window bounds].size.width, [window bounds].size.height)];  
		
	}
	else
	{
		[mpPlayerController.view setFrame:CGRectMake(0, 0, [window bounds].size.height, [window bounds].size.width)];  		
	}
	mpPlayerController.view.transform = [rootVC.view transform];
	mpPlayerController.view.center = movieContainer.center;
	
}

void MOAIVideoPlayer::ScaleDown()
{
	MPMoviePlayerController *mp = mpPlayerController;
	
	UIWindow* window = [[ UIApplication sharedApplication ] keyWindow ];
	UIViewController* rootVC = [ window rootViewController ];
	
	movieContainer.transform = [rootVC.view transform];		
	mpPlayerController.view.transform = CGAffineTransformIdentity;
	[movieContainer setFrame:originalSize];
	[mpPlayerController.view setFrame:CGRectMake(0, 0, originalSize.size.height, originalSize.size.width)];  	
	
	mpPlayerController.scalingMode = MPMovieScalingModeAspectFit;
	mpPlayerController.controlStyle = MPMovieControlStyleNone;
	
	movieContainer.center = originalOffset;
	
}

void MOAIVideoPlayer::Pause()
{
	MPMoviePlayerController *mp = mpPlayerController;
	[mp pause];
}
void MOAIVideoPlayer::Unpause()
{
	
	MPMoviePlayerController *mp = mpPlayerController;
	[mp play];
}

float	MOAIVideoPlayer::CurrentTime()
{
	
	MPMoviePlayerController *mp = mpPlayerController;
	return [mp currentPlaybackTime];
	
}


void MOAIVideoPlayer::SetVolume(float v)
{
	[[MPMusicPlayerController applicationMusicPlayer] setVolume:v];
}

void MOAIVideoPlayer::VideoDone()
{
	if(this->mCallback)
	{
		MOAILuaStateHandle state = this->mCallback.GetSelf ();
		state.DebugCall ( 0, 0 );
	}
}

void MOAIVideoPlayer::PushVideoState()
{
	if(this->mStateCallback)
	{
		printf("Loadstate is %d\n", (int)[mpPlayerController loadState]);
		MOAILuaStateHandle state = this->mStateCallback.GetSelf ();
		lua_pushnumber ( state, (int)[mpPlayerController loadState] );
		state.DebugCall ( 1, 0 );
	}
}


void MOAIVideoPlayer::SetCallback(MOAILuaState & s)
{	
	mCallback.SetStrongRef ( s, 1 );
}


void MOAIVideoPlayer::SetStateCallback(MOAILuaState & s)
{	
	mStateCallback.SetStrongRef ( s, 1 );
}
