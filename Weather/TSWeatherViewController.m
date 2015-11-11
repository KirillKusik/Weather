/*
 ViewController в котором пользователь осуществляет поиск прогноза интересующего города.
 */
#import "TSWeatherViewController.h"
#import "TSWeatherDatabase.h"
#import "TSYahooWeather.h"
#import "TSYahooGeocode.h"
#import "MBProgressHUD.h"

@interface TSWeatherViewController () <MBProgressHUDDelegate, TSYahooWeatherProtocol ,UITableViewDelegate,
        UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic) NSArray *arrayFoundTowns;
@property (nonatomic, weak) IBOutlet UITextView *weatherForecastField;
@property (nonatomic, weak) IBOutlet UISearchBar *searchCityName;
@property (nonatomic, weak) IBOutlet UITableView *searchCityRezalt;
@end

@implementation TSWeatherViewController

#pragma mark - get list of cities
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([self.searchCityName.text length] > 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        TSYahooWeather *yahooWeather = [[TSYahooWeather alloc] initWithDelegate:self];
        [yahooWeather getYahooGeocodes:self.searchCityName.text];
    }
}

-(void)TakeYahooGeocodeArray:(NSArray *)geocodeArray error:(NSError *)error {
    if (geocodeArray) {
        self.arrayFoundTowns = geocodeArray;
        if(self.arrayFoundTowns != nil) {
            //выводим список вариантов SearchBar
            [self.searchCityRezalt reloadData];
        }
    } else {
        [self showAlertViewWithError:error];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark - download weather
-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.arrayFoundTowns count] > 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        TSYahooWeather *weatherRest = [[TSYahooWeather alloc] initWithDelegate:self];
        [weatherRest getYahooWeather:[[self.arrayFoundTowns objectAtIndex:[indexPath item]] geocode]];
    }
}

-(void)TakeYahooWeather:(TSWeather *)weather error:(NSError *)error {
    if (weather) {
        [self deactivateSearch];
        NSString *textWeather = [NSString stringWithFormat:@"City = %@\nDate = %@\nTemp = %dC\nText = %@",
                weather.city, weather.date, [weather.temp intValue], weather.text];
        self.weatherForecastField.text = textWeather;
        TSWeatherDatabase *database = [TSWeatherDatabase sharedDatabase];
        if (![database addWeather:weather]) {
            [self showAlertViewWithError:database.error];
        }
    } else {
        [self showAlertViewWithError:error];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark - Activation/deactivation of the search string
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self activateSearch];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self deactivateSearch];
}

-(void)activateSearch {
    self.arrayFoundTowns = nil;
    [self.searchCityRezalt reloadData];
    self.searchCityRezalt.hidden = NO;
}

-(void)deactivateSearch {
    self.searchCityRezalt.hidden = YES;
    self.searchCityName.text = @"";
    [self.view endEditing:YES];
}

#pragma mark - Table View methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.arrayFoundTowns) {
        return [self.arrayFoundTowns count];
    } else {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
            reuseIdentifier:CellIdentifier];
    TSYahooGeocode *adress = [self.arrayFoundTowns objectAtIndex:indexPath.item];
    NSString *cellText = [NSString stringWithFormat:@"%@, %@", adress.region, adress.country];
    cell.textLabel.text = adress.town;
    cell.detailTextLabel.text = cellText;
    cell.backgroundColor = [UIColor lightGrayColor];
    return cell;
}

#pragma mark - Alert view
-(void)showAlertViewWithError:(NSError *)error {
    NSDictionary *erorDic = error.userInfo;
    [[[UIAlertView alloc] initWithTitle:[erorDic objectForKey:NSLocalizedFailureReasonErrorKey]
            message:[erorDic objectForKey:NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:@"Ok"
            otherButtonTitles:nil] show];
}

@end
