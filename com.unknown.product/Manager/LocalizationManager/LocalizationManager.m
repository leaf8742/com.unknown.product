#import "LocalizationManager.h"

NSString *const kDefaultLanguage = @"default";
NSString *const kChineseSimplifiedLanguage = @"zh-Hans";
NSString *const kEnglishLanguage = @"en";

@interface LocalizationManager()

@property (retain, nonatomic) NSBundle *bundle;

@end


@implementation LocalizationManager

- (id)init {
    self = [super init];
    if (self) {
        NSString *localization = [[NSUserDefaults standardUserDefaults] valueForKey:@"localizationLanguage"];
        if (!localization || [localization isEqualToString:@"default"]) {
            NSArray* languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
            NSString *defaultLanguage = [languages objectAtIndex:0];
            if ([defaultLanguage isEqualToString:@"zh_cn"]) {
                defaultLanguage = kChineseSimplifiedLanguage;
            }
            NSString *path = [[NSBundle mainBundle] pathForResource:defaultLanguage ofType:@"lproj"];
            self.bundle = [NSBundle bundleWithPath:path];
        } else {
            NSString *path = [[NSBundle mainBundle] pathForResource:localization ofType:@"lproj"];
            self.bundle = [NSBundle bundleWithPath:path];
        }
    }
    return self;
}

+ (LocalizationManager *)sharedInstance {
    static LocalizationManager *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [NSAllocateObject([self class], 0, NULL) init];
    });
    return sharedClient;
}

+ (NSString *)localizedStringForKey:(NSString *)key comment:(NSString *)comment {
    NSBundle *bundle = [[LocalizationManager sharedInstance] bundle];
    NSString *result = [bundle localizedStringForKey:key value:nil table:@"Localization"];
    if (result == nil)
        result = NSLocalizedString(key, comment);
    return result;
}

+ (NSString *)language {
    NSString *localization = [[NSUserDefaults standardUserDefaults] valueForKey:@"localizationLanguage"];
    if (!localization) {
        return @"default";
    } else {
        return localization;
    }
}

+ (void)setLanguage:(NSString *)language {
    if ([language isEqualToString:kDefaultLanguage]) {
        [[NSUserDefaults standardUserDefaults] setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"NSLanguages"] forKey:@"AppleLanguages"];
    } else {
        NSMutableArray *array = [NSMutableArray arrayWithObjects:language, nil];
        for (NSString *languageItem in [[NSUserDefaults standardUserDefaults] objectForKey:@"NSLanguages"]) {
            if (![languageItem isEqualToString:language]) {
                [array addObject:languageItem];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:array forKey:@"AppleLanguages"];
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:language forKey:@"localizationLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
