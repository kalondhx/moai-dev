// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#include "pch.h"

#import <moaiext-iphone/MOAIImagePicker.h>
#import <moaiext-iphone/NSDate+MOAILib.h>

@implementation MOAIImagePickerController
-(id)init
{
	self = [super init];
	if( self )
	{
		m_pPickerParent			 = NULL;
		m_pPopover				 = NULL;
		m_pImagePickerController = NULL;
		m_pRootVC				 = NULL;
	}
}

/**
 * Initialize()
 * Initializes the ImagePicker and determines if the user has camera functionality
 * @param pickerParent The MOAIImagePicker class that is invoking this method
 */
-(void) Initialize:(MOAIImagePicker*)pickerParent WithOverlay:(NSString*)overlayPath
{
	m_pPickerParent          = pickerParent;
	
	// if we've already allocated the controller, kill it and realloc it
	if( m_pImagePickerController != NULL )
		[m_pImagePickerController release];
	
	if( m_pPopover != NULL )
		[m_pPopover release];
		
	// initialize the properties of the image picker controller and assign delegates
	m_pImagePickerController = [[UIImagePickerController alloc] init];
	[m_pImagePickerController setDelegate:self];
	
	UIWindow* mWindow = [[ UIApplication sharedApplication ] keyWindow ];
	m_pRootVC = [ mWindow rootViewController ];
	
	// if there is a camera on the device, use that otherwise, pick from the device's photo library
	if( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] )
	{
		[m_pImagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
		
		// check to see if there's an overlay image and load it
		if( [overlayPath length] > 0 )
		{
			NSString *fileLocation = [[NSBundle mainBundle] pathForResource:overlayPath ofType:nil];
			NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
			
			UIImageView* pImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
			CGRect rect = CGRectMake(0,0,pImageView.image.size.width, pImageView.image.size.height);
			pImageView.frame = rect;
			m_pImagePickerController.cameraOverlayView = pImageView;
		}
		
		[m_pRootVC presentModalViewController:m_pImagePickerController animated:YES];
	}
	else
	{
		[m_pImagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];

		// if we're on an iPhone, this will work just fine as a modal popup
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) 
		{
			[m_pRootVC presentModalViewController:m_pImagePickerController animated:YES];
		}
		// we must be in an iPad that doesn't have a camera, so open as a popover
		else
		{
			// JULIAN TO-DO: figure out a better size for the popup
			m_pPopover = [[UIPopoverController alloc] initWithContentViewController:m_pImagePickerController];
			[m_pPopover setDelegate:self];
			m_pPopover.delegate = self;
			[m_pPopover presentPopoverFromRect:CGRectMake(10,10,500,500) inView:m_pRootVC.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
	}
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	
	// If you go to the folder below, you will find those pictures
	NSString *pngPath = [NSString stringWithFormat:@"%@/photo_temp.png",docDir];
		
	[UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
	[m_pRootVC dismissModalViewControllerAnimated:YES];
	
	if( m_pPopover != NULL )
	{
		[m_pPopover dismissPopoverAnimated:YES];
	}
	
	const char* pngPathC = [pngPath cStringUsingEncoding:NSASCIIStringEncoding];
	m_pPickerParent->SetImagePath((char*)pngPathC);
	m_pPickerParent->SetCaptured(true);
}
@end

//================================================================//
// lua
//================================================================//

//----------------------------------------------------------------//
/**	@name	_captureImage
 @text	Invokes the camera (or image browser) and attempts to capture an image
 @in	string	overlayPath			Path to overlay image (relative to the base application directory)
 @out   nil
 */
int MOAIImagePicker::_captureImage( lua_State *L )
{
	MOAILuaState state ( L );
	NSString* overlayPath = [[ NSString alloc ] initWithUTF8String:state.GetValue< cc8* >( 1, "" ) ];
	MOAIImagePicker::Get ().Initialize(overlayPath);	
	return 0;
}

int MOAIImagePicker::_isCaptured ( lua_State* L )
{
	MOAILuaState state ( L );
	
	lua_pushboolean( state, MOAIImagePicker::Get ().GetCaptured() );
	return 1;
}

int MOAIImagePicker::_imagePath ( lua_State* L )
{
	MOAILuaState state ( L );
	
	lua_pushstring( L, MOAIImagePicker::Get ().GetImagePath().c_str() );
	return 1;
}

//----------------------------------------------------------------//
MOAIImagePicker::MOAIImagePicker ()
{
	RTTI_SINGLE ( MOAILuaObject )		
	m_pCameraContainer       = NULL;
	m_pImagePickerController = NULL;
	m_bCaptured              = false;
}

//----------------------------------------------------------------//
MOAIImagePicker::~MOAIImagePicker () 
{	
}

void MOAIImagePicker::Initialize(NSString* overlayPath)
{
	UIWindow* mWindow = [[ UIApplication sharedApplication ] keyWindow ];
	UIViewController* rootVC = [ mWindow rootViewController ];
	
	m_bCaptured = false;
	
	if( m_pImagePickerController != NULL )
	{
		[m_pImagePickerController release];
	}
	
	m_pImagePickerController = [[MOAIImagePickerController alloc] init];
	

	[m_pImagePickerController.view setFrame:CGRectMake(0,0,[mWindow bounds].size.width, [mWindow bounds].size.height)];
	m_pImagePickerController.view.transform = [rootVC.view transform];
		
	[m_pImagePickerController Initialize:this WithOverlay:overlayPath];
}

void MOAIImagePicker::GetImage()
{
	MOAIImage* pImg = new MOAIImage();
	
	CFDataRef pData = CGDataProviderCopyData(CGImageGetDataProvider(m_pImage.CGImage));
	
	USColor::Format fmt = USColor::RGBA_8888;
	pImg->Init((void*)CFDataGetBytePtr(pData), CGImageGetWidth(m_pImage.CGImage), CGImageGetHeight(m_pImage.CGImage), fmt);
}

//----------------------------------------------------------------//
void MOAIImagePicker::RegisterLuaClass ( MOAILuaState& state ) 
{

	luaL_Reg regTable[] = 
	{
		{ "takePicture",           _captureImage     },
		{ "isCaptured",			   _isCaptured		 },
		{ "imagePath",             _imagePath        },
		{ NULL, NULL }
	};

	luaL_register( state, 0, regTable );
}
