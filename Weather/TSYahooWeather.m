/*
 метод предназначен для загрузки прогноза погоды по заданному городу 
 при использовании REST сервиса Yahoo weather

 https://developer.yahoo.com/weather/documentation.html
*/

#import "TSYahooWeather.h"

static NSString * const kWoeidKey_query = @"query";
static NSString * const kWoeidKey_results = @"results";
static NSString * const kWoeidKey_place = @"place";
static NSString * const kWoeidKey_adminRegion = @"admin1";
static NSString * const kWoeidKey_content = @"content";
static NSString * const kWoeidKey_district = @"locality1";
static NSString * const kWoeidKey_count = @"count";
static NSString * const kWoeidKey_item = @"item";
static NSString * const kWoeidKey_condition = @"condition";
static NSString * const kWoeidKey_location = @"location";
static NSString * const kWoeidKey_channel = @"channel";

static NSString * const kWoeidKey_city = @"city";
static NSString * const kWoeidKey_code = @"code";
static NSString * const kWoeidKey_date = @"date";
static NSString * const kWoeidKey_temp = @"temp";
static NSString * const kWoeidKey_text = @"text";

@interface TSYahooWeather()
-(NSDictionary *)getAddressOfDictionary:(NSDictionary *)place;
-(NSArray *)woeids:(NSString *)city;
@end

@implementation TSYahooWeather

@synthesize error;

//Возвращает массив с прогнозом погоды в населенны пунктах
//с названиями соответствующими введенному слову
//также проверяет и подготавливает вводимое значение
-(NSArray *)getWoeidArray:(NSString *)city{
    
    //Если введеная строка не пустая
    if([city length] > 0 || [city isEqualToString:@""] == FALSE){
    
        //Подготавливаем слово для поиска
        NSString *cityName = [city lowercaseString];
        cityName = [cityName stringByReplacingOccurrencesOfString:@" " withString:@""];

        //Возврашаем результат запроса
        return  [self woeids:cityName];
    }
    //Если сторока пуста
    else{
        
        //Генерируем ошибку
        NSString *searchError = @"RESP Error";
        NSString *messageError = @"string is empty";
        NSString *descriptionError =@"Serarch string is empty";
        
        [self generateErrorWithDomain:searchError
                         ErrorMessage:messageError
                          Description:descriptionError];
        
        NSLog(@"Serarch string is empty");
        return nil;
    }
}

//Возвращает массив с прогнозом погоды в населенны пунктах
//с названиями соответствующими введенному слову
-(NSArray *)woeids:(NSString *)city{
    
    //загружаем данные по названию города в формате json
    NSString *woeidUrlString = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=select * from geo.places where text=\"%@\"&format=json", city];
    NSString *utfWoeidUrlString = [woeidUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URLWoeid = [NSURL URLWithString:utfWoeidUrlString];
    NSData *responseJsonData = [NSData dataWithContentsOfURL:URLWoeid];
    
    //конвертируем данные в словарь
    NSError *errorMassage;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseJsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&errorMassage];
    //если преобразование выполнилось корректно
    if ([NSJSONSerialization isValidJSONObject:responseDic])
    {
        
        //извлекаем из списка данные для массива адресов
        NSDictionary *query = [responseDic objectForKey:kWoeidKey_query];
        NSDictionary *results = [query objectForKey:kWoeidKey_results];
        
        //если был найден хоть один населенный пункт
        if (![results isEqual:[NSNull null]]){
            
            //получим адреса найденных населенных пунктов
            NSMutableArray *resaltArray = [[NSMutableArray alloc] init];
            
            NSInteger numberFoundLocations = [[query objectForKey:kWoeidKey_count] integerValue];
            if (numberFoundLocations == 1) {
                
                NSDictionary *place = [results objectForKey:kWoeidKey_place];
                [resaltArray addObject:[self getAddressOfDictionary:place]];
            }
            else{
                
                NSArray *places = [results objectForKey:kWoeidKey_place];
                for (NSDictionary *place in places) {
                
                    NSDictionary *address = [self getAddressOfDictionary:place];
                    if (address) {
                        [resaltArray addObject:address];
                    }
                }
            }
            //возвращаем массив словарей с адресами найденных населенных пунктов
            return resaltArray;
        }
        //если не найдено не одного населенного пункта
        else{
            
            //Генерируем ошибку
            NSString *searchError = @"RESP Error";
            NSString *messageError = @"Nothing Found";
            NSString *descriptionError =@"Search on this request returned no results";
            
            [self generateErrorWithDomain:searchError
                             ErrorMessage:messageError
                              Description:descriptionError];
            return nil;
        }
    }
    //ели полученны не корректные данные
    else{
        
        //завершаем метод с ошибкой
        error = errorMassage;
        return nil;
    }
}

