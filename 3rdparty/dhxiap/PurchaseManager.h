
#pragma once

#ifdef DHX_PLATFORM_ANDROID
#include <jni.h>
#include <android/log.h>
#ifndef JNI_GET_ENV
	#define JNI_GET_ENV(jvm, env) 	\
		JNIEnv* env; 				\
		jvm->GetEnv (( void** )&env, JNI_VERSION_1_4 );
#endif
#define dhxlog(x, y, z) __android_log_write(x, y, z)
#else
//#define ANDROID_LOG_INFO 0
#define dhxlog(x, y, z) printf("%s, %s", y, z);
#endif

namespace DHX
{
	enum DHX_PM_PLATFORM
	{
		PLATFORM_UNKNOWN,
		PLATFORM_ANDROID,
		PLATFORM_IOS
	};
	
	class OnPurchaseManagerEvent
	{
		public:
			virtual void OnPurchaseStateChanged(const char* itemID, int purchaseState, const char* json) = 0;
			virtual void OnRequestResponse(const char* itemID, int responseID, const char* response) = 0;
	};
	
	class PurchaseManager
	{
	public:
		PurchaseManager();
		virtual ~PurchaseManager();
		virtual void Init();
		virtual void Destroy();
		virtual void SetBillingChecked(bool val);
		virtual void CreateDialog(bool val);
		void SetDelegate(OnPurchaseManagerEvent* delegate){_delegate = delegate;};
		
		virtual void RequestPurchase(const char* val);
		virtual void RequestSubscription(const char* val);
		virtual void OnPurchaseStateChanged(const char* itemID, int purchaseState, const char* json);
		virtual void OnRequestResponse(const char* itemID, int responseID, const char* response);
		virtual void RestorePurchases();
		virtual void SetActivity(const char* className, const char* varName){};
	protected:
		bool _billingEnabled;
		DHX_PM_PLATFORM _platform;
		OnPurchaseManagerEvent* _delegate;
	};
}