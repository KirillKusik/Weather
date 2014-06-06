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

-(IBAction)changAddres:(id)sender{
    [TSSettings sharedController].addresDbHost = hostAddres.text;
    [[TSSettings sharedController] saveSettings];
}

-(IBAction)inc:(id)sender{
    NSInteger val = [dbCount.text integerValue];
    val++;
    [TSSettings sharedController].DBCount = val;
    [[TSSettings sharedController] saveSettings];
    dbCount.text = [NSString stringWithFormat:@"%ld",(long)val];
}

-(IBAction)dec:(id)sender{
    NSInteger val = [dbCount.text integerValue];
    val--;
    [TSSettings sharedController].DBCount = val;
    [[TSSettings sharedController] saveSettings];
    dbCount.text = [NSString stringWithFormat:@"%ld",(long)val];
    TSDB *db = [TSDB new];
    [db removeUnneededRecords];
}

-(IBAction)dbCheng{
    TSDB *db = [TSDB new];
    if(DBChengControl.selectedSegmentIndex == 0){
        [TSSettings sharedController].DBType = true;
        [db mysqlToCoreData];
        hostAddres.enabled = false;
        changHostName.enabled = false;
    }
    else{
        [TSSettings sharedController].DBType = false;
        [db coreDataToMysql];
        hostAddres.enabled = true;
        changHostName.enabled = true;
    }
    [[TSSettings sharedController] saveSettings];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSNumber *count = [NSNumber numberWithInteger:[[TSSettings sharedController] DBCount]];
    dbCount.text = [count stringValue];
    
    hostAddres.text = [[TSSettings sharedController] addresDbHost];
    
    BOOL type = [[TSSettings sharedController]DBType];
    if (type){
        DBChengControl.selectedSegmentIndex = 0;
        hostAddres.enabled = false;
        changHostName.enabled = false;
    }
    else{
        DBChengControl.selectedSegmentIndex = 1;
        hostAddres.enabled = true;
        changHostName.enabled = true;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
