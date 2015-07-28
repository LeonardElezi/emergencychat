#import "NSUserDefaults+CantTalkSettings.h"

static NSString * const settingInitialMessage = @"settingInitialMessage";
static NSString * const settingInitialTitleMessage = @"settingInitialTitleMessage";
static NSString * const settingFontSize = @"settingFontSize";
static NSString * const settingPlaySound = @"settingPlaySound";
static NSString * const settingAppHasBeenOpened = @"settingAppHasBeenOpened";
static NSString * const settingAutoSwitch = @"settingAutoSwitch";


@implementation NSUserDefaults (CantTalkSettings)

+(void)savePlaySoundSetting:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:settingPlaySound];
}

+(BOOL)playSound
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:settingPlaySound];
}

+(void)saveInitialMessage:(NSString*)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:settingInitialMessage];
}

+(NSString*)initialMessageSetting
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:settingInitialMessage];
}

+(void)saveInitialTitleMessage:(NSString*)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:settingInitialTitleMessage];
}

+(NSString*)initialTitleMessageSetting
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:settingInitialTitleMessage];
}

+(void)saveFontSize:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:settingFontSize];
}

+(NSString*)fontSizeSetting
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:settingFontSize];
}

+(void)saveAppHasBeenOpened:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:settingAppHasBeenOpened];
}

+(BOOL)hasBeenOpened
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:settingAppHasBeenOpened];
}

+(void)saveAutoSwitch:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:settingAutoSwitch];
}

+(BOOL)autoSwitch
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:settingAutoSwitch];
}

@end
