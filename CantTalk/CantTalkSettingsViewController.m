#import "CantTalkSettingsViewController.h"
#import "NSUserDefaults+CantTalkSettings.h"
#import "ACEExpandableTextCell.h"

@interface CantTalkSettingsViewController ()<ACEExpandableTableViewDelegate> {
    CGFloat _cellHeight[2];
}

@property (nonatomic, strong) NSMutableArray *cellData;
@property (nonatomic, strong) NSMutableArray *cellTitleData;
@property NSArray *fontSizes;
@property (nonatomic, strong) UIButton *callPickerViewButton;


@end


@implementation CantTalkSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fontSizes = @[@"Default", @"Small", @"Medium", @"Large", @"Huge"];
    
    NSString* initialMessage = [NSUserDefaults initialMessageSetting];
    if(initialMessage==nil){
        initialMessage = @"";
    }
    self.cellData = [NSMutableArray arrayWithArray:@[ initialMessage, @""]];
    
    NSString* initialTitleMessage = [NSUserDefaults initialTitleMessageSetting];
    if(initialTitleMessage==nil){
        initialTitleMessage = @"";
    }
    self.cellTitleData = [NSMutableArray arrayWithArray:@[ initialTitleMessage, @""]];

}


/* comment out this method to allow
 CZPickerView:titleForRow: to work.
 */
- (NSAttributedString *)czpickerView:(CZPickerView *)pickerView
               attributedTitleForRow:(NSInteger)row{
    
    NSAttributedString *att = [[NSAttributedString alloc]
                               initWithString:self.fontSizes[row]
                               attributes:@{
                                            NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:18.0]
                                            }];
    return att;
}

- (NSString *)czpickerView:(CZPickerView *)pickerView
               titleForRow:(NSInteger)row{
    return self.fontSizes[row];
}

- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView{
    return self.fontSizes.count;
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row{
    NSString *f = self.fontSizes[row];
    [NSUserDefaults saveFontSize:f];
    [_callPickerViewButton setTitle:f forState:UIControlStateNormal];
    
}

-(void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemsAtRows:(NSArray *)rows{
//    for(NSNumber *n in rows){
//        NSInteger row = [n integerValue];
//    }
}

- (IBAction)showWithFooter:(id)sender {
    CZPickerView *picker = [[CZPickerView alloc] initWithHeaderTitle:@"Font Sizes" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
    picker.delegate = self;
    picker.dataSource = self;
    picker.needFooterView = NO;
    picker.headerBackgroundColor = [UIColor colorWithRed:69.0f/255.0f green:216.0f/255.0f blue:93.0f/255.0f alpha:1.0];
    [picker show];
}

- (void)czpickerViewDidClickCancelButton:(CZPickerView *)pickerView{
    NSLog(@"Canceled.");
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1) {
        ACEExpandableTextCell *cell = [tableView expandableTextCellWithId:@"messageViewCell"];
        cell.text = [NSUserDefaults initialMessageSetting];
        cell.textView.placeholder = @"Insert initial message here...";
        return cell;
    } else if (indexPath.section == 0){
        ACEExpandableTextCell *cell = [tableView expandableTextCellWithId:@"titleViewCell"];
        cell.text = [NSUserDefaults initialTitleMessageSetting];
        cell.textView.placeholder = @"Insert initial title here...";
        return cell;
        
    } else if(indexPath.section == 2) {
       
        NSString *cellIdentifier = @"fontSizeCell";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell==nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            NSString *fontS = [NSUserDefaults fontSizeSetting];
            if (fontS == nil || fontS.length==0) {
                fontS = self.fontSizes[self.fontSizes.count - 1];
            }
            
            NSString *buttonTitle = [NSString stringWithFormat:@"%@", fontS];
            
            
            _callPickerViewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            _callPickerViewButton.frame = CGRectMake(0.0f, 0.0f, 100.0f, 44.0f);
            [_callPickerViewButton setTitle:buttonTitle forState:UIControlStateNormal];
            cell.accessoryView = _callPickerViewButton;
            
            [_callPickerViewButton addTarget:self action:@selector(showWithFooter:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.textLabel.text = @"Current Size:";
            
                    
        }
        return cell;
        
        
    } else {
        NSString *cellIdentifier = @"autoSwitchCell";
        UITableViewCell* cellSwitch = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cellSwitch==nil){
            cellSwitch = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            BOOL autoSwitch = [NSUserDefaults autoSwitch];
            NSLog(@"switch is: %s", autoSwitch ? "true" : "false");
            
            cellSwitch.textLabel.text = @"One message at a time?";
            cellSwitch.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cellSwitch.accessoryView = switchView;
            [switchView setOn:autoSwitch animated:NO];
            [switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventValueChanged];

            cellSwitch.accessoryView = switchView;
            
            [_callPickerViewButton addTarget:self action:@selector(showWithFooter:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        return cellSwitch;
        
    }
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MAX(50.0, _cellHeight[indexPath.section]);
}

- (void)tableView:(UITableView *)tableView updatedHeight:(CGFloat)height atIndexPath:(NSIndexPath *)indexPath
{
    _cellHeight[indexPath.section] = height;
}

- (void)tableView:(UITableView *)tableView updatedText:(NSString *)text atIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1){
        [_cellData replaceObjectAtIndex:1 withObject:text];
        [NSUserDefaults saveInitialMessage:text];
    } else if(indexPath.section==0){
        [_cellTitleData replaceObjectAtIndex:indexPath.section withObject:text];
        [NSUserDefaults saveInitialTitleMessage:text];
    }
}

- (void)updateSwitch:(id)sender{
    UISwitch* aSwitch = sender;
    [NSUserDefaults saveAutoSwitch:aSwitch.on];
}

@end
