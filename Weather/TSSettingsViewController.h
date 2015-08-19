/*
 ViewController в котором производится настройка параметров приложения
 */

#import <UIKit/UIKit.h>


@interface TSSettingsViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>{
    IBOutlet UISegmentedControl *chengDatabaseControl;
}

@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;

@end
