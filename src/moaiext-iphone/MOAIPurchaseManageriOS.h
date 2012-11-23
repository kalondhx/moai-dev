//
//  MOAIPurchaseManageriOS.h
//  libmoai
//
//  Created by Kalon Winnik on 2012-11-22.
//
//
#pragma once
#include <PurchaseManageriOS.h>
#import <moaicore/moaicore.h>

class MOAIPurchaseManageriOS : public MOAIGlobalClass < MOAIPurchaseManageriOS, MOAILuaObject >, public DHX::PurchaseManageriOS
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
	DECL_LUA_SINGLETON ( MOAIPurchaseManageriOS );
	
	MOAIPurchaseManageriOS		();
	~MOAIPurchaseManageriOS		();
	void	RegisterLuaClass			( MOAILuaState& state );
	virtual void OnPurchaseStateChanged(const char* itemID, int purchaseState, const char* json);

};
