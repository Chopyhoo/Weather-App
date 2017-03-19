//
//  WAModel.m
//  ElilinkWeatherApp
//
//  Created by Alex Sobolevski on 3/16/17.
//  Copyright © 2017 Alex Sobolevski. All rights reserved.
//

#import "WAModel.h"
#import "WAController.h"
#import <CoreData/CoreData.h>

@implementation WAModel


NSArray *cities;

-(void) initTableViewData {
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"cities" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSDictionary* citiesDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    cities = [NSArray arrayWithObjects:[citiesDict allValues], nil];
}

-(NSUInteger)getTableViewLength {
    
    NSUInteger length = [cities[0] count];
    return length;
    
}

-(void)cacheData: (NSDictionary *)data {
    
    NSError *error = nil;
    NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:@"ElilinkWeatherApp"];
    [container loadPersistentStoresWithCompletionHandler:
     ^(NSPersistentStoreDescription *storeDescription, NSError *error) {
         if (error != nil) {
             NSLog(@"Failed to load store: %@", error);
             abort();
         }
     }];
    NSManagedObjectContext *context = [container newBackgroundContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Cache"];
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching cache objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    NSManagedObject *cache;
    @try {
        cache = [results objectAtIndex:0];
        [cache setValue:data[@"city"] forKey:@"cityCache"];
        [cache setValue:data[@"weather"]  forKey:@"weatherCache"];
        [cache setValue:data[@"weather_description"]  forKey:@"descriptionCache"];
        [cache setValue:data[@"temp"]  forKey:@"tempCache"];
        [cache setValue:data[@"pressure"]  forKey:@"pressureCache"];
        [cache setValue:data[@"humidity"]  forKey:@"humidityCache"];
    }
    @catch (NSException* e)
    {
        cache = [NSEntityDescription insertNewObjectForEntityForName:@"Cache" inManagedObjectContext:context];
        [cache setValue:data[@"city"] forKey:@"cityCache"];
        [cache setValue:data[@"weather"]  forKey:@"weatherCache"];
        [cache setValue:data[@"weather_description"]  forKey:@"descriptionCache"];
        [cache setValue:data[@"temp"]  forKey:@"tempCache"];
        [cache setValue:data[@"pressure"]  forKey:@"pressureCache"];
        [cache setValue:data[@"humidity"]  forKey:@"humidityCache"];
    }
    NSLog(@"%@", cache);
    if ([context save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

-(NSDictionary *)uncacheData {
    
    NSError *error = nil;
    NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:@"ElilinkWeatherApp"];
    [container loadPersistentStoresWithCompletionHandler:
     ^(NSPersistentStoreDescription *storeDescription, NSError *error) {
         if (error != nil) {
             NSLog(@"Failed to load store: %@", error);
             abort();
         }
     }];
    NSManagedObjectContext *context = [container newBackgroundContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Cache"];
    NSArray *results = [context executeFetchRequest:request error:&error];
    NSLog(@"%@", results);
    if (!results) {
        NSLog(@"Error fetching cache objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    NSManagedObject *cache;
    @try {
        cache = [results objectAtIndex:0];
    }
    @catch (NSException* e)
    {
        return [NSDictionary dictionaryWithObject:@"No data" forKey:@"cache"];
    }
    NSLog(@"%@", cache);
    return [NSDictionary dictionaryWithObjectsAndKeys:[cache valueForKey:@"cityCache"], @"city", [cache valueForKey:@"weatherCache"], @"weather", [cache valueForKey:@"tempCache"], @"temp", [cache valueForKey:@"pressureCache"], @"pressure", [cache valueForKey:@"humidityCache"], @"humidity", [cache valueForKey:@"descriptionCache"], @"weather_description", nil];
}

-(NSString *)getTableCellName: (NSInteger)index {
    return [cities[0][index] valueForKey:@"name"];
}

-(NSString *)getTableCellDetailName: (NSInteger)index {
    return [cities[0][index] valueForKey:@"code"];
}

-(void)userTappedOnCell:(NSInteger)index {
    
    NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:@"ElilinkWeatherApp"];
    [container loadPersistentStoresWithCompletionHandler:
     ^(NSPersistentStoreDescription *storeDescription, NSError *error) {
         if (error != nil) {
             NSLog(@"Failed to load store: %@", error);
             abort();
         }
     }];
    NSError *error = nil;
    NSManagedObjectContext *context = [container newBackgroundContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Weather"];
    NSString *cityName = [cities[0][index] valueForKey:@"name"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"city==%@", cityName];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching Employee objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    NSManagedObject *weather;
    @try {
        weather = [results objectAtIndex:0];
    }
    @catch (NSException* e)
    {
        weather = [NSEntityDescription insertNewObjectForEntityForName:@"Weather" inManagedObjectContext:context];
        [weather setValue:[[NSDate date] dateByAddingTimeInterval:-3601] forKey:@"date"];
    }
    NSLog(@"%f", [[NSDate date] timeIntervalSinceDate:[weather valueForKey:@"date"]]);
    if ([[NSDate date] timeIntervalSinceDate:[weather valueForKey:@"date"]] > 3600) {
        
        NSString *city = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?id=%@&appid=78c493c54523b7892d2a8d5f97adb891", [cities[0][index] valueForKey:@"id"]];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:city]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    NSDictionary *allData = [ NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                    
                    NSString *city = [allData valueForKey:@"name"];
                    NSString *idCity = [NSString stringWithFormat:@"%@",[allData valueForKey:@"id"]];
                    NSString *weatherAttr = [[allData valueForKey:@"weather"][0] valueForKey:@"main"];
                    NSString *weatherDescription = [[allData valueForKey:@"weather"][0] valueForKey:@"description"];
                    NSString *temperature = [NSString stringWithFormat:@"%@", [allData[@"main"] valueForKey:@"temp"]];
                    double buffTemp = [temperature doubleValue] - 273;
                    temperature = [NSString stringWithFormat:@"%.2f", buffTemp];
                    NSString *pressure = [NSString stringWithFormat:@"%@", [allData[@"main"] valueForKey:@"pressure"]];
                    NSString *humidity = [NSString stringWithFormat:@"%@", [allData[@"main"] valueForKey:@"humidity"]];
                    
                    [weather setValue:city forKey:@"city"];
                    [weather setValue:idCity forKey:@"id_city"];
                    [weather setValue:weatherAttr forKey:@"weather"];
                    [weather setValue:weatherDescription forKey:@"weather_description"];
                    [weather setValue:temperature forKey:@"temp"];
                    [weather setValue:pressure forKey:@"pressure"];
                    [weather setValue:humidity forKey:@"humidity"];
                    [weather setValue:[NSDate date] forKey:@"date"];
                    
                    if ([context save:&error] == NO) {
                        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
                    }
                    
                    NSDictionary *weatherData = [NSDictionary dictionaryWithObjectsAndKeys:[weather valueForKey:@"city"], @"city", [weather valueForKey:@"weather"], @"weather", [weather valueForKey:@"temp"], @"temp", [weather valueForKey:@"pressure"], @"pressure", [weather valueForKey:@"humidity"], @"humidity", [weather valueForKey:@"weather_description"], @"weather_description", nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"parseDataNotification" object:weatherData];
                        [self cacheData:weatherData];
                    });
                }] resume];
    }
    else {
        NSDictionary *weatherData = [NSDictionary dictionaryWithObjectsAndKeys:[weather valueForKey:@"city"], @"city", [weather valueForKey:@"weather"], @"weather", [weather valueForKey:@"temp"], @"temp", [weather valueForKey:@"pressure"], @"pressure", [weather valueForKey:@"humidity"], @"humidity", [weather valueForKey:@"weather_description"], @"weather_description", nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"parseDataNotification" object:weatherData];
            [self cacheData:weatherData];
        });
    }
    NSLog(@"%@", weather);
    
}

@end
