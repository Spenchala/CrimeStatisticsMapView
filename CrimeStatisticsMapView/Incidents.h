//
//  Incidents.h
//  CrimeStatisticsMapView
//
//  Copyright © 2017 All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Locations.h"

@interface Incidents : NSObject < NSCoding>

@property (nonatomic, copy) NSString * category;
@property (nonatomic, copy) NSString * pddistrict;
@property (nonatomic, strong) Locations * location;


@end
