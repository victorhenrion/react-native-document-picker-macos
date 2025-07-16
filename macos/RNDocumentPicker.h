#ifdef RCT_NEW_ARCH_ENABLED

#import <RNDocumentPickerSpec/RNDocumentPickerSpec.h>

@interface RNDocumentPicker : NSObject <NativeRNDocumentPickerSpec>
@end

#else

#import <React/RCTBridgeModule.h>

@interface RNDocumentPicker : NSObject <RCTBridgeModule>
@end

#endif
