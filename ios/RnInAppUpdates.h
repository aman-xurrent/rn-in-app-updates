
#import <StoreKit/StoreKit.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNRnInAppUpdatesSpec.h"

@interface RnInAppUpdates : NSObject <NativeRnInAppUpdatesSpec, SKStoreProductViewControllerDelegate>
#else
#import <React/RCTBridgeModule.h>

@interface RnInAppUpdates : NSObject <RCTBridgeModule, SKStoreProductViewControllerDelegate>
#endif

@end
