/*
 ViewController демонстрирующий историю просмотренных прогнозов
 */

#import <UIKit/UIKit.h>


@interface TSHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    
    IBOutlet UITableView *table;
}

@end
