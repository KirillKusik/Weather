/*
 метод предназначен для загрузки прогноза погоды по заданному городу 
 при использовании REST сервиса Yahoo weather

 https://developer.yahoo.com/weather/documentation.html
*/

#import "TSYahooWeather.h"
#import "TSYahooGeocode.h"

NSString *kYahooWeatherKey_query = @"query";
NSString *kYahooWeatherKey_results = @"results";
NSString *kYahooWeatherKey_place = @"place";
NSString *kYahooWeatherKey_adminRegion = @"admin1";
NSString *kYahooWeatherKey_content = @"content";
NSString *kYahooWeatherKey_district = @"locality1";
NSString *kYahooWeatherKey_count = @"count";
NSString *kYahooWeatherKey_item = @"item";
NSString *kYahooWeatherKey_condition = @"condition";
NSString *kYahooWeatherKey_location = @"location";
NSString *kYahooWeatherKey_channel = @"channel";

NSString *kYahooWeatherKey_city = @"city";
NSString *kYahooWeatherKey_code = @"code";
NSString *kYahooWeatherKey_date = @"date";
NSString *kYahooWeatherKey_temp = @"temp";
NSString *kYahooWeatherKey_text = @"text";

NSString *kYahooWeatherKey_country = @"country";
NSString *kYahooWeatherKey_region = @"region";
NSString *kYahooWeatherKey_town = @"town";
NSString *kYahooWeatherKey_Geocode = @"woeid";

NSString *kInvalidСharacters = @"0123456789/*-+.,\\\';][=-`§~!@#$%^&()_<>?\":|}{±";

@interface TSYahooWeather  ()
@property (weak) id <TSYahooWeatherProtocol> delegate;
@property NSError *error;
@end

@implementation TSYahooWeather

-(instancetype) initWithDelegate:(id)delegate {
    if (self) {
        self = [super init];
    }
    self.delegate = delegate;
    return self;
}

#pragma mark - Request for the names of the cities whom resemble a specified
-(void)getYahooGeocodes:(NSString *)city {
    //Если введеная строка не пустая запрашиваем массив городов с похожими названиями
    if (self.delegate && [self.delegate respondsToSelector:@selector(TakeYahooGeocodeArray:error:)]) {
        if([city length] > 0 || [city isEqualToString:@""] == FALSE) {
            NSString *cityName = [city lowercaseString];
            cityName = [cityName stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSCharacterSet *invalidСharacters = [NSCharacterSet characterSetWithCharactersInString:kInvalidСharacters];
            NSRange range = [cityName rangeOfCharacterFromSet:invalidСharacters];
            if (range.length == 0) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSArray *geocodeArray = [self geocodes:cityName];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.delegate performSelector:@selector(TakeYahooGeocodeArray: error:) withObject:geocodeArray
                                withObject:self.error];
                    });
                });
            } else {
                [self generateErrorWithDomain:@"RESP Error" ErrorMessage:@"invalid characters"
                        Description:[NSString stringWithFormat:@"line contains one or more invalid characters (%@)",
                        kInvalidСharacters]];
                [self.delegate performSelector:@selector(TakeYahooGeocodeArray: error:) withObject:nil
                        withObject:self.error];
            }
        } else {//Если сторока пуста генерируем ошибку
            [self generateErrorWithDomain:@"RESP Error" ErrorMessage:@"string is empty"
                    Description:@"Serarch string is empty"];
            [self.delegate performSelector:@selector(TakeYahooGeocodeArray: error:) withObject:nil
                    withObject:self.error];
        }
    } else {
        [self generateErrorWithDomain:@"RESP Error" ErrorMessage:@"Delegate is nil"
                Description:@"Delegate Unknown"];
        [self.delegate performSelector:@selector(TakeYahooGeocodeArray: error:) withObject:nil
                withObject:self.error];
    }
}

