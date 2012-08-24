// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#ifndef	MOAIVIDEOPLAYER_H
#define	MOAIVIDEOPLAYER_H

#include <MediaPlayer/MPMoviePlayerViewController.h>
#include <MediaPlayer/MPMoviePlayerController.h>
#import <moaicore/moaicore.h>

#include <moaicore/MOAILua.h>
@interface MovieObserver : NSObject 
{
	
};
-(void) myMovieFinished:(NSNotification *)notif;
-(void) onStatusChanged:(NSNotification *)notif;
@end
@class MoaiLeaderboardDelegate;
@class MoaiAchievementDelegate;

//================================================================//
// MOAIGameCenter
//================================================================//
/**	@name	MOAIGameCenter
	@text	Wrapper for iOS Game Center functionality

*/

class MOAIVideoPlayer :
	public MOAIGlobalClass < MOAIVideoPlayer, MOAILuaObject > {
private:
		
		//MPMoviePlayerViewController* mpviewController;
		UIView* movieContainer;
		MPMoviePlayerController* mpPlayerController;
		UIViewController* baseController;
		CGRect originalSize;
		CGPoint originalOffset;
		MovieObserver* observer;
		MOAILuaRef	mCallback;
		MOAILuaRef	mStateCallback;
	//----------------------------------------------------------------//
	static int		_initVideoWithFrameSize			( lua_State* L );
		static int		_loadVideo			( lua_State* L );
		static int		_playVideo			( lua_State* L );
		static int		_stop			( lua_State* L );
		static int		_pause			( lua_State* L );
		static int		_unpause			( lua_State* L );
		static int		_hideVideo			( lua_State* L );
		static int		_showVideo			( lua_State* L );
		static int		_fullscreen			( lua_State* L );
		static int		_currentTime			( lua_State* L );
		static int		_scaleDown			( lua_State* L );
		static int		_setVolume			( lua_State* L );
		static int		_setMovieCallback ( lua_State* L );
		static int		_setStateCallback ( lua_State* L );
	
public:
	
	DECL_LUA_SINGLETON ( MOAIVideoPlayer );
	
	//----------------------------------------------------------------//
					MOAIVideoPlayer					();
					~MOAIVideoPlayer					();
	void			RegisterLuaClass				( MOAILuaState& state );
		void			InitVideoWithFrameSize(int x, int y, int w, int h);
		void			PlayVideo(const char* video, bool stream);
		void			FullScreen();
		void			ScaleDown();
		void			Pause();
		void			Unpause();
		float				CurrentTime();
		void				SetVolume(float);
		void			Stop();
		void			VideoDone();
		void			SetCallback( MOAILuaState& s);
		void			SetStateCallback( MOAILuaState& s);
		
		
		void			PushVideoState();
};


#endif
