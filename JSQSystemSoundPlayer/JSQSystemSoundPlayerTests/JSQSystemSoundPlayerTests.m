//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://www.jessesquires.com/JSQSystemSoundPlayer
//
//
//  GitHub
//  https://github.com/jessesquires/JSQSystemSoundPlayer
//
//
//  License
//  Copyright (c) 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

#import <JSQSystemSoundPlayer/JSQSystemSoundPlayer.h>


static NSString * const kJSQSystemSoundPlayerUserDefaultsKey = @"kJSQSystemSoundPlayerUserDefaultsKey";

static NSString * const kSoundBasso = @"Basso";
static NSString * const kSoundFunk = @"Funk";
static NSString * const kSoundBalladPiano = @"BalladPiano";


// Declare private interface here in order to test private methods
// ***************************************************************
@interface JSQSystemSoundPlayer (UnitTests)

@property (strong, nonatomic) NSMutableDictionary *sounds;
@property (strong, nonatomic) NSMutableDictionary *completionBlocks;

- (NSData *)dataWithSoundID:(SystemSoundID)soundID;

- (SystemSoundID)soundIDFromData:(NSData *)data;

- (SystemSoundID)soundIDForFilename:(NSString *)filenameKey;

- (void)addSoundIDForAudioFileWithName:(NSString *)filename
                             extension:(NSString *)ext;

- (SystemSoundID)createSoundIDWithName:(NSString *)filename
                             extension:(NSString *)ext;

- (JSQSystemSoundPlayerCompletionBlock)completionBlockForSoundID:(SystemSoundID)soundID;

- (void)addCompletionBlock:(JSQSystemSoundPlayerCompletionBlock)block
                 toSoundID:(SystemSoundID)soundID;

- (void)removeCompletionBlockForSoundID:(SystemSoundID)soundID;

@end
// ***************************************************************



@interface JSQSystemSoundPlayerTests : XCTestCase

@property (strong, nonatomic) JSQSystemSoundPlayer *sharedPlayer;

@end



@implementation JSQSystemSoundPlayerTests

- (void)setUp
{
    [super setUp];
    _sharedPlayer = [JSQSystemSoundPlayer sharedPlayer];
    _sharedPlayer.bundle = [NSBundle bundleForClass:[self class]];
}

- (void)tearDown
{
    [_sharedPlayer stopAllSounds];
    _sharedPlayer = nil;
    [super tearDown];
}

- (void)testInitAndSharedInstance
{
    XCTAssertNotNil(self.sharedPlayer, @"Player should not be nil");

    JSQSystemSoundPlayer *anotherPlayer = [JSQSystemSoundPlayer sharedPlayer];
    XCTAssertEqualObjects(self.sharedPlayer, anotherPlayer, @"Players returned from shared instance should be equal");

    XCTAssertNotNil(self.sharedPlayer.sounds, @"Sounds dictionary should be initialized");
    XCTAssertTrue([self.sharedPlayer.sounds count] == 0, @"Sounds dictionary count should be 0");

    XCTAssertNotNil(self.sharedPlayer.completionBlocks, @"Completion blocks dictionary should be initialized");
    XCTAssertTrue([self.sharedPlayer.completionBlocks count] == 0, @"Completion blocks dictionary count should be 0");
}

- (void)testAddingSounds
{
    [self.sharedPlayer addSoundIDForAudioFileWithName:kSoundBasso extension:kJSQSystemSoundTypeAIF];
    XCTAssertTrue([self.sharedPlayer.sounds count] == 1, @"Player should contain 1 cached sound");

    SystemSoundID retrievedSoundID = [self.sharedPlayer soundIDForFilename:kSoundBasso];
    NSData *soundData = [self.sharedPlayer dataWithSoundID:retrievedSoundID];
    XCTAssertEqualObjects([self.sharedPlayer.sounds objectForKey:kSoundBasso], soundData, @"Sound data should be equal");

    [self.sharedPlayer addSoundIDForAudioFileWithName:kSoundBasso extension:kJSQSystemSoundTypeAIF];
    XCTAssertTrue([self.sharedPlayer.sounds count] == 1, @"Player should still contain 1 only cached sound");
}

