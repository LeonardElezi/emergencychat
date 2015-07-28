//
//  ViewController.h
//  CantTalk
//
//  Created by Leonard Elezi on 6/23/15.
//  Copyright (c) 2015 Leonard Elezi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessagesViewController/JSQMessages.h"
#import "CantTalkModelData.h"

typedef NS_ENUM(NSUInteger, Turns) {
    Left = 1,
    Right = 2
};

@class MessageViewController;

@protocol MessageViewControllerDelegate <NSObject>

- (void)didDismissMessageViewController:(MessageViewController *)vc;

@end


@interface MessageViewController : JSQMessagesViewController <UIActionSheetDelegate>

@property (weak, nonatomic) id<MessageViewControllerDelegate> delegateModal;

@property BOOL switchToReceiver;

@property (strong, nonatomic) CantTalkModelData *demoData;

- (void)closePressed:(UIBarButtonItem *)sender;

@end

