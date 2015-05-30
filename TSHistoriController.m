//
//  TSHistoriController.m
//  Weather
//
//  Created by Admin on 23.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import "TSHistoriController.h"
#import "TSDatabase.h"


@interface TSHistoriController (){
    NSArray *datadaseArray;
}

@end

@implementation TSHistoriController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    [self viewDidAppear:NO];
}

-(void)viewDidAppear:(BOOL)animated{

    TSDatabase *database = [[TSDatabase alloc] init];
    datadaseArray = [database getArrayOfRecordsFromDatabase];

    if (datadaseArray == nil) {
        [[[UIAlertView alloc] initWithTitle:database.error.domain
                                    message:database.error.description
                                    delegate:nil
                            cancelButtonTitle:@"Ok"
                            otherButtonTitles:nil] show];
    }
    
    [table reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [datadaseArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"Cell Identifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Weather *weather = [datadaseArray objectAtIndex:[indexPath row]];
    NSString *historiLineString = [NSString stringWithFormat:@"%@ %@ %@",
                       weather.date,
                       weather.city,
                       weather.temp];
    
    [cell.textLabel setText:historiLineString];
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
        
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return cell;
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}


@end
