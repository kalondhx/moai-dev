

#pragma once
#include "PurchaseManager.h"

namespace DHX
{

	class PurchaseManagerAndroid : public PurchaseManager
	{
		const typedef PurchaseManager super;
	public:
		PurchaseManagerAndroid();
		virtual ~PurchaseManagerAndroid();
		// Create DHXIAP class in java evironment
		virtual void Init();
		virtual void RequestPurchase(const char* val);
		virtual void RequestSubscription(const char* val);
		
		void InitAndroid();
		void RequestPurchaseAndroid(jstring& val);
		void RequestSubscriptionAndroid(jstring& val);
		void SetJObjectRef(jobject ref);
		static void SetActivity(jobject ref);
		void SetActivity(const char* className, const char* varName);
	protected:
		jobject _DHXIAP;
	};
}