#define DHX_PLATFORM_ANDROID
#include <PurchaseManagerAndroid.h>


DHX::PurchaseManager* GetPlatformPurchaseManager()
{
	return new DHX::PurchaseManagerAndroid();
}