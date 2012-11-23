//
//  PurchaseManageriOS.h
//  DHXStore
//
//  Created by Kalon Winnik on 2012-11-21.
//  Copyright (c) 2012 DHX Media. All rights reserved.
//

#include "PurchaseManager.h"
namespace DHX
{
    class PurchaseManageriOS : public PurchaseManager
    {
    public:
        PurchaseManageriOS();
        ~PurchaseManageriOS();
        
		virtual void Init();
		virtual void Destroy();
		virtual void SetBillingChecked(bool val);
		virtual void CreateDialog(bool val);
		
		virtual void RequestPurchase(const char* val);
		virtual void RequestSubscription(const char* val);
        void SetSecret(char* secret);
    };

}