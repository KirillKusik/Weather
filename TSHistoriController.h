//
//  TSHistoriController.h
//  Weather
//
//  Created by Admin on 23.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSDB.h"

@interface TSHistoriController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    NSArray * weatherHistory;
    IBOutlet UITableView *table;
}
//@property NSArray *fruits;
@end
