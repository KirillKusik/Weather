//
//  TSSecondViewController.m
//  Weather
//
//  Created by Admin on 13.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import "TSSecondViewController.h"
#import "TSSettings.h"
#import "TSDatabase.h"

@implementation TSSecondViewController


//увиличивает допустимое количество записей в базе на одно поле
-(IBAction)incMaxCountValue:(id)sender{
    
    NSInteger MaxCountValue = [databaseCount.text integerValue];
    MaxCountValue++;
    
    [TSSettings sharedController].limitRecordsInDatabase = MaxCountValue;
    [[TSSettings sharedController] saveSettings];
    
    databaseCount.text = [NSString stringWithFormat:@"%ld",(long)MaxCountValue];
}

//уменьшает допустимое количество записей в базе на одно поле
-(IBAction)decMaxCountValue:(id)sender{
    
    NSInteger MaxCountValue = [databaseCount.text integerValue];
    MaxCountValue--;
    
    if (MaxCountValue > 0){
        
        [TSSettings sharedController].limitRecordsInDatabase = MaxCountValue;
        [[TSSettings sharedController] saveSettings];
        databaseCount.text = [NSString stringWithFormat:@"%ld",(long)MaxCountValue];
    
        TSDatabase *database = [TSDatabase new];
        [database removeUnneededRecords];
    }

}

//изменить базу данных
-(IBAction)databaseCheng{
    
    TSDatabase *database = [TSDatabase new];
    if(chengDatabaseControl.selectedSegmentIndex == 0){
        
        [TSSettings sharedController].DBType = CoreDataDatabaseType;
        [database sqlToCoreData];
    }
    else if(chengDatabaseControl.selectedSegmentIndex == 1){
        
        [TSSettings sharedController].DBType = SQLiteDatabaseType;
        [database coreDataToSql];
    }
    [[TSSettings sharedController] saveSettings];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //загружаем настройки приложения
    NSNumber *count = [NSNumber numberWithInteger:[[TSSettings sharedController] limitRecordsInDatabase]];
    databaseCount.text = [count stringValue];
    
    DatabaseType databaseType = [[TSSettings sharedController]DBType];
    if (databaseType == CoreDataDatabaseType){
        
        chengDatabaseControl.selectedSegmentIndex = 0;
    }
    else if(databaseType == SQLiteDatabaseType){
        
        chengDatabaseControl.selectedSegmentIndex = 1;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Alert view

//метод выводит сообшение с указанной ошибкой
-(void)showAlertViewWithError:(NSError *)error{
    
    [[[UIAlertView alloc] initWithTitle:error.domain
                                message:error.description
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}


@end
