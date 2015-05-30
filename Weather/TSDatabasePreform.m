/*
 Этот класс основа для классов баз данных.
 
 Здесь объявленны константы с именами полей используемых в бд и методы.
*/

#import "TSDatabasePreform.h"

@implementation TSDatabasePreform

@synthesize error;

//********************************************
//метод генерацыи ошибки
-(void)generateErrorWithDomain:(NSString *)domain
                  ErrorMessage:(NSString *)message
                   Description:(NSString *)description{
    
    NSArray *objArray = [NSArray arrayWithObjects:description, message, nil];
    NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
    error = [NSError errorWithDomain:domain code:1 userInfo:userInfo];
}
@end
