#ifdef RCT_NEW_ARCH_ENABLED

#import <React/RCTBridgeModule.h>
#import <React/RCTDefines.h>
#import <React/RCTTurboModule.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RNDocumentPickerSpec <RCTBridgeModule, RCTTurboModule>
- (void)pick:(NSDictionary *)options
     resolve:(RCTPromiseResolveBlock)resolve
     reject:(RCTPromiseRejectBlock)reject;
@end

typedef NSObject<RNDocumentPickerSpec> *NativeRNDocumentPickerSpec;

NS_ASSUME_NONNULL_END

#endif
