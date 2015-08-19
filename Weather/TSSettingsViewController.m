/*
 ViewController в котором производится настройка параметров приложения
 */

#import "TSSettingsViewController.h"
#import "TSSettings.h"
#import "TSWeatherDatabase.h"

NSInteger const PICKER_VIEW_MAX_VALUE = 100;
NSInteger const PICKER_VIEW_STEP = 5;

@implementation TSSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    //загружаем настройки приложения
    [self.pickerView reloadAllComponents];
    NSInteger pickerViewRow = [self picerViewNumberRows:[TSSettings sharedSettings].databaseCount];
    [self.pickerView selectRow:pickerViewRow inComponent:0 animated:NO];
    
    //устанавливаем переключатель типа базы данных соответственно настройкам
    DatabaseType databaseType = [[TSSettings sharedSettings]databaseType];
    if (databaseType == CoreDataDatabaseType){
        
        chengDatabaseControl.selectedSegmentIndex = 0;
    }
    else if(databaseType == SQLiteDatabaseType){
        
        chengDatabaseControl.selectedSegmentIndex = 1;
    }
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

//изменить базу данных
-(IBAction)databaseChange{
    
    if(chengDatabaseControl.selectedSegmentIndex == 0){
        
        [TSSettings sharedSettings].databaseType = CoreDataDatabaseType;
        [[TSSettings sharedSettings] saveSettings];
        TSWeatherDatabase *database = [[TSWeatherDatabase alloc] initWithSettings:[TSSettings sharedSettings]];
        [database sqlToCoreData];
    }
    else if(chengDatabaseControl.selectedSegmentIndex == 1){
        
        [TSSettings sharedSettings].databaseType = SQLiteDatabaseType;
        [[TSSettings sharedSettings] saveSettings];
        TSWeatherDatabase *database = [[TSWeatherDatabase alloc] initWithSettings:[TSSettings sharedSettings]];
        [database coreDataToSql];
    }
}

#pragma mark - Picker View delegate

//указываем число столбцов Picker View
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

//указываем количество строк Picker View
 -(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return (PICKER_VIEW_MAX_VALUE / PICKER_VIEW_STEP);
}

//выводим значения в строки Picker View (количество записей в бд)
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return [NSString stringWithFormat:@"%ld",[self picerViewRowValue:row]];
}

//изменяем количество записей в базе данных
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSInteger maxNumberDatabaseRecords = [self picerViewRowValue:row];
    
    if (maxNumberDatabaseRecords > 0){
        
        [TSSettings sharedSettings].databaseCount = maxNumberDatabaseRecords;
        [[TSSettings sharedSettings] saveSettings];
        
        TSWeatherDatabase *database = [[TSWeatherDatabase alloc] initWithSettings:[TSSettings sharedSettings]];
        [database removeSurplusRecords];
    }
}

//вычисляем значение конкретной строке PicerView
-(NSInteger)picerViewRowValue:(NSInteger)row{
    
    return ((row + 1) * PICKER_VIEW_STEP);
}

//вычисляем количество строк Picker View
-(NSInteger)picerViewNumberRows:(NSInteger)recordsCount{
    
    return (recordsCount - 1) / PICKER_VIEW_STEP;
}

#pragma mark - Alert view

//метод выводит сообщение с указанной ошибкой
-(void)showAlertViewWithError:(NSError *)error{
    
    [[[UIAlertView alloc] initWithTitle:error.domain
                                message:error.description
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}


@end
