/*
 ViewController в котором производится настройка параметров приложения
 */

#import "TSSettingsViewController.h"
#import "TSWeatherDatabase.h"

NSInteger const PICKER_VIEW_MAX_VALUE = 100;
NSInteger const PICKER_VIEW_STEP = 5;

@interface TSSettingsViewController ()
@property (nonatomic, weak) IBOutlet UISegmentedControl *chengDatabaseControl;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@end

@implementation TSSettingsViewController

#pragma mark - Initialization of settings
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.pickerView reloadAllComponents];
    TSWeatherDatabase *weatherDatabase = [TSWeatherDatabase sharedDatabase];
    NSInteger pickerViewRow = [self picerViewNumberRows: [weatherDatabase maxRecordsValueInDatabase]];
    [self.pickerView selectRow:pickerViewRow inComponent:0 animated:NO];
    DatabaseType databaseType = [weatherDatabase databaseType];
    if (databaseType == CoreDataDatabaseType) {
        self.chengDatabaseControl.selectedSegmentIndex = 0;
    } else if (databaseType == SQLiteDatabaseType) {
        self.chengDatabaseControl.selectedSegmentIndex = 1;
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return (PICKER_VIEW_MAX_VALUE / PICKER_VIEW_STEP);
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
          forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld",[self picerViewRowValue:row]];
}

//вычисляем значение строке PicerView
-(NSInteger)picerViewRowValue:(NSInteger)row {
    return ((row + 1) * PICKER_VIEW_STEP);
}

//вычисляем количество строк Picker View
-(NSInteger)picerViewNumberRows:(NSInteger)recordsCount {
    return (recordsCount - 1) / PICKER_VIEW_STEP;
}

#pragma mark - Changing the type of data store
-(IBAction)databaseChange {
    TSWeatherDatabase *weatherDatabase = [TSWeatherDatabase sharedDatabase];
    if (self.chengDatabaseControl.selectedSegmentIndex == 0) {
        [weatherDatabase migrateToDatabase:CoreDataDatabaseType];
    } else if (self.chengDatabaseControl.selectedSegmentIndex == 1) {
        [weatherDatabase migrateToDatabase:SQLiteDatabaseType];
    }
}

#pragma mark - Changing the maximum number of records storage
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger maxNumberDatabaseRecords = [self picerViewRowValue:row];
    if (maxNumberDatabaseRecords > 0) {
        [[TSWeatherDatabase sharedDatabase] setMaxRecordsValueInDatabase:maxNumberDatabaseRecords];
    }
}

#pragma mark - Alert view
-(void)showAlertViewWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:error.domain message:error.description delegate:nil
            cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

@end
