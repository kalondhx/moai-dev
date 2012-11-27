//
//  MOAIPurchaseManageriOS.m
//  libmoai
//
//  Created by Kalon Winnik on 2012-11-22.
//
//

#include "pch.h"

#include <PurchaseManageriOS.h>

DHX::PurchaseManager* GetPlatformPurchaseManager()
{
	return new DHX::PurchaseManageriOS();
}
