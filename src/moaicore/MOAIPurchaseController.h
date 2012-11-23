#pragma once

#include <PurchaseManager.h>
#include <moaicore/moaicore.h>

extern DHX::PurchaseManager* GetPlatformPurchaseManager();

class MOAIPurchaseController : public MOAIGlobalClass < MOAIPurchaseController, MOAILuaObject >, public DHX::PurchaseManager, public DHX::OnPurchaseManagerEvent 
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
		DECL_LUA_SINGLETON ( MOAIPurchaseController );
		
		MOAIPurchaseController		();
		~MOAIPurchaseController		();
		void	RegisterLuaClass			( MOAILuaState& state );	
		virtual void OnPurchaseStateChanged(const char* itemID, int purchaseState, const char* json);
		virtual void OnRequestResponse(const char* itemID, int responseID, const char* response);
		
		void Init();
		void RequestPurchase(const char* item);
		void RequestSubscription(const char* item);
		void SetActivity(const char* activityClassName, const char* staticActivityName);
		
	protected:
		DHX::PurchaseManager* _pm;
		string _activityName;
		string _activityMember;
};