//Возвращает массив геокодов населенны пунктов
-(NSArray *)geocodes:(NSString *)city {
    //загружаем данные по городам с похожими названиями в формате json
    NSString *geocodeUrlString = [NSString stringWithFormat:
          @"http://query.yahooapis.com/v1/public/yql?q=select * from geo.places where text=\"%@\"&format=json", city];
    NSString *utfGeocodeUrlString = [geocodeUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *geocodeURL = [NSURL URLWithString:utfGeocodeUrlString];
    NSData *responseJsonData = [NSData dataWithContentsOfURL:geocodeURL];
    //конвертируем данные в словарь
    NSError *errorMassage;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseJsonData
            options:NSJSONReadingMutableContainers error:&errorMassage];
    //если преобразование выполнилось корректно извлекаем из списка адреса и геокоды городов
    if ([NSJSONSerialization isValidJSONObject:responseDic]) {
        NSDictionary *query = [responseDic objectForKey:kYahooWeatherKey_query];
        NSDictionary *results = [query objectForKey:kYahooWeatherKey_results];
        //если был найден хоть один населенный пункт получим его адрес
        if (![results isEqual:[NSNull null]]) {
            NSMutableArray *locationsArray = [[NSMutableArray alloc] init];
            NSInteger numberFoundLocations = [[query objectForKey:kYahooWeatherKey_count] integerValue];
            if (numberFoundLocations == 1) {
                NSDictionary *place = [results objectForKey:kYahooWeatherKey_place];
                [locationsArray addObject:[self getGeocodeFromDictionary:place]];
            } else if (numberFoundLocations > 1) {
                NSArray *places = [results objectForKey:kYahooWeatherKey_place];
                for (NSDictionary *place in places) {
                    TSYahooGeocode *address = [self getGeocodeFromDictionary:place];
                    if (address) {
                        [locationsArray addObject:address];
                    }
                }
            }
            //возвращаем массив объектов TSYahooGeocode с адресами найденных населенных пунктов
            return locationsArray;
        } else {//если не найдено не одного населенного пункта генерируем ошибку
            [self generateErrorWithDomain:@"RESP Error" ErrorMessage:@"Nothing Found"
                    Description:@"Search on this request returned no results"];
            return nil;
        }
    } else {//если получены не корректные данные завершаем метод с ошибкой
        self.error = errorMassage;
        return nil;
    }
}

//выделяет из словаря только страну, область, город и геокод
-(TSYahooGeocode *)getGeocodeFromDictionary:(NSDictionary *)place {
    NSDictionary *contryDic = [place objectForKey:kYahooWeatherKey_country];
    NSString *contry;
    if (![contryDic isEqual:[NSNull null]]) {
        contry = [contryDic objectForKey:kYahooWeatherKey_content];
    } else { //если нет названия страны
        contry = @"";
    }
    NSDictionary *regionDic = [place objectForKey:kYahooWeatherKey_adminRegion];
    NSString *region;
    if (![regionDic isEqual:[NSNull null]]) {
        region = [regionDic objectForKey:kYahooWeatherKey_content];
    } else { //если нет названия область
        region = @"";
    }
    NSDictionary *townDic = [place objectForKey:kYahooWeatherKey_district];
    NSString *town;
    if (![townDic isEqual:[NSNull null]]) {
        town = [townDic objectForKey:kYahooWeatherKey_content];
    } else { //если нет названия города завершить итерацию
        return nil;
    }
    NSString *geocodeID;
    if (![townDic isEqual:[NSNull null]]) {
        geocodeID = [townDic objectForKey:kYahooWeatherKey_Geocode];
    } else { //если нет геокода завершить итерацию
        return nil;
    }
    TSYahooGeocode *geocode = [[TSYahooGeocode alloc] initGeocodeWithContry:contry region:region town:town
            geocode:geocodeID];
    return geocode;
}


#pragma mark - Requesting forecast
-(void)getYahooWeather:(NSString *)geocode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(TakeYahooWeather: error:)]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            TSWeather *weather = [self getWeather:geocode];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate performSelector:@selector(TakeYahooWeather:error:) withObject:weather
                        withObject:self.error];
            });
        });
    } else {
        [self generateErrorWithDomain:@"RESP Error" ErrorMessage:@"Delegate is nil"
                Description:@"Delegate Unknown"];
        [self.delegate performSelector:@selector(TakeYahooWeather:error:) withObject:nil withObject:self.error];
    }
}