- (void)testCompletionBlocks
{
    SystemSoundID soundID = [self.sharedPlayer createSoundIDWithName:kSoundBasso extension:kJSQSystemSoundTypeAIF];
    NSData *data = [self.sharedPlayer dataWithSoundID:soundID];

    JSQSystemSoundPlayerCompletionBlock block = ^{
        NSLog(@"Completion block");
    };

    [self.sharedPlayer addCompletionBlock:block toSoundID:soundID];
    XCTAssertTrue([self.sharedPlayer.completionBlocks count] == 1, @"Player should contain 1 cached completion blocks");
    XCTAssertEqualObjects(block, [self.sharedPlayer.completionBlocks objectForKey:data], @"Blocks should be equal");
    XCTAssertEqualObjects(block, [self.sharedPlayer completionBlockForSoundID:soundID], @"Blocks should be equal");

    [self.sharedPlayer removeCompletionBlockForSoundID:soundID];
    XCTAssertTrue([self.sharedPlayer.completionBlocks count] == 0, @"Player should contain 0 cached completion blocks");
    XCTAssertNil([self.sharedPlayer.completionBlocks objectForKey:data], @"Blocks should be nil");
    XCTAssertNil([self.sharedPlayer completionBlockForSoundID:soundID], @"Blocks should be nil");
}

- (void)testCreatingAndRetrievingSounds
{
    SystemSoundID soundID = [self.sharedPlayer createSoundIDWithName:kSoundBasso extension:kJSQSystemSoundTypeAIF];
    XCTAssert(soundID, @"SoundID should not be nil");

    [self.sharedPlayer addSoundIDForAudioFileWithName:kSoundBasso extension:kJSQSystemSoundTypeAIF];
    SystemSoundID retrievedSoundID = [self.sharedPlayer soundIDForFilename:kSoundBasso];
    XCTAssert(retrievedSoundID, @"SoundID should not be nil");

    NSData *soundData = [self.sharedPlayer dataWithSoundID:retrievedSoundID];
    XCTAssertNotNil(soundData, @"Sound data should not be nil");

    SystemSoundID soundIDFromData = [self.sharedPlayer soundIDFromData:soundData];
    XCTAssert(soundIDFromData, @"SoundID should not be nil");
    XCTAssertEqual(soundIDFromData, retrievedSoundID, @"SoundIDs should be equal");

    SystemSoundID nilSound = [self.sharedPlayer createSoundIDWithName:@"" extension:@""];
    XCTAssert(!nilSound, @"SoundID should be nil");

    SystemSoundID retrievedNilSoundID = [self.sharedPlayer soundIDForFilename:@""];
    XCTAssert(!retrievedNilSoundID, @"SoundID should be nil");
}

- (void)testPlayingSounds
{
    XCTAssertNoThrow([self.sharedPlayer playSoundWithFilename:kSoundBasso
                                                fileExtension:kJSQSystemSoundTypeAIF
                                                   completion:^{
                                                       NSLog(@"Completion block...");
                                                   }],
                     @"Player should play sound and not throw");

    XCTAssertNoThrow([self.sharedPlayer playSoundWithFilename:kSoundFunk
                                                fileExtension:kJSQSystemSoundTypeAIFF
                                                   completion:nil],
                     @"Player should play sound and not throw");

    XCTAssertNoThrow([self.sharedPlayer playAlertSoundWithFilename:kSoundBasso
                                                     fileExtension:kJSQSystemSoundTypeAIF
                                                        completion:nil],
                     @"Player should play alert and not throw");

    XCTAssertNoThrow([self.sharedPlayer playAlertSoundWithFilename:kSoundFunk
                                                     fileExtension:kJSQSystemSoundTypeAIFF
                                                        completion:nil],
                     @"Player should play alert and not throw with nil block");

    XCTAssertThrows([self.sharedPlayer playAlertSoundWithFilename:nil
                                                    fileExtension:nil
                                                       completion:nil],
                    @"Player should throw on nil params");

    XCTAssertNoThrow([self.sharedPlayer playAlertSoundWithFilename:kSoundBalladPiano
                                                     fileExtension:kJSQSystemSoundTypeAIFF
                                                        completion:nil],
                     @"Player should fail gracefully and not throw on incorrect extension");

    XCTAssertNoThrow([self.sharedPlayer playVibrateSound], @"Player should vibrate and not throw");
}

