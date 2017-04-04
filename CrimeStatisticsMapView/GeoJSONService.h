//
//  GeoJSONService.h
//  CrimeStatisticsMapView
//
 
#import <Foundation/Foundation.h>

@interface GeoJSONService : NSObject
+(void)getGeoJSONDataforOffset:(NSInteger) offset withLimit:(NSInteger) limit fromDate:(NSString *)date Withcompletion:(void (^)(NSArray *locationsData))completionHandler;
@end
