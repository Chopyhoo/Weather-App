//
//  ViewController.m
//  ElilinkWeatherApp
//
//  Created by Alex Sobolevski on 3/13/17.
//  Copyright © 2017 Alex Sobolevski. All rights reserved.
//

#import "WAController.h"
#import "WAModel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *citiesTableView;
@property (strong, nonatomic) WAModel *model;
@property (weak, nonatomic) IBOutlet UIView *descriptionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *citiesTableViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintForExpandedDescription;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintForDefaultDescription;
@property (weak, nonatomic) IBOutlet UILabel *additionalDescriptionLabel;

-(void)expandView:(UITapGestureRecognizer *)tapGestureRecognizer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _model = [[WAModel alloc] init];
    [_model initTableViewData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseDataToUI:) name:@"parseDataNotification" object:nil];
    NSDictionary *data = [_model uncacheData];
    if ([data[@"cache"] isEqualToString:@"No data"])
    {
        [_cityValue setText:@"Choose a city"];
    }
    else {
        [_cityValue setText:data[@"city"]];
        [_weatherValue setText:data[@"weather"]];
        [_temperatureValue setText:data[@"temp"]];
        [_pressureValue setText:data[@"pressure"]];
        [_humidityValue setText:data[@"humidity"]];
        [_additionalDescriptionLabel setText:data[@"weather_description"]];
    }
    UITapGestureRecognizer *expandViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandView:)];
    [_descriptionView addGestureRecognizer:expandViewGestureRecognizer];
}

-(void)expandView:(UITapGestureRecognizer *)tapGestureRecognizer {
    
    CGFloat bufferValue = _citiesTableViewHeight.constant;
    _citiesTableViewHeight.constant = _descriptionViewHeight.constant;
    _descriptionViewHeight.constant = bufferValue;
    
    UILayoutPriority bufferPriority = _constraintForDefaultDescription.priority;
    _constraintForDefaultDescription.priority = _constraintForExpandedDescription.priority;
    _constraintForExpandedDescription.priority = bufferPriority;
    
    [UIView animateWithDuration:1 animations: ^{
        [self.view layoutIfNeeded];
    }];
    
    if (_additionalDescriptionLabel.isHidden)
    {
        _additionalDescriptionLabel.alpha = 0;
        [_additionalDescriptionLabel setHidden:NO];
        [UIView animateWithDuration:1 animations:^{
            self.additionalDescriptionLabel.alpha = 1;
        }];
    }
    else
    {
        _additionalDescriptionLabel.alpha = 1;
        [UIView animateWithDuration:1 animations:^{
            self.additionalDescriptionLabel.alpha = 0;
        }completion:^(BOOL finished) {
            if (finished) {
                [_additionalDescriptionLabel setHidden:YES];
            }
        }
         ];
    }
    
    
}

-(void) parseDataToUI: (NSNotification *) notification {
    NSLog(@"%@", notification);
    [_cityValue setText:[notification object][@"city"]];
    [_weatherValue setText:[notification object][@"weather"]];
    [_temperatureValue setText:[notification object][@"temp"]];
    [_pressureValue setText:[notification object][@"pressure"]];
    [_humidityValue setText:[notification object][@"humidity"]];
    [_additionalDescriptionLabel setText:[notification object][@"weather_description"]];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_model getTableViewLength];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *WATableIdentifier = @"WATableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WATableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:WATableIdentifier];
    }

    cell.textLabel.text = [_model getTableCellName:indexPath.row];
    cell.detailTextLabel.text = [_model getTableCellDetailName:indexPath.row];
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    [_model userTappedOnCell:indexPath.row];
}



@end

