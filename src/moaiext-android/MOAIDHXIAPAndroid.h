#pragma once
#define DHX_PLATFORM_ANDROID
#include <PurchaseManager.h>
#include <moaicore/moaicore.h>
class MOAIDHXIAPAndroid : public MOAIGlobalClass < MOAIDHXIAPAndroid, MOAILuaObject >, public DHX::PurchaseManager 
{ 
	private:
	//----------------------------------------------------------------//
	static int	_init			( lua_State* L );
	static int	_requestPurchase			( lua_State* L );
	static int	_requestSubscription			( lua_State* L );
	static int	_setListener	( lua_State* L );
public:

	enum {
		DHX_IAP_RESPONSE,
		DHX_IAP_PURCHASE_STATE_CHANGED,
		TOTAL,
	};
	MOAILuaRef		mListeners [ TOTAL ];
	DECL_LUA_SINGLETON ( MOAIDHXIAPAndroid );
	
			MOAIDHXIAPAndroid		();
			~MOAIDHXIAPAndroid		();
	void	RegisterLuaClass			( MOAILuaState& state );	
	virtual void OnPurchaseStateChanged(const char* itemID, int purchaseState, const char* json);	
};