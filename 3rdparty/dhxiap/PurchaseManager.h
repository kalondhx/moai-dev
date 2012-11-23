#ifdef DHX_PLATFORM_ANDROID
#include <jni.h>
#endif
#pragma once

namespace DHX
{
	enum DHX_PM_PLATFORM
	{
		PLATFORM_UNKNOWN,
		PLATFORM_ANDROID,
		PLATFORM_IOS
	};
	class PurchaseManager
	{
	public:
		PurchaseManager();
		virtual ~PurchaseManager();
		// Create DHXIAP class in java evironment
		virtual void Init();
		virtual void Destroy();
		virtual void SetBillingChecked(bool val);
		virtual void CreateDialog(bool val);
		
		virtual void RequestPurchase(const char* val);
		virtual void RequestSubscription(const char* val);
		virtual void OnPurchaseStateChanged(const char* itemID, int purchaseState, const char* json);
		
		// Android only functions
#ifdef DHX_PLATFORM_ANDROID
		virtual void InitAndroid();
		virtual void RequestPurchaseAndroid(jstring& val);
		virtual void RequestSubscriptionAndroid(jstring& val);
		virtual void SetJObjectRef(jobject ref);
		static void SetActivity(jobject ref);
		virtual void SetActivity(const char* className, const char* varName);
#endif
	protected:
		bool _billingEnabled;
		DHX_PM_PLATFORM _platform;
#ifdef DHX_PLATFORM_ANDROID
		jobject _DHXIAP;
#endif
	};
}