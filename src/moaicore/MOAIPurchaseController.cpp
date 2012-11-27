#include "pch.h"
#include <moaicore/MOAIPurchaseController.h>


//================================================================//
// lua
//================================================================//

//----------------------------------------------------------------//
/**	@name	init
	@text	Initialize the video player with the URL of a video to play.
	
	@in		string 	url				The URL of the video to play.
	@out	nil
*/
int MOAIPurchaseController::_init ( lua_State* L ) {
	
	MOAILuaState state ( L );
	
	const char* activityClass = lua_tostring ( state, 1 );
	const char* activityMember = lua_tostring ( state, 2 );
	
	USLog::Print ( "set activity info" );
	USLog::Print ( "MOAIPurchaseController::_init SetActivity %s %s", activityClass, activityMember );
	//MOAIPurchaseController::Get().SetActivity("com/dhxmedia/piko/MoaiActivity", "currentActivity");
	MOAIPurchaseController::Get().SetActivity(activityClass, activityMember);
	USLog::Print ( "MOAIPurchaseController::_init Init" );
	MOAIPurchaseController::Get().Init();
	USLog::Print ( "MOAIPurchaseController::_init Post Init" );
	return 0;
}

//----------------------------------------------------------------//
/**	@name	play
	@text	Play the video as soon as playback is ready.
	
	@out	nil
*/
int MOAIPurchaseController::_requestPurchase ( lua_State* L ) {
	
	MOAILuaState state ( L );
	const char* com = lua_tostring ( state, 1 );
	MOAIPurchaseController::Get().RequestPurchase(com);
	return 0;
}


int MOAIPurchaseController::_restorePurchases ( lua_State* L ) {
	
	MOAIPurchaseController::Get().RestorePurchases();
	return 0;
}

int MOAIPurchaseController::_requestSubscription ( lua_State* L ) {
	
	MOAILuaState state ( L );
	const char* com = lua_tostring ( state, 1 );
	MOAIPurchaseController::Get().RequestSubscription(com);
	return 0;
}

int MOAIPurchaseController::_setListener ( lua_State* L ) {
	
	MOAILuaState state ( L );
	
	u32 idx = state.GetValue < u32 >( 1, TOTAL );
	
	if ( idx < TOTAL ) {
		
		MOAIPurchaseController::Get ().mListeners [ idx ].SetStrongRef ( state, 2 );
	}
	
	return 0;
}

//================================================================//
// MOAIPurchaseController
//================================================================//

//----------------------------------------------------------------//
MOAIPurchaseController::MOAIPurchaseController () {

	RTTI_SINGLE ( MOAILuaObject )	
}

//----------------------------------------------------------------//
MOAIPurchaseController::~MOAIPurchaseController () {

}

void MOAIPurchaseController::Init()
{
	_pm = GetPlatformPurchaseManager();
	_pm->SetActivity(_activityName.c_str(), _activityMember.c_str());
	_pm->SetDelegate(this);
	_pm->SetSecret("36011eee133e4c08913252eb3b0aa4d2");
	_pm->Init();
	
}

//----------------------------------------------------------------//
void MOAIPurchaseController::RegisterLuaClass ( MOAILuaState& state ) {

	state.SetField ( -1, "DHX_IAP_RESPONSE", 		( u32 )DHX_IAP_RESPONSE );
	state.SetField ( -1, "DHX_IAP_PURCHASE_STATE_CHANGED",	( u32 )DHX_IAP_PURCHASE_STATE_CHANGED );
	
	luaL_Reg regTable[] = {
		{ "init",			_init },
		{ "requestPurchase",			_requestPurchase },
		{ "setListener",	_setListener },
		{ "restorePurchases",			_restorePurchases },
		{ NULL, NULL }	
	};

	luaL_register ( state, 0, regTable );
}

void MOAIPurchaseController::OnPurchaseStateChanged(const char* itemID, int purchaseState, const char* json)
{
	
	MOAILuaRef& callback = this->mListeners [ DHX_IAP_PURCHASE_STATE_CHANGED ];
		
	if ( callback ) {
		
		MOAILuaStateHandle state = callback.GetSelf ();
		lua_pushstring ( state, itemID );
		lua_pushnumber ( state, purchaseState );
		lua_pushstring ( state, json );
		state.DebugCall ( 3, 0 );
	}
	
}

void MOAIPurchaseController::OnRequestResponse(const char* itemID, int responseID, const char* response)
{
	MOAILuaRef& callback = this->mListeners [ DHX_IAP_RESPONSE ];
		
	if ( callback ) {
		
		MOAILuaStateHandle state = callback.GetSelf ();
		lua_pushstring ( state, itemID );
		lua_pushnumber ( state, responseID );
		lua_pushstring ( state, response );
		state.DebugCall ( 3, 0 );
	}

}

void MOAIPurchaseController::RequestPurchase(const char* item)
{
	_pm->RequestPurchase(item);
}


void MOAIPurchaseController::RestorePurchases()
{
	_pm->RestorePurchases();
}

void MOAIPurchaseController::RequestSubscription(const char* item)
{
	_pm->RequestSubscription(item);

}

void MOAIPurchaseController::SetActivity(const char* activityClassName, const char* staticActivityName)
{
	_activityName = activityClassName;
	_activityMember = staticActivityName;
}

