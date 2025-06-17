#import "RNDocumentPicker.h"
#import <React/RCTUtils.h>
#import <Cocoa/Cocoa.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <CoreServices/CoreServices.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <ReactCommon/TurboModuleUtils.h>
#import "RNDocumentPickerSpec.h"
#endif

@implementation RNDocumentPicker

RCT_EXPORT_MODULE();

#pragma mark - React exports

RCT_EXPORT_METHOD(
    pick:(NSDictionary *)options
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSOpenPanel *panel = [NSOpenPanel openPanel];

        BOOL allowDirectories = [options objectForKey:@"allowDirectorySelection"] ? [options[@"allowDirectorySelection"] boolValue] : NO;
        BOOL allowFiles       = [options objectForKey:@"allowFileSelection"] ? [options[@"allowFileSelection"] boolValue] : YES;
        BOOL multiple         = [options objectForKey:@"multiple"] ? [options[@"multiple"] boolValue] : NO;
        NSArray *utis         = [options objectForKey:@"allowedUTIs"];

        panel.canChooseDirectories = allowDirectories;
        panel.canChooseFiles       = allowFiles;
        panel.allowsMultipleSelection = multiple;
        panel.resolvesAliases = YES;

        if (utis != nil && [utis isKindOfClass:[NSArray class]] && utis.count > 0) {
            if (@available(macOS 11.0, *)) {
                NSMutableArray<UTType *> *contentTypes = [NSMutableArray new];
                for (NSString *uti in utis) {
                    UTType *type = [UTType typeWithIdentifier:uti];
                    if (type) {
                        [contentTypes addObject:type];
                    }
                }
                panel.allowedContentTypes = contentTypes;
            } else {
                panel.allowedFileTypes = utis;
            }
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
                if (@available(macOS 11.0, *)) {
                    UTType *uti = [url resourceValuesForKeys:@[NSURLContentTypeKey] error:nil][NSURLContentTypeKey];
                    if (uti) {
                        mimeType = uti.preferredMIMEType;
                    }
                } else {
                    NSString *uti = nil;
                    [url getResourceValue:&uti forKey:NSURLTypeIdentifierKey error:nil];
                    if (uti) {
                        CFStringRef mimeTypeCF = UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)uti, kUTTagClassMIMEType);
                        if (mimeTypeCF) {
                            mimeType = (__bridge_transfer NSString *)mimeTypeCF;
                        }
                    }
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

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeRNDocumentPickerSpec>(params);
}
#endif

@end
