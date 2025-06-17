#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTTurboModule.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface RNDocumentPicker : NSObject <RCTBridgeModule
#ifdef RCT_NEW_ARCH_ENABLED
, RCTTurboModule
#endif
>
@end

NS_ASSUME_NONNULL_END
