//
//  TSSecondViewController.m
//  Weather
//
//  Created by Admin on 13.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import "TSSecondViewController.h"
#import "TSSettings.h"
#import "TSDB.h"
@implementation TSSecondViewController



-(IBAction)inc:(id)sender{
    NSInteger val = [dbCount.text integerValue];
    val++;
    [TSSettings sharedController].limitRecordsInDatabase = val;
    [[TSSettings sharedController] saveSettings];
    dbCount.text = [NSString stringWithFormat:@"%ld",(long)val];
}

-(IBAction)dec:(id)sender{
    NSInteger val = [dbCount.text integerValue];
    val--;
    [TSSettings sharedController].limitRecordsInDatabase = val;
    [[TSSettings sharedController] saveSettings];
    dbCount.text = [NSString stringWithFormat:@"%ld",(long)val];
    TSDB *db = [TSDB new];
    [db removeUnneededRecords];
}

-(IBAction)dbCheng{
    TSDB *db = [TSDB new];
    if(DBChengControl.selectedSegmentIndex == 0){
        [TSSettings sharedController].DBType = true;
        [db sqlToCoreData];
    }
    else{
        [TSSettings sharedController].DBType = false;
        [db coreDataToSql];
    }
    [[TSSettings sharedController] saveSettings];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSNumber *count = [NSNumber numberWithInteger:[[TSSettings sharedController] limitRecordsInDatabase]];
    dbCount.text = [count stringValue];
    

    
    BOOL type = [[TSSettings sharedController]DBType];
    if (type){
        DBChengControl.selectedSegmentIndex = 0;
    }
    else{
        DBChengControl.selectedSegmentIndex = 1;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
