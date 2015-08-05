/*
 метод предназначен для загрузки прогноза погоды по заданному городу 
 при использовании REST сервиса Yahoo weather

 https://developer.yahoo.com/weather/documentation.html
*/

#import "TSYahooWeather.h"
#import "TSYahooGeocode.h"

NSString * kYahooWeatherKey_query = @"query";
NSString * kYahooWeatherKey_results = @"results";
NSString * kYahooWeatherKey_place = @"place";
NSString * kYahooWeatherKey_adminRegion = @"admin1";
NSString * kYahooWeatherKey_content = @"content";
NSString * kYahooWeatherKey_district = @"locality1";
NSString * kYahooWeatherKey_count = @"count";
NSString * kYahooWeatherKey_item = @"item";
NSString * kYahooWeatherKey_condition = @"condition";
NSString * kYahooWeatherKey_location = @"location";
NSString * kYahooWeatherKey_channel = @"channel";

NSString * kYahooWeatherKey_city = @"city";
NSString * kYahooWeatherKey_code = @"code";
NSString * kYahooWeatherKey_date = @"date";
NSString * kYahooWeatherKey_temp = @"temp";
NSString * kYahooWeatherKey_text = @"text";

NSString * kYahooWeatherKey_country = @"country";
NSString * kYahooWeatherKey_region = @"region";
NSString * kYahooWeatherKey_town = @"town";
NSString * kYahooWeatherKey_Geocode = @"woeid";

@implementation TSYahooWeather

//Возвращает массив геокодов населенны пунктов названия которых соответствуют введенному слову
-(NSArray *)getYahooGeocodes:(NSString *)city{
    
    //Если введеная строка не пустая запрашиваем массив городов с похожими названиями
    if([city length] > 0 || [city isEqualToString:@""] == FALSE){
    
        NSString *cityName = [city lowercaseString];
        cityName = [cityName stringByReplacingOccurrencesOfString:@" " withString:@""];
        return  [self geocodes:cityName];
        
    } else{//Если сторока пуста генерируем ошибку
        
        NSString *searchError = @"RESP Error";
        NSString *messageError = @"string is empty";
        NSString *descriptionError =@"Serarch string is empty";
        [self generateErrorWithDomain:searchError
                         ErrorMessage:messageError
                          Description:descriptionError];
        return nil;
    }
}

//Возвращает массив геокодов населенны пунктов
-(NSArray *)geocodes:(NSString *)city{
    
    //загружаем данные по городам с похожими названиями в формате json
    NSString *geocodeUrlString = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=select * from geo.places where text=\"%@\"&format=json", city];
    NSString *utfGeocodeUrlString = [geocodeUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *geocodeURL = [NSURL URLWithString:utfGeocodeUrlString];
    NSData *responseJsonData = [NSData dataWithContentsOfURL:geocodeURL];
    
    //конвертируем данные в словарь
    NSError *errorMassage;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseJsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&errorMassage];
    
    //если преобразование выполнилось корректно извлекаем из списка адреса и геокоды городов
    if ([NSJSONSerialization isValidJSONObject:responseDic]){
        
        NSDictionary *query = [responseDic objectForKey:kYahooWeatherKey_query];
        NSDictionary *results = [query objectForKey:kYahooWeatherKey_results];
        
        //если был найден хоть один населенный пункт получим его адрес
        if (![results isEqual:[NSNull null]]){
            
            NSMutableArray *resaltArray = [[NSMutableArray alloc] init];
            NSInteger numberFoundLocations = [[query objectForKey:kYahooWeatherKey_count] integerValue];
            if (numberFoundLocations == 1) {
                
                NSDictionary *place = [results objectForKey:kYahooWeatherKey_place];
                [resaltArray addObject:[self getGeocodeFromDictionary:place]];
            
            } else{
                
                NSArray *places = [results objectForKey:kYahooWeatherKey_place];
                for (NSDictionary *place in places) {
                
                    TSYahooGeocode *address = [self getGeocodeFromDictionary:place];
                    if (address) {
                        [resaltArray addObject:address];
                    }
                }
            }
            //возвращаем массив объектов TSYahooGeocode с адресами найденных населенных пунктов
            return resaltArray;
            
        } else{//если не найдено не одного населенного пункта генерируем ошибку
            
            NSString *searchError = @"RESP Error";
            NSString *messageError = @"Nothing Found";
            NSString *descriptionError =@"Search on this request returned no results";
            [self generateErrorWithDomain:searchError ErrorMessage:messageError Description:descriptionError];
            return nil;
        }
    } else{//если получены не корректные данные завершаем метод с ошибкой
        
        _error = errorMassage;
        return nil;
    }
}

