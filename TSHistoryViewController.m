/*
 ViewController демонстрирующий историю просмотренных прогнозов
 */

#import "TSHistoryViewController.h"
#import "TSWeatherDatabase.h"
#import "TSWeather.h"

@interface TSHistoryViewController ()
@property (nonatomic) NSArray *datadaseArray;
@property (nonatomic, weak) IBOutlet UITableView *table;
@end

@implementation TSHistoryViewController

-(void)viewDidAppear:(BOOL)animated {
    TSWeatherDatabase *database = [TSWeatherDatabase sharedDatabase];
    self.datadaseArray = [database getAllWeathers];
    if (database.error != nil) {
        [[[UIAlertView alloc] initWithTitle:database.error.domain message:database.error.description delegate:nil
                cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    [self.table reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.datadaseArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell Identifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
            reuseIdentifier:cellIdentifier];
    NSInteger indexOutputWeather = ([self.datadaseArray count] - 1) - [indexPath row];
    TSWeather *weather = [self.datadaseArray objectAtIndex:indexOutputWeather];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@˚C", weather.city, weather.temp];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = weather.date;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return cell;
}

@end
