/*
 ViewController демонстрирующий историю просмотренных прогнозов
 */

#import <UIKit/UIKit.h>


@interface TSHistoriViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    
    IBOutlet UITableView *table;
}

@end
