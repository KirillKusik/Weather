//
//  TSHistoriController.m
//  Weather
//
//  Created by Admin on 23.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import "TSHistoriController.h"

@interface TSHistoriController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self viewDidAppear:NO];
}

-(void) viewDidAppear:(BOOL)animated{
    //NSLog(@"ok");
    TSDB *db = [TSDB new];
    weatherHistory = [NSArray arrayWithArray:[db getWeather]];
    [table reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [weatherHistory count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell Identifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *historyLine = [weatherHistory objectAtIndex:[indexPath row]];
    
    NSString *fruit = [NSString stringWithFormat:@"%@ %@ %@",
                       [historyLine objectForKey:@"date"],
                       [historyLine objectForKey:@"city"],
                       [historyLine objectForKey:@"temp"]];
    [cell.textLabel setText:fruit];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
