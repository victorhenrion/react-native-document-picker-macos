#import "RNDocumentPicker.h"

#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@implementation RNDocumentPicker

RCT_EXPORT_MODULE();

#ifdef RCT_NEW_ARCH_ENABLED

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeRNDocumentPickerSpecJSI>(params);
}

- (void)pick:(JS::NativeRNDocumentPicker::SpecPickOptions &)options
         resolve:(RCTPromiseResolveBlock)resolve
         reject:(RCTPromiseRejectBlock)reject
{
    BOOL allowDirectorySelection     = options.allowDirectorySelection().value_or(NO);
    BOOL allowFileSelection          = options.allowFileSelection().value_or(NO);
    BOOL multiple                    = options.multiple().value_or(NO);
    NSArray<NSString *> *allowedUTIs = nil;

    if (auto utisOpt = options.allowedUTIs(); utisOpt) {
        const auto &vec = *utisOpt;
        NSMutableArray<NSString *> *tmp = [NSMutableArray arrayWithCapacity:vec.size()];
        for (NSString *uti : vec) [tmp addObject:uti];
        allowedUTIs = tmp;
    }

    [self pickImpl:allowDirectorySelection
        allowFileSelection:allowFileSelection
        multiple:multiple
        allowedUTIs:allowedUTIs
        resolve:resolve
        reject:reject];
}

#else

RCT_EXPORT_METHOD(pick:(NSDictionary<NSString *, id> * _Nonnull)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    BOOL allowDirectorySelection     = [options[@"allowDirectorySelection"] boolValue];
    BOOL allowFileSelection          = [options[@"allowFileSelection"] boolValue];
    BOOL multiple                    = [options[@"multiple"] boolValue];
    NSArray<NSString *> *allowedUTIs = nil;

    if ([options[@"allowedUTIs"] isKindOfClass:[NSArray class]]) {
        allowedUTIs = (NSArray<NSString *> *)options[@"allowedUTIs"];
    }

    [self pickImpl:allowDirectorySelection
        allowFileSelection:allowFileSelection
        multiple:multiple
        allowedUTIs:allowedUTIs
        resolve:resolve
        reject:reject];
}

#endif

- (void)pickImpl:(BOOL)allowDirectorySelection
        allowFileSelection:(BOOL)allowFileSelection
        multiple:(BOOL)multiple
        allowedUTIs:(NSArray<NSString *> *)allowedUTIs
        resolve:(RCTPromiseResolveBlock)resolve
        reject:(RCTPromiseRejectBlock)reject
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSOpenPanel *panel = [NSOpenPanel openPanel];

        panel.canChooseDirectories    = allowDirectorySelection;
        panel.canChooseFiles          = allowFileSelection;
        panel.allowsMultipleSelection = multiple;
        panel.resolvesAliases         = YES;

        if (allowedUTIs != nil && [allowedUTIs isKindOfClass:[NSArray class]] && allowedUTIs.count > 0) {
            NSMutableArray<UTType *> *contentTypes = [NSMutableArray new];
            for (NSString *uti in allowedUTIs) {
                UTType *type = [UTType typeWithIdentifier:uti];
                if (type) {
                    [contentTypes addObject:type];
                }
            }
            panel.allowedContentTypes = contentTypes;
        }

        NSInteger result = [panel runModal];
        if (result == NSModalResponseOK) {
            NSMutableArray *responseArray = [NSMutableArray new];
            NSFileManager *fileManager = [NSFileManager defaultManager];

            for (NSURL *url in panel.URLs) {
                NSString *path = url.path;
                NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:nil];
                NSNumber *size = attributes[NSFileSize];
                NSString *mimeType = nil;
                UTType *uti = [url resourceValuesForKeys:@[NSURLContentTypeKey] error:nil][NSURLContentTypeKey];
                if (uti) {
                    mimeType = uti.preferredMIMEType;
                }
                NSString *name = url.lastPathComponent;

                NSMutableDictionary *dict = [@{
                    @"uri": url.absoluteString ?: @"",
                    @"path": path ?: @"",
                    @"name": name ?: @"",
                } mutableCopy];

                dict[@"size"] = size ?: [NSNull null];

                // Determine if the item is a directory – only attach mimeType for files.
                NSNumber *isDirectory = nil;
                [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
                if (isDirectory == nil || !isDirectory.boolValue) {
                    dict[@"mimeType"] = mimeType ?: [NSNull null];
                }

                [responseArray addObject:dict];
            }
            resolve(responseArray);
        } else {
            NSError *error = [NSError errorWithDomain:@"USER_CANCELLED" code:-1 userInfo:nil];
            reject(@"USER_CANCELLED", @"User cancelled document picker", error);
        }
    });
}

@end
