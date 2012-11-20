#include "pch.h"

#include <jni.h>

#include <moaiext-android/moaiext-jni.h>
#include <moaiext-android/MOAIDHXIAPAndroid.h>

extern JavaVM* jvm;

//================================================================//
// lua
//================================================================//

//----------------------------------------------------------------//
/**	@name	init
	@text	Initialize the video player with the URL of a video to play.
	
	@in		string 	url				The URL of the video to play.
	@out	nil
*/
int MOAIDHXIAPAndroid::_init ( lua_State* L ) {
	
	USLog::Print ( "set activity info" );
	USLog::Print ( "MOAIDHXIAPAndroid::_init SetActivity" );
	MOAIDHXIAPAndroid::Get().SetActivity("com/dhxmedia/piko/MoaiActivity", "currentActivity");
	USLog::Print ( "MOAIDHXIAPAndroid::_init Init" );
	MOAIDHXIAPAndroid::Get().Init();
	USLog::Print ( "MOAIDHXIAPAndroid::_init Post Init" );
	return 0;
}

//----------------------------------------------------------------//
/**	@name	play
	@text	Play the video as soon as playback is ready.
	
	@out	nil
*/
int MOAIDHXIAPAndroid::_requestPurchase ( lua_State* L ) {
	
	MOAILuaState state ( L );
	const char* com = lua_tostring ( state, 1 );
	MOAIDHXIAPAndroid::Get().RequestPurchase(com);
	return 0;
}


int MOAIDHXIAPAndroid::_requestSubscription ( lua_State* L ) {
	
	MOAILuaState state ( L );
	const char* com = lua_tostring ( state, 1 );
	MOAIDHXIAPAndroid::Get().RequestSubscription(com);
	return 0;
}

int MOAIDHXIAPAndroid::_setListener ( lua_State* L ) {
	
	MOAILuaState state ( L );
	
	u32 idx = state.GetValue < u32 >( 1, TOTAL );
	
	if ( idx < TOTAL ) {
		
		MOAIDHXIAPAndroid::Get ().mListeners [ idx ].SetStrongRef ( state, 2 );
	}
	
	return 0;
}

//================================================================//
// MOAIDHXIAPAndroid
//================================================================//

//----------------------------------------------------------------//
MOAIDHXIAPAndroid::MOAIDHXIAPAndroid () {

	RTTI_SINGLE ( MOAILuaObject )	
}

//----------------------------------------------------------------//
MOAIDHXIAPAndroid::~MOAIDHXIAPAndroid () {

}

//----------------------------------------------------------------//
void MOAIDHXIAPAndroid::RegisterLuaClass ( MOAILuaState& state ) {

	state.SetField ( -1, "DHX_IAP_RESPONSE", 		( u32 )DHX_IAP_RESPONSE );
	state.SetField ( -1, "DHX_IAP_PURCHASE_STATE_CHANGED",	( u32 )DHX_IAP_PURCHASE_STATE_CHANGED );
	
	luaL_Reg regTable[] = {
		{ "init",			_init },
		{ "requestPurchase",			_requestPurchase },
		{ "setListener",	_setListener },
		{ NULL, NULL }	
	};

	luaL_register ( state, 0, regTable );
}

void MOAIDHXIAPAndroid::OnPurchaseStateChanged(const char* itemID, int purchaseState, const char* json)
{
	DHX::PurchaseManager::OnPurchaseStateChanged(itemID, purchaseState, json);
	
	MOAILuaRef& callback = this->mListeners [ DHX_IAP_PURCHASE_STATE_CHANGED ];
		
	if ( callback ) {
		
		MOAILuaStateHandle state = callback.GetSelf ();
		lua_pushstring ( state, itemID );
		lua_pushnumber ( state, purchaseState );
		lua_pushstring ( state, json );
		state.DebugCall ( 3, 0 );
	}
	
}
