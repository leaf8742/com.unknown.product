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
        localization = kChineseSimplifiedLanguage;
        if (!localization || [localization isEqualToString:@"default"]) {
            NSArray* languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
            NSString *defaultLanguage = [languages objectAtIndex:0];
            NSString *path = [[NSBundle mainBundle] pathForResource:defaultLanguage ofType:@"lproj"];
            self.bundle = [NSBundle bundleWithPath:path];
        } else {
            NSString *path = [[NSBundle mainBundle] pathForResource:localization ofType:@"lproj"];
            self.bundle = [NSBundle bundleWithPath:path];
        }
    }
    return self;
}

- (NSBundle *)bundle {
    NSString *language = [[NSUserDefaults standardUserDefaults] valueForKey:@"localizationLanguage"];
    language = kChineseSimplifiedLanguage;
    if (!language) {
        language = kDefaultLanguage;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
    self.bundle = [NSBundle bundleWithPath:path];
    return _bundle;
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
    NSString *result = [bundle localizedStringForKey:key value:nil table:@"Localizable"];
    if (result == nil)
        result = NSLocalizedString(key, comment);
    return result;
}

+ (NSString *)language {
    NSString *language = [[NSUserDefaults standardUserDefaults] valueForKey:@"localizationLanguage"];
    return [self sysLanguageFrom:language];
}

+ (NSString *)sysLanguageFrom:(NSString *)appLanguage {
    NSString *language = appLanguage;
    
    if ([language isEqualToString:kDefaultLanguage]) {
        NSArray *languages = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
        language = languages.firstObject;
    }
    
    return language;
}

+ (void)setLanguage:(NSString *)language {
    if ([language isEqualToString:kDefaultLanguage]) {
        NSArray* languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        NSString *defaultLanguage = [languages objectAtIndex:0];
        NSString *path = [[NSBundle mainBundle] pathForResource:defaultLanguage ofType:@"lproj"];
        [[LocalizationManager sharedInstance] setBundle:[NSBundle bundleWithPath:path]];
    } else {
        NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
        [[LocalizationManager sharedInstance] setBundle:[NSBundle bundleWithPath:path]];
    }
    [[NSUserDefaults standardUserDefaults] setValue:language forKey:@"localizationLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
