 //
//  TSFirstViewController.m
//  Weather
//
//  Created by Admin on 13.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import "TSFirstViewController.h"
#import "TSDatabase.h"
#import "TSYahooWeather.h"
#import "MBProgressHUD.h"

@interface TSFirstViewController () <MBProgressHUDDelegate>{
    
    NSArray *arrayFoundTowns;
    MBProgressHUD *HUD;
}

@property (nonatomic, weak) IBOutlet UITextView *weatherForecastField;
@property (nonatomic, weak) IBOutlet UISearchBar *city;


@end

@implementation TSFirstViewController
@synthesize city,weatherForecastField;

//тестовая кнопка выводит прогноз погоды первого найденного значения (если найден хотябы 1-н)
-(IBAction)testButon:(id)sender{
    
    //если массив вариантов результатов поиска не пуст
    if ([arrayFoundTowns count] > 0){
        
        [self showHUD];
        
        //получаем гео-код первого населенного пункта в массиве найденных городов
        //(тестовый вариант! пользователь должен выбран произвольное значение)
        NSString *woeidString = [[arrayFoundTowns firstObject] objectForKey:kWoeidKey_woeid];
        
        TSYahooWeather *weatherRest = [[TSYahooWeather alloc] init];
        Weather *weather = [weatherRest getWeather:woeidString];
        
        //если объект с погодой не пуст
        if (weather != nil) {
            
            //выводим прогноз на экран
            NSString *textWeather = [NSString stringWithFormat:@"City = %@\nDate = %@\nTemp = %dC\nText = %@",
                                     weather.city,
                                     weather.date,
                                     [weather.temp intValue],
                                     weather.text];
            
            weatherForecastField.text = textWeather;
            
            //добавляем прогноз в базу
            TSDatabase *database = [[TSDatabase alloc] init];
            if ([database addRecordToDatabase:weather]){
            
            }
            //если база данные не добавились в базу
            else{
                
                //выводим окно с ощибкой
                [self showAlertViewWithError:database.error];
            }
        }
        //если объект с погодой пуст
        else{
            
            //выводим окно с ощибкой
            [self showAlertViewWithError:weatherRest.error];
        }
        
        [self hideHUD];
    }
}


- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    if (arrayFoundTowns == nil){
        arrayFoundTowns = [[NSArray alloc] init];
    }
    
    UITapGestureRecognizer *tapToDismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(tapped)];
    [tapToDismissKeyboard setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapToDismissKeyboard];
}


- (void)tapped{
    
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Search bar delegate methods

//не срабатывает при нажатии на поле списка в результате поиска
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"123");
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"123");
    }
}

//нажатие на кнопку поиска SearchBar
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    //если строка не пуста
    if ([city.text length] > 0) {

        [self showHUD];
        
        //запрашиваем массив с адресами населенных пунктов и гео-кодами соотвующие запросам
        TSYahooWeather *seatchTownWoeid = [[TSYahooWeather alloc] init];
        arrayFoundTowns = [seatchTownWoeid getWoeidArray:city.text];
        
        //если массив не пуст
        if(arrayFoundTowns != nil){
            
            //выводим список вариантов SearchBar
            [self.searchDisplayController.searchResultsTableView reloadData];
            self.weatherForecastField.text = @"Нажмите кнопку testButton для того что бы получить прогноз первого найденного значения";
        }
        //если массив пуст
        else{
            
            //выводим окно с ощибкой
            [self showAlertViewWithError:seatchTownWoeid.error];
        }
        
        [self hideHUD];
    }
}


-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    //обнуляем массив вариантов населенных пунктов когда пользователь начинает вводить новые данные
    arrayFoundTowns = nil;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //если tableView принадлежит Search Bar
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        //если массив не пуст
        if (arrayFoundTowns) {
            
            //то количество строк Search Bar будет равно количеству найденных населенных пунктов
            return [arrayFoundTowns count];
        }
        //в остальных случаях строк не будет
        else{
            
            return 0;
        }
    }
    else {
        
        return 0;
    }
}


//заполнение строк Search Bar вариантами найденных населенных пунктов
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        NSDictionary *adress = [arrayFoundTowns objectAtIndex:indexPath.item];
        NSString *cellText = [NSString stringWithFormat:@"%@, %@, %@",
                              [adress objectForKey:kWoeidKey_country],
                              [adress objectForKey:kWoeidKey_region],
                              [adress objectForKey:kWoeidKey_town]];
        
        cell.textLabel.text = cellText;
    } else {
        cell.textLabel.text = @"";
    }
    return cell;
}

#pragma mark - HUD methods

-(void)showHUD{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}


-(void)hideHUD{
    
    [HUD removeFromSuperview];
    HUD = nil;
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
