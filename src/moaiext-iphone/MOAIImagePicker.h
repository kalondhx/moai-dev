// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#ifndef	MOAIIMAGEPICKER_H
#define	MOAIIMAGEPICKER_H

#include <UIKit/UIKit.h>
#include <UIKit/UIImagePickerController.h>

#import <Foundation/Foundation.h>
#import <moaicore/moaicore.h>

#include <moaicore/MOAILua.h>

class MOAIImagePicker;

@interface MOAIImagePickerController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
{
	UIImage* m_pFinalImage;
	UIImagePickerController* m_pImagePickerController;
	UIScrollView *filtersScrollView; 
	MOAIImagePicker* m_pPickerParent;
	UIViewController* m_pRootVC;
	
	UIPopoverController* m_pPopover;	// for camera-less iPads
};
- (void) Initialize:(MOAIImagePicker*)pickerParent WithOverlay:(NSString*)overlayPath;
@end

class MOAIImagePicker : public MOAIGlobalClass < MOAIImagePicker, MOAILuaObject > 
{
private:
	UIView*                    m_pCameraContainer;
	UIViewController*          m_pViewController;
	MOAIImagePickerController* m_pImagePickerController;
	UIImage*                   m_pImage;
	
	
	std::string                m_strImagePath;
	BOOL                       m_bCaptured;
	
	
	// lua methods
	static int _captureImage( lua_State* L );
	static int _isCaptured ( lua_State* L );
	static int _imagePath ( lua_State* L );
public:
	
	DECL_LUA_SINGLETON ( MOAIImagePicker );
	
	//----------------------------------------------------------------//
	MOAIImagePicker();
	~MOAIImagePicker();
	
	void Initialize( NSString* overlayPath );
	
	void RegisterLuaClass( MOAILuaState& state );
	
	void SetImage( UIImage* pImage ) { m_pImage = pImage; }
	void GetImage();
	
	void SetImagePath( char* strPath ) { m_strImagePath = strPath; }
	const std::string& GetImagePath() { return m_strImagePath; }
	
	void SetCaptured( BOOL bVal ) { m_bCaptured = bVal; }
	inline BOOL GetCaptured() { return m_bCaptured; }
};


#endif
