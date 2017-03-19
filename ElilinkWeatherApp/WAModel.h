//
//  WAModel.h
//  ElilinkWeatherApp
//
//  Created by Alex Sobolevski on 3/16/17.
//  Copyright © 2017 Alex Sobolevski. All rights reserved.
//

#import "WAController.h"
#import <Foundation/Foundation.h>


@interface WAModel : NSObject

-(void) initTableViewData;

-(NSUInteger)getTableViewLength;

-(NSString *)getTableCellName: (NSInteger)index;

-(NSString *)getTableCellDetailName: (NSInteger)index;

-(void)userTappedOnCell:  (NSInteger)index;

-(NSDictionary *)uncacheData;
@end
