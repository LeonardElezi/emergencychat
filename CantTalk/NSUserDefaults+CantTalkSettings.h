
#import <Foundation/Foundation.h>

@interface NSUserDefaults (CantTalkSettings)

+(void)savePlaySoundSetting:(BOOL)value;
+(BOOL)playSound;

+(void)saveInitialMessage:(NSString*)value;
+(NSString*)initialMessageSetting;

+(void)saveInitialTitleMessage:(NSString*)value;
+(NSString*)initialTitleMessageSetting;

+(void)saveFontSize:(NSString*)value;
+(NSString*)fontSizeSetting;

+(void)saveAppHasBeenOpened:(BOOL)value;
+(BOOL)hasBeenOpened;

+(void)saveAutoSwitch:(BOOL)value;
+(BOOL)autoSwitch;

@end
