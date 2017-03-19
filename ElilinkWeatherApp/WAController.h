//
//  ViewController.h
//  ElilinkWeatherApp
//
//  Created by Alex Sobolevski on 3/13/17.
//  Copyright © 2017 Alex Sobolevski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *cityValue;
@property (weak, nonatomic) IBOutlet UILabel *weatherValue;
@property (weak, nonatomic) IBOutlet UILabel *temperatureValue;
@property (weak, nonatomic) IBOutlet UILabel *pressureValue;
@property (weak, nonatomic) IBOutlet UILabel *humidityValue;

@end