-(TSWeather *)getWeather:(NSString *)geocode {
    //Загружаем прогноз погоды по введенному геокоду
    NSString *weatherRequest = [NSString stringWithFormat:
            @"http://query.yahooapis.com/v1/public/yql?q=select * from weather.forecast where woeid=\"%@\" and u='c' &format=json",
            geocode];
    NSString *utfWeatherRequest = [weatherRequest stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URLWeather = [NSURL URLWithString:utfWeatherRequest];
    NSData *responseJsonData = [NSData dataWithContentsOfURL:URLWeather];
    //конвертируем данные в словарь
    NSError *errorMassage;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseJsonData
            options:NSJSONReadingMutableContainers error:&errorMassage];
    //если данные корректно конвертировались в словарь
    if ([NSJSONSerialization isValidJSONObject:responseDic]) {
        //извлекаем из словаря данные для заполнения объекта Weather
        NSDictionary *query = [responseDic objectForKey:kYahooWeatherKey_query];
        NSDictionary *results = [query objectForKey:kYahooWeatherKey_results];
        //если в ответе присутствуют данные о погоде извлекаем данные из списка ответа
        if (![results isEqual:[NSNull null]]) {
            NSDictionary *channel = [results objectForKey:kYahooWeatherKey_channel];
            NSString *city = [[channel objectForKey:kYahooWeatherKey_location] objectForKey:kYahooWeatherKey_city];
            //если объект с именем city не найден генерируем ошибку и завершаем метод
            if (city == nil) {
                [self generateErrorNotFoundParameterPrognosis:kYahooWeatherKey_city];
                return nil;
            }
            NSDictionary *condition = [[channel objectForKey:kYahooWeatherKey_item]
                    objectForKey:kYahooWeatherKey_condition];
            NSString *code = [condition objectForKey:kYahooWeatherKey_code];
            //если объект с именем code не найден генерируем ошибку и завершаем метод
            if (code == nil) {
                [self generateErrorNotFoundParameterPrognosis:kYahooWeatherKey_code];
                return nil;
            }
            NSString *date = [condition objectForKey:kYahooWeatherKey_date];
            //если объект с именем date не найден генерируем ошибку и завершаем метод
            if (date == nil) {
                [self generateErrorNotFoundParameterPrognosis:kYahooWeatherKey_date];
                return nil;
            }
            NSNumber *temp = [NSNumber numberWithInt:[[condition objectForKey:kYahooWeatherKey_temp] intValue]];
            //если объект с именем temp не найден генерируем ошибку и завершаем метод
            if (temp == nil) {
                [self generateErrorNotFoundParameterPrognosis:kYahooWeatherKey_temp];
                return nil;
            }
            NSString *text = [condition objectForKey:kYahooWeatherKey_text];
            //если объект с именем text не найден генерируем ошибку и завершаем метод
            if ([text isEqual:[NSNull null]]) {
                [self generateErrorNotFoundParameterPrognosis:kYahooWeatherKey_text];
                return nil;
            }
            //возвращаем объект Weather с полученными данными
            TSWeather *weather = [[TSWeather alloc] initWithNameOfCity:city code:code date:date temp:temp text:text];
            return weather;
        } else {//Если данные о погоде не найдены в ответе генерируем оштбку и завершаем метод
            [self generateErrorWithDomain:@"Yahoo weather error" ErrorMessage:@"Objeckt resalts not found"
                    Description:@"Is not listed in the loaded parameter with the key resalts"];
            return nil;
        }
    } else {//если соловарь конвертировался не корректно завершаем метод с ошибкой
        self.error = errorMassage;
        return nil;
    }
}

#pragma mark - Error metods
-(void)generateErrorNotFoundParameterPrognosis:(NSString *)parameter {
    [self generateErrorWithDomain:@"Yahoo weather error"
            ErrorMessage:[NSString stringWithFormat:@"Objeckt %@ not found", parameter]
            Description:[NSString stringWithFormat:@"Is not listed in the loaded parameter with the key %@",parameter]];
}

-(void)generateErrorWithDomain:(NSString *)domain ErrorMessage:(NSString *)message Description:(NSString *)description {
    NSArray *objArray = [NSArray arrayWithObjects:description, message, nil];
    NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
    self.error = [NSError errorWithDomain:domain code:1 userInfo:userInfo];
}
@end
