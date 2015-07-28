
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CZPicker.h>

@interface CantTalkSettingsViewController : UITableViewController<CZPickerViewDataSource, CZPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *playSoundSwitch;

@end
