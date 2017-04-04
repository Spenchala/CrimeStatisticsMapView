//
//  Incidents.m
//  CrimeStatisticsMapView
//
//  Copyright © 2017 All rights reserved.
//

#import "Incidents.h"

@implementation Incidents

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _category = [aDecoder decodeObjectForKey:@"category"];
        _pddistrict = [aDecoder decodeObjectForKey:@"pddistrict"];
        _location = [aDecoder decodeObjectForKey:@"location"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.category forKey:@"category"];
    [aCoder encodeObject:self.pddistrict forKey:@"pddistrict"];
    [aCoder encodeObject:self.location forKey:@"location"];
    
}

@end
