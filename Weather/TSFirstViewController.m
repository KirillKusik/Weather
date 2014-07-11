//
//  TSFirstViewController.m
//  Weather
//
//  Created by Admin on 13.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import "TSFirstViewController.h"

#import "TSDB.h"
//#import "TSMySQLDB.h"
#import "TSYahooWeather.h"
//#import "TSSettings.h"
//#import "TSCoreDataDB.h"

@interface TSFirstViewController ()
@property (nonatomic,weak) IBOutlet UITextField *city;
@property (nonatomic,weak) IBOutlet UITextView *wather;

@end

@implementation TSFirstViewController
@synthesize city,wather;

-(IBAction)testButon:(id)sender{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:@"doneck" forKey:@"city"];
    [dic setValue:@"25" forKey:@"code"];
    [dic setValue:@"07.06.2014" forKey:@"date"];
    [dic setValue:@"20" forKey:@"temp"];
    [dic setValue:@"test" forKey:@"text"];
    
    TSDB *db = [TSDB new];
    
    if ([db addRecordToDatabase:dic]) {
        NSLog(@"data added to the table");
    }
    else{
        NSLog(@"ERROR: %@",db.dbError);
    }
    
}


-(IBAction)getWatherInCity:(id)sender{
    if([self.city.text length] > 0 || [self.city.text isEqualToString:@""] == FALSE){
        [self.view endEditing:YES];
        
        TSYahooWeather *weatherInCity = [TSYahooWeather new];
        NSString *woeid = [[NSString alloc] initWithString:[weatherInCity getWoeid:city.text]];

        if (woeid != nil){
            NSMutableDictionary *weatherDictionary = [[NSMutableDictionary alloc] initWithDictionary:[weatherInCity getWeather:woeid]];
            if(weatherDictionary != nil){
                [weatherDictionary setObject:city.text forKey:@"city"];
                NSString *textWeather = [NSString stringWithFormat:@"City = %@\nDate = %@\nTemp = %@C\nText = %@",[weatherDictionary objectForKey:@"city"],
                    [weatherDictionary objectForKey:@"date"],
                    [weatherDictionary objectForKey:@"temp"],
                    [weatherDictionary objectForKey:@"text"]];
                wather.text = textWeather;
                
                TSDB *db = [TSDB new];
                [db addRecordToDatabase:weatherDictionary];
                NSLog(@"data added to the table");
                
            }
            else
            [self showMasage:@"server not responding weather"];
        }
        else
        [self showMasage:@"WOEID on the city not found"];
        
    }
    else
        [self showMasage:@"Type a city in order to get"];
}

-(void) showMasage:(NSString *) errorString{
    //NSLog(@"%@",parserDelegate.error);
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Input error"
                          message:errorString
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

/*-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        
    }
}*/

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UITapGestureRecognizer *tapToDismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
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

@end
