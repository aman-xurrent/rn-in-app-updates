#import "RnInAppUpdates.h"
#import <UIKit/UIKit.h>

@implementation RnInAppUpdates
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(checkForUpdate:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];

  if (!bundleId) {
    reject(@"BUNDLE_ID_ERROR", @"Could not get bundle identifier", nil);
    return;
  }

  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/lookup?bundleId=%@", bundleId]];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];

  NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      reject(@"NETWORK_ERROR", @"Failed to check for updates", error);
      return;
    }

    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

    if (jsonError) {
      reject(@"JSON_ERROR", @"Failed to parse response", jsonError);
      return;
    }

    NSArray *results = json[@"results"];
    if (results && [results count] > 0) {
      NSDictionary *appInfo = results[0];
      NSString *appStoreVersion = appInfo[@"version"];
      NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
      NSString *trackId = [appInfo[@"trackId"] stringValue];
      NSString *appStoreUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", trackId];

      BOOL isUpdateAvailable = ![appStoreVersion isEqualToString:currentVersion];

      NSDictionary *result = @{
        @"isUpdateAvailable": @(isUpdateAvailable),
        @"updateUrl": appStoreUrl
      };

      resolve(result);
    } else {
      reject(@"APP_NOT_FOUND", @"App not found in App Store", nil);
    }
  }];

  [task resume];
}

RCT_EXPORT_METHOD(updateApp:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];

  if (!bundleId) {
    reject(@"BUNDLE_ID_ERROR", @"Could not get bundle identifier", nil);
    return;
  }

  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/lookup?bundleId=%@", bundleId]];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];

  NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      reject(@"NETWORK_ERROR", @"Failed to get app info", error);
      return;
    }

    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

    if (jsonError) {
      reject(@"JSON_ERROR", @"Failed to parse response", jsonError);
      return;
    }

    NSArray *results = json[@"results"];
    if (results && [results count] > 0) {
      NSDictionary *appInfo = results[0];
      NSString *trackId = [appInfo[@"trackId"] stringValue];

      dispatch_async(dispatch_get_main_queue(), ^{
        if (![SKStoreProductViewController class]) {
          // Fallback
          NSString *appStoreUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", trackId];
          NSURL *storeURL = [NSURL URLWithString:appStoreUrl];
          [[UIApplication sharedApplication] openURL:storeURL options:@{} completionHandler:^(BOOL success) {
            if (success) {
              resolve(nil);
            } else {
              reject(@"OPEN_URL_ERROR", @"Failed to open App Store", nil);
            }
          }];
          return;
        }

        SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
        storeViewController.delegate = self;

        NSDictionary *parameters = @{
          SKStoreProductParameterITunesItemIdentifier: trackId
        };

        [storeViewController loadProductWithParameters:parameters completionBlock:^(BOOL result, NSError *error) {
          if (result) {
            UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            while (rootViewController.presentedViewController) {
              rootViewController = rootViewController.presentedViewController;
            }
            [rootViewController presentViewController:storeViewController animated:YES completion:^{
              resolve(nil);
            }];
          } else {
            reject(@"STORE_VIEW_ERROR", @"Failed to load App Store view", error);
          }
        }];
      });
    } else {
      reject(@"APP_NOT_FOUND", @"App not found in App Store", nil);
    }
  }];

  [task resume];
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
  [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
