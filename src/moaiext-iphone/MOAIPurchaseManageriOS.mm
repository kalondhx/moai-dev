//
//  MOAIPurchaseManageriOS.m
//  libmoai
//
//  Created by Kalon Winnik on 2012-11-22.
//
//

#include "pch.h"


#include <moaiext-iphone/MOAIPurchaseManageriOS.h>


//================================================================//
// lua
//================================================================//

//----------------------------------------------------------------//
/**	@name	init
 @text	Initialize the video player with the URL of a video to play.
 
 @in		string 	url				The URL of the video to play.
 @out	nil
 */
int MOAIPurchaseManageriOS::_init ( lua_State* L ) {
	
	USLog::Print ( "set activity info" );
	USLog::Print ( "MOAIPurchaseManageriOS::_init SetActivity" );
	USLog::Print ( "MOAIPurchaseManageriOS::_init Init" );
	MOAIPurchaseManageriOS::Get().Init();
	USLog::Print ( "MOAIPurchaseManageriOS::_init Post Init" );
	MOAIPurchaseManageriOS::Get().SetSecret("36011eee133e4c08913252eb3b0aa4d2");
	return 0;
}

//----------------------------------------------------------------//
/**	@name	play
 @text	Play the video as soon as playback is ready.
 
 @out	nil
 */
int MOAIPurchaseManageriOS::_requestPurchase ( lua_State* L ) {
	printf("Request purchase\n");
	MOAILuaState state ( L );
	const char* com = lua_tostring ( state, 1 );
	MOAIPurchaseManageriOS::Get().RequestPurchase(com);
	return 0;
}


int MOAIPurchaseManageriOS::_requestSubscription ( lua_State* L ) {
	
	MOAILuaState state ( L );
	const char* com = lua_tostring ( state, 1 );
	MOAIPurchaseManageriOS::Get().RequestSubscription(com);
	return 0;
}

int MOAIPurchaseManageriOS::_setListener ( lua_State* L ) {
	
	MOAILuaState state ( L );
	
	u32 idx = state.GetValue < u32 >( 1, TOTAL );
	
	if ( idx < TOTAL ) {
		
		MOAIPurchaseManageriOS::Get ().mListeners [ idx ].SetStrongRef ( state, 2 );
	}
	
	return 0;
}

//================================================================//
// MOAIPurchaseManageriOS
//================================================================//

//----------------------------------------------------------------//
MOAIPurchaseManageriOS::MOAIPurchaseManageriOS () {
	
	RTTI_SINGLE ( MOAILuaObject )
}

//----------------------------------------------------------------//
MOAIPurchaseManageriOS::~MOAIPurchaseManageriOS () {
	
}

//----------------------------------------------------------------//
void MOAIPurchaseManageriOS::RegisterLuaClass ( MOAILuaState& state ) {
	
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

void MOAIPurchaseManageriOS::OnPurchaseStateChanged(const char* itemID, int purchaseState, const char* json)
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
