/*
 ViewController демонстрирующий историю просмотренных прогнозов
 */

#import "TSHistoriViewController.h"
#import "TSWeatherDatabase.h"

@interface TSHistoriViewController (){
    NSArray *datadaseArray;
}

@end

@implementation TSHistoriViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    [self viewDidAppear:NO];
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}

//обновление истории поиска при переходе на вкладку
-(void)viewDidAppear:(BOOL)animated{

    TSWeatherDatabase *database = [[TSWeatherDatabase alloc] initWithSettings:[TSSettings sharedSettings]];
    datadaseArray = [database getWeatherArray];

    //если объект базы данных содержит ошибку вывести ее на экран
    if (database.error != nil) {
        [[[UIAlertView alloc] initWithTitle:database.error.domain
                                    message:database.error.description
                                    delegate:nil
                            cancelButtonTitle:@"Ok"
                            otherButtonTitles:nil] show];
    }
    [table reloadData];
}

//задаем количество строк в таблице
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [datadaseArray count];
}

//заполняем ячейки таблицы историей поиска
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //настраиваем свойства ячейки
    static NSString *cellIdentifier = @"Cell Identifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    //заполняем ячейку
    NSInteger indexOutputWeather = ([datadaseArray count] - 1) - [indexPath row];
    TSWeather *weather = [datadaseArray objectAtIndex:indexOutputWeather];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@˚C", weather.city, weather.temp];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = weather.date;
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
        
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return cell;
}

@end