- (void)testStoppingSounds
{
    [self.sharedPlayer playSoundWithFilename:kSoundBasso fileExtension:kJSQSystemSoundTypeAIF completion:nil];
    [self.sharedPlayer playSoundWithFilename:kSoundBalladPiano fileExtension:kJSQSystemSoundTypeCAF completion:nil];

    XCTAssertTrue([self.sharedPlayer.sounds count] == 2, @"Player should have 2 sounds cached");

    [self.sharedPlayer stopSoundWithFilename:kSoundBalladPiano];
    XCTAssertTrue([self.sharedPlayer.sounds count] == 1, @"Player should have 1 sound cached");
}

- (void)testSoundCompletionBlocks
{
    XCTAssertNoThrow([self.sharedPlayer playSoundWithFilename:kSoundBasso
                                                fileExtension:kJSQSystemSoundTypeAIF
                                                   completion:^{
                                                       NSLog(@"Exectuing block...");
                                                   }],
                     @"Player should play and now throw");

    XCTAssertTrue([self.sharedPlayer.completionBlocks count] == 1, @"Completion blocks dictionary should contain 1 object");
}

- (void)testMemoryWarning
{
    [self.sharedPlayer playSoundWithFilename:kSoundBasso
                               fileExtension:kJSQSystemSoundTypeAIF
                                  completion:^{
                                      NSLog(@"Completion block...");
                                  }];

    XCTAssertTrue([self.sharedPlayer.completionBlocks count] == 1, @"Completion blocks dictionary should contain 1 object");

    [self.sharedPlayer playAlertSoundWithFilename:kSoundFunk
                                    fileExtension:kJSQSystemSoundTypeAIFF
                                       completion:nil];

    XCTAssertTrue([self.sharedPlayer.sounds count] == 2, @"Sounds dictionary should contain 2 objects");

    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification
                                                        object:nil];

    XCTAssertTrue([self.sharedPlayer.sounds count] == 0, @"Sounds should have been purged on memory warning");
    XCTAssertTrue([self.sharedPlayer.completionBlocks count] == 0, @"Completion blocks should have been purged on memory warning");
}

- (void)testUserDefaultsSettings
{
    BOOL soundPlayerOn = self.sharedPlayer.on;
    BOOL soundSetting = [[[NSUserDefaults standardUserDefaults] objectForKey:kJSQSystemSoundPlayerUserDefaultsKey] boolValue];
    XCTAssertEqual(soundPlayerOn, soundSetting, @"Sound setting values should be equal");

    [self.sharedPlayer toggleSoundPlayerOn:NO];
    soundPlayerOn = self.sharedPlayer.on;
    soundSetting = [[[NSUserDefaults standardUserDefaults] objectForKey:kJSQSystemSoundPlayerUserDefaultsKey] boolValue];
    XCTAssertEqual(soundPlayerOn, soundSetting, @"Sound setting values should be equal");

    [self.sharedPlayer toggleSoundPlayerOn:YES];
    soundPlayerOn = self.sharedPlayer.on;
    soundSetting = [[[NSUserDefaults standardUserDefaults] objectForKey:kJSQSystemSoundPlayerUserDefaultsKey] boolValue];
    XCTAssertEqual(soundPlayerOn, soundSetting, @"Sound setting values should be equal");
}

- (void)testPreloadSounds
{
    XCTAssertTrue([self.sharedPlayer.sounds count] == 0, @"Player should begin with no sounds");

    [self.sharedPlayer preloadSoundWithFilename:kSoundBasso fileExtension:kJSQSystemSoundTypeAIF];

    XCTAssertTrue([self.sharedPlayer.sounds count] == 1, @"Player should have 1 sound after preloading");
    XCTAssert([self.sharedPlayer soundIDForFilename:kSoundBasso], @"Player soundID for file should not be 0");
}

@end
