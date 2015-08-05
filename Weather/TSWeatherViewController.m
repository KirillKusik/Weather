/*
 ViewController в котором пользователь осуществляет поиск прогноза интересующего города.
 */

#import "TSWeatherViewController.h"
#import "TSWeatherDatabase.h"
#import "TSYahooWeather.h"
#import "TSYahooGeocode.h"
#import "MBProgressHUD.h"
#import "TSSettings.h"

@interface TSWeatherViewController () <MBProgressHUDDelegate>{
    
    NSArray *arrayFoundTowns;
    MBProgressHUD *HUD;
}

@property (nonatomic, weak) IBOutlet UITextView *weatherForecastField;
@property (nonatomic, weak) IBOutlet UISearchBar *searchCityName;
@property (nonatomic, weak) IBOutlet UITableView *searchRezaltTable;


@end

@implementation TSWeatherViewController

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


- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}


#pragma mark - Search bar delegate methods

//поиск городов с названиями похожими на введенное слово
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    //если строка поиска не пуста
    if ([_searchCityName.text length] > 0) {

        [self showHUD];
        
        //выполняем асинхронную загрузку списка городов
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSOperation *loadCityArray = [[NSInvocationOperation alloc] initWithTarget:self
                                                                      selector:@selector(downloadCitiesArray:)
                                                                        object:_searchCityName.text];
        [queue addOperation:loadCityArray];
    }
}

//редактирование поля поиска
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    //обнуляем массив вариантов населенных пунктов когда пользователь начинает вводить новые данные
    arrayFoundTowns = nil;
}

#pragma mark - download list of cities methods

//загрузить массив городов соответствующих указанному слову
-(void)downloadCitiesArray:(NSString *)city{
    
    //запрашиваем массив с адресами населенных пунктов и генокодами соответствующие им
    TSYahooWeather *yahooWeather = [[TSYahooWeather alloc] init];
    NSArray *townsArray = [yahooWeather getYahooGeocodes:city];
    
    //добавляем найденные города в список результатов SearchBar
    [self performSelectorOnMainThread:@selector(outputDataInSearchBar:)
                           withObject:townsArray
                        waitUntilDone:YES];
}

//выводим найденные города в список результатов SearchBar
-(void)outputDataInSearchBar:(NSArray *)array{
    
    arrayFoundTowns = array;
    
    //если массив не пуст
    if(arrayFoundTowns != nil){
        
        //выводим список вариантов SearchBar
        [self.searchDisplayController.searchResultsTableView performSelectorOnMainThread:@selector(reloadData)
                                                                              withObject:nil
                                                                           waitUntilDone:YES];
    }
    [self hideHUD];
}

#pragma mark - Table View methods

//указываем количество строк Table View равным количеству найденных городов
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //если массив не пуст
    if (arrayFoundTowns) {
            
        //то количество строк Search Bar будет равно количеству найденных населенных пунктов
        return [arrayFoundTowns count];
    
    } else{//в остальных случаях строк не будет
        return 0;
    }
}


//заполнение строк Table View вариантами найденных населенных пунктов
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:CellIdentifier];

    //заполняем ячейку таблицы соответствующим значением из массива найденных населенных пунктов
    TSYahooGeocode *adress = [arrayFoundTowns objectAtIndex:indexPath.item];
    NSString *cellText = [NSString stringWithFormat:@"%@, %@", adress.region, adress.country];
    cell.textLabel.text = adress.town;
    cell.detailTextLabel.text = cellText;
    return cell;
}


//загружаем прогноз погоды выбраного города
-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //если массив городов не пуст
    if ([arrayFoundTowns count] > 0){
     
        [self showHUD];

        //асинхронно загружаем прогноз в выбранном городе
        NSString *geocodeString = [[arrayFoundTowns objectAtIndex:[indexPath item]] geocode];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSOperation *loadWeather = [[NSInvocationOperation alloc] initWithTarget:self
                                                                        selector:@selector(downloadForecast:)
                                                                          object:geocodeString];
        [queue addOperation:loadWeather];
     }
}


#pragma mark - download weather methods

//загрузка прогноза погоды
-(void)downloadForecast:(NSString *)geocode{
    
    //загружаем прогноз по геокоду города
    TSYahooWeather *weatherRest = [[TSYahooWeather alloc] init];
    TSWeather *weather = [weatherRest getYahooWeather:geocode];
    
    //если погода не пуста
    if (weather != nil){
        
        //выводим результат
        [self performSelectorOnMainThread:@selector(forecastProcess:)
                               withObject:weather
                            waitUntilDone:YES];
        
    } else{ //если объект пуст выводим ошибку
        
        [self performSelectorOnMainThread:@selector(hideHUD)
                               withObject:nil
                            waitUntilDone:YES];
        
        [self performSelectorOnMainThread:@selector(showAlertViewWithError:)
                               withObject:weatherRest.error
                            waitUntilDone:YES];
    }
}

//выводим прогноз на экран и добавляем его в базу
-(void)forecastProcess:(TSWeather *)weather{
    
    //если объект с погодой не пуст
    if (weather != nil) {
        
        //выводим прогноз на экран
        self.searchDisplayController.active = NO;
        NSString *textWeather = [NSString stringWithFormat:@"City = %@\nDate = %@\nTemp = %dC\nText = %@",
                                 weather.city,
                                 weather.date,
                                 [weather.temp intValue],
                                 weather.text];
        _weatherForecastField.text = textWeather;
        
        //добавляем прогноз в базу
        TSWeatherDatabase *database = [[TSWeatherDatabase alloc] initWithSettings:[TSSettings sharedSettings]];
        if (![database addWeather:weather]){
            
            //если база данные не добавились в базу выводим окно с ошибкой
            [self showAlertViewWithError:database.error];
        }
    }
    [self hideHUD];
}


#pragma mark - HUD methods

//показать брогресбар
-(void)showHUD{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}

//скрыть прогресбар
-(void)hideHUD{
    
    [HUD removeFromSuperview];
    HUD = nil;
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
