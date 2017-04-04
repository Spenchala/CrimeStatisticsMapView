//
//  GeoJSONService.m
//  CrimeStatisticsMapView
 
#import "GeoJSONService.h"

@implementation GeoJSONService

//https://data.sfgov.org/resource/ritf-b9ki.json


+(void)getGeoJSONDataforOffset:(NSInteger) offset withLimit:(NSInteger) limit fromDate:(NSString *)date Withcompletion:(void (^)(NSArray *locationsData))completionHandler {
    
    
    // FIXME: You are not supporting Pagination and requesting data for last month only
    /**
     Please refer to https://dev.socrata.com/docs/paging.html for information about the required parameters
     Also you need to request incidents from three  months ago because the API isn't returning data for 2016
     **/
    NSString *urlString = [NSString stringWithFormat:@"https://data.sfgov.org/resource/ritf-b9ki.json?$limit=%li&$offset=%li&$where=date>=%@",(long)limit,(long)offset,date];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
     [defaultConfigObject setHTTPAdditionalHeaders:@{ @"X-Auth-Token" : @"IqwxgJPJXiiYqhdft0rs3dCbZ" }];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject];
    NSURLSessionDataTask *requestGeoJsonTask =
    [defaultSession dataTaskWithRequest:urlRequest
                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                          if (error == nil) {
                              NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                              
                              if (completionHandler && json) {
                                  completionHandler(json);
                                  
                              }
                          } else {
                              NSLog(@"There is an error with getting GeoJson response: %@", error);
                          }
                          [defaultSession finishTasksAndInvalidate];
                      }];
    
    [requestGeoJsonTask resume];
}



@end