//выделяет из словаря только страну, область, город и гео-код
-(NSDictionary *)getAddressOfDictionary:(NSDictionary *)place{
    
    NSDictionary *contryDic = [place objectForKey:kWoeidKey_country];
    NSString *contry;
    if (![contryDic isEqual:[NSNull null]]){ contry = [contryDic objectForKey:kWoeidKey_content];}
    else{ contry = @"";}//если нет названия страны
    
    NSDictionary *regionDic = [place objectForKey:kWoeidKey_adminRegion];
    NSString *region;
    if (![regionDic isEqual:[NSNull null]]){ region = [regionDic objectForKey:kWoeidKey_content];}
    else{ region = @"";}//если нет названия облость
    
    NSDictionary *townDic = [place objectForKey:kWoeidKey_district];
    NSString *town;
    if (![townDic isEqual:[NSNull null]]){ town = [townDic objectForKey:kWoeidKey_content];}
    else{ return nil; }//если нет названия города завершить итерацию
    
    NSDictionary *woeidDic = [place objectForKey:kWoeidKey_district];
    NSString *woeid;
    if (![woeidDic isEqual:[NSNull null]]){ woeid = [woeidDic objectForKey:kWoeidKey_woeid];}
    else{ return nil; }//если нет гео-кода завершить итерацию
    
    NSDictionary *resalpPlace = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 contry, kWoeidKey_country,
                                 region, kWoeidKey_region,
                                 town, kWoeidKey_town,
                                 woeid, kWoeidKey_woeid, nil];
    return resalpPlace;
}


//метод возвращает прогноз погоды (объект Weather) по введенному гео-коду
-(Weather *)getWeather:(NSString *)woeid{

    //Загружаем прогноз погоды по введенному геокоду
    NSString *weatherRequest = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=select * from weather.forecast where woeid=\"%@\" and u='c' &format=json", woeid];
    NSString *utfWeatherRequest = [weatherRequest stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URLWeather = [NSURL URLWithString:utfWeatherRequest];
    
    NSData *responseJsonData = [NSData dataWithContentsOfURL:URLWeather];
    
    //конвертируем данные в словарь
    NSError *errorMassage;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseJsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&errorMassage];
    //если данные коректно конвертировались в словарь
    if ([NSJSONSerialization isValidJSONObject:responseDic])
    {
        //извлекаем из словаря данные для заполнения объекта Weather
        NSDictionary *query = [responseDic objectForKey:kWoeidKey_query];
        NSDictionary *results = [query objectForKey:kWoeidKey_results];
    
        //если в ответе присутствуют данные о погоде
        if (![results isEqual:[NSNull null]]){
            
            //извлекаем данные из списка ответа
            NSDictionary *channel = [results objectForKey:@"channel"];
            
            NSString *city = [[channel objectForKey:kWoeidKey_location] objectForKey:kWoeidKey_city];
            if ([city isEqual:[NSNull null]]){
                
                //если объект с именем city не найден генерируем ошибку и завершаем метод
                [self generateErrorWithDomain:@"Yahoo weather error"
                                 ErrorMessage:@"Objeckt city not found"
                                  Description:@"Is not listed in the loaded parameter with the key city"];
                return nil;
            }
            
            NSDictionary *condition = [[channel objectForKey:kWoeidKey_item] objectForKey:kWoeidKey_condition];
            
            NSString *code = [condition objectForKey:kWoeidKey_code];
            if ([code isEqual:[NSNull null]]){
                
                //если объект с именем code не найден генерируем ошибку и завершаем метод
                [self generateErrorWithDomain:@"Yahoo weather error"
                                 ErrorMessage:@"Objeckt code not found"
                                  Description:@"Is not listed in the loaded parameter with the key code"];
                return nil;
            }
            
            NSString *date = [condition objectForKey:kWoeidKey_date];
            if ([date isEqual:[NSNull null]]){
                
                //если объект с именем date не найден генерируем ошибку и завершаем метод
                [self generateErrorWithDomain:@"Yahoo weather error"
                                 ErrorMessage:@"Objeckt date not found"
                                  Description:@"Is not listed in the loaded parameter with the key date"];
                return nil;
            }
            
            NSNumber *temp = [NSNumber numberWithInt:[[condition objectForKey:kWoeidKey_temp] intValue]];
            if ([temp isEqual:[NSNull null]]){
                
                //если объект с именем temp не найден генерируем ошибку и завершаем метод
                [self generateErrorWithDomain:@"Yahoo weather error"
                                 ErrorMessage:@"Objeckt temp not found"
                                  Description:@"Is not listed in the loaded parameter with the key temp"];
                return nil;
            }
            
            NSString *text = [condition objectForKey:kWoeidKey_text];
            if ([text isEqual:[NSNull null]]){
                
                //если объект с именем text не найден генерируем ошибку и завершаем метод
                [self generateErrorWithDomain:@"Yahoo weather error"
                                 ErrorMessage:@"Objeckt text not found"
                                  Description:@"Is not listed in the loaded parameter with the key text"];
                return nil;
            }
            
            //возвращаем объект Weather с полученными данными
            Weather *weather = [[Weather alloc] initWithNameOfCity:city
                                                              code:code
                                                              date:date
                                                              temp:temp
                                                              text:text];
            return weather;
        }
        //Если данные о погоде не найдены в ответе
        else{
            
            //генерируем оштбку и завершаем метод
            [self generateErrorWithDomain:@"Yahoo weather error"
                             ErrorMessage:@"Objeckt resalts not found"
                              Description:@"Is not listed in the loaded parameter with the key resalts"];
            return nil;
        }
    }
    //соловарь конвертировался не корректно
    else{
        
        //завершаем метод с ошибкой
        error = errorMassage;
        return nil;
    }
}

//метод генерирует ошибку по введенным данным
-(void)generateErrorWithDomain:(NSString *)domain
                  ErrorMessage:(NSString *)message
                   Description:(NSString *)description{
    
    NSArray *objArray = [NSArray arrayWithObjects:description, message, nil];
    NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
    error = [NSError errorWithDomain:domain code:1 userInfo:userInfo];
}
@end