//выделяет из словаря только страну, область, город и геокод
-(TSYahooGeocode *)getGeocodeFromDictionary:(NSDictionary *)place{
    
    NSDictionary *contryDic = [place objectForKey:kYahooWeatherKey_country];
    NSString *contry;
    if (![contryDic isEqual:[NSNull null]]){ contry = [contryDic objectForKey:kYahooWeatherKey_content];}
    else{ contry = @"";}//если нет названия страны
    
    NSDictionary *regionDic = [place objectForKey:kYahooWeatherKey_adminRegion];
    NSString *region;
    if (![regionDic isEqual:[NSNull null]]){ region = [regionDic objectForKey:kYahooWeatherKey_content];}
    else{ region = @"";}//если нет названия область
    
    NSDictionary *townDic = [place objectForKey:kYahooWeatherKey_district];
    NSString *town;
    if (![townDic isEqual:[NSNull null]]){ town = [townDic objectForKey:kYahooWeatherKey_content];}
    else{ return nil; }//если нет названия города завершить итерацию

    NSString *geocodeID;
    if (![townDic isEqual:[NSNull null]]){ geocodeID = [townDic objectForKey:kYahooWeatherKey_Geocode];}
    else{ return nil; }//если нет геокода завершить итерацию
    
    TSYahooGeocode *geocode = [[TSYahooGeocode alloc] initGeocodeWithContry:contry
                                                                     region:region
                                                                       town:town
                                                                    geocode:geocodeID];
    return geocode;
}


//метод возвращает прогноз погоды (объект Weather) по введенному геокоду
-(TSWeather *)getYahooWeather:(NSString *)geocode{

    //Загружаем прогноз погоды по введенному геокоду
    NSString *weatherRequest = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=select * from weather.forecast where woeid=\"%@\" and u='c' &format=json", geocode];
    NSString *utfWeatherRequest = [weatherRequest stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URLWeather = [NSURL URLWithString:utfWeatherRequest];
    
    NSData *responseJsonData = [NSData dataWithContentsOfURL:URLWeather];
    
    //конвертируем данные в словарь
    NSError *errorMassage;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseJsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&errorMassage];
    //если данные корректно конвертировались в словарь
    if ([NSJSONSerialization isValidJSONObject:responseDic])
    {
        //извлекаем из словаря данные для заполнения объекта Weather
        NSDictionary *query = [responseDic objectForKey:kYahooWeatherKey_query];
        NSDictionary *results = [query objectForKey:kYahooWeatherKey_results];
    
        //если в ответе присутствуют данные о погоде извлекаем данные из списка ответа
        if (![results isEqual:[NSNull null]]){

            NSDictionary *channel = [results objectForKey:@"channel"];
            NSString *city = [[channel objectForKey:kYahooWeatherKey_location] objectForKey:kYahooWeatherKey_city];
            
            //если объект с именем city не найден генерируем ошибку и завершаем метод
            if (city == nil){

                [self generateErrorWithDomain:@"Yahoo weather error"
                                 ErrorMessage:@"Objeckt city not found"
                                  Description:@"Is not listed in the loaded parameter with the key city"];
                return nil;
            }
            
            NSDictionary *condition = [[channel objectForKey:kYahooWeatherKey_item] objectForKey:kYahooWeatherKey_condition];
            NSString *code = [condition objectForKey:kYahooWeatherKey_code];
            
            //если объект с именем code не найден генерируем ошибку и завершаем метод
            if (code == nil){
                
                [self generateErrorWithDomain:@"Yahoo weather error"
                                 ErrorMessage:@"Objeckt code not found"
                                  Description:@"Is not listed in the loaded parameter with the key code"];
                return nil;
            }
            
            NSString *date = [condition objectForKey:kYahooWeatherKey_date];
            
            //если объект с именем date не найден генерируем ошибку и завершаем метод
            if (date == nil){

                [self generateErrorWithDomain:@"Yahoo weather error"
                                 ErrorMessage:@"Objeckt date not found"
                                  Description:@"Is not listed in the loaded parameter with the key date"];
                return nil;
            }
            
            NSNumber *temp = [NSNumber numberWithInt:[[condition objectForKey:kYahooWeatherKey_temp] intValue]];
            
            //если объект с именем temp не найден генерируем ошибку и завершаем метод
            if (temp == nil){
                
                [self generateErrorWithDomain:@"Yahoo weather error"
                                 ErrorMessage:@"Objeckt temp not found"
                                  Description:@"Is not listed in the loaded parameter with the key temp"];
                return nil;
            }
            
            NSString *text = [condition objectForKey:kYahooWeatherKey_text];
            
            //если объект с именем text не найден генерируем ошибку и завершаем метод
            if ([text isEqual:[NSNull null]]){

                [self generateErrorWithDomain:@"Yahoo weather error"
                                 ErrorMessage:@"Objeckt text not found"
                                  Description:@"Is not listed in the loaded parameter with the key text"];
                return nil;
            }
            
            //возвращаем объект Weather с полученными данными
            TSWeather *weather = [[TSWeather alloc] initWithNameOfCity:city
                                                              code:code
                                                              date:date
                                                              temp:temp
                                                              text:text];
            return weather;
            
        } else{//Если данные о погоде не найдены в ответе генерируем оштбку и завершаем метод
            
            [self generateErrorWithDomain:@"Yahoo weather error"
                             ErrorMessage:@"Objeckt resalts not found"
                              Description:@"Is not listed in the loaded parameter with the key resalts"];
            return nil;
        }
    } else{//если соловарь конвертировался не корректно завершаем метод с ошибкой
        
        _error = errorMassage;
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
    _error = [NSError errorWithDomain:domain code:1 userInfo:userInfo];
}
@end
