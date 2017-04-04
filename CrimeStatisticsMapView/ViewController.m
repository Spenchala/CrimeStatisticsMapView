//
//  ViewController.m
//  CrimeStatisticsMapView

#import "ViewController.h"
#import "MyMapAnnotation.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mkMapView;
@property (assign,nonatomic) NSUInteger limit;
@property (assign,nonatomic) NSUInteger offSet;
@property (assign,nonatomic) NSUInteger refresh;
@property (assign,nonatomic) double latitude;
@property (assign,nonatomic) double longitude;
@property (assign,nonatomic) BOOL isPageOne;
@property (nonatomic, strong) NSMutableArray *annotationArray;
@property (nonatomic, strong) MyMapAnnotation *annotation;
@property (nonatomic, strong) NSMutableDictionary *districOccurences ;
@property (nonatomic,strong) NSString *pinTitle;
@property (nonatomic,strong) UIColor *pinColor;
@property (nonatomic, strong) NSMutableDictionary *colorSortedDictionary ;
@property (nonatomic, strong) NSMutableArray *colorSortedArray ;
@property (nonatomic, strong) NSMutableArray *finalSortedArray ;
@property (assign,nonatomic) NSUInteger colorIndex;
@property (nonatomic, strong) NSMutableArray *wholeArray ;
@property(nonatomic) BOOL isProcessed;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Crime View Distribution";
    self.wholeArray = [[NSMutableArray alloc]init];
    UIBarButtonItem *refreshMapButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh  target:self action: @selector(refreshMap:)];
    [self.navigationItem setRightBarButtonItem:refreshMapButton animated:YES];
    
    self.isPageOne = YES;
    self.refresh = 0;
    self.mkMapView.delegate = self;
    self.mkMapView.mapType = MKMapTypeStandard;
    self.isProcessed = false;
    [self fetchGeoJsonData];
    self.annotationArray = [NSMutableArray new];
    self.annotation = [[MyMapAnnotation alloc] init];

    
    
    
  
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma private Methods

-(void)fetchGeoJsonData {
    
    if (self.isPageOne) {
        self.offSet = 0;
        self.limit = 100;
    } else {
        self.offSet = self.limit;
        self.limit = self.refresh * 100;
    }
    
    NSInteger n = -3; // n value could be inputted based on user selection for months, if there was such requirement
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:n];
    NSDate *newDate = [calendar dateByAddingComponents:components
                                                toDate:now
                                               options:0];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *s = [df stringFromDate:newDate];
    
    NSString *threeMonthsFromNow = [NSString stringWithFormat:@"%@%@%@",@"'",s,@"'"];
    
    [GeoJSONService getGeoJSONDataforOffset:self.offSet withLimit:self.limit fromDate:threeMonthsFromNow   Withcompletion:^(NSArray *locationsData) {
        if (locationsData) {
            [self.wholeArray addObjectsFromArray:locationsData];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pddistrict" ascending:YES ];
            NSArray *sortedArray = [self.wholeArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            [sortedArray enumerateObjectsUsingBlock:^(Incidents*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                self.annotation = [[MyMapAnnotation alloc] init];
                NSDictionary *locationObject = [[sortedArray objectAtIndex:idx] valueForKey:@"location"];
                
                self.latitude = [locationObject[@"latitude"] doubleValue];
                
                self.longitude = [locationObject[@"longitude"] doubleValue];
                self.annotation.coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
                
                self.annotation.title = [obj valueForKey:@"pddistrict"];
                self.annotation.subtitle = [obj valueForKey:@"category"];
                if(self.districOccurences == nil){
                    self.districOccurences = [[NSMutableDictionary alloc] init];
                }
                NSArray *keys = [self.districOccurences allKeys];
                NSString *key = [obj valueForKey:@"pddistrict"];
                NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:self.annotation, nil];
                if ([keys containsObject:key]) {
                    array = [self.districOccurences valueForKey:key];
                    [array addObject:self.annotation];
                    
                }
                [self.districOccurences setObject:array forKey:key];
            }];
            
            
            NSMutableDictionary *sortedKeysDict = [[NSMutableDictionary alloc] init];
            [self.districOccurences enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSMutableArray*  _Nonnull obj, BOOL * _Nonnull stop) {
                [sortedKeysDict setObject:obj forKey:@([obj count]).stringValue];
            }];
            
            NSArray *sortedKeys = [[sortedKeysDict allKeys] sortedArrayUsingSelector: @selector(compare:)];
            sortedKeys = [sortedKeys sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return obj1 < obj2;
            }];
            
            NSMutableArray *sortedValues = [NSMutableArray array];
            __block CGFloat red = 255/255,green = 0.0,blue = 0.0;
            [sortedKeys enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableArray *array = [sortedKeysDict valueForKey:obj];
                for (int i = 0; i < [array count]; i++) {
                    MyMapAnnotation *annotation = array[i];
                    if(idx == 0){
                        annotation.pinColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
                    }
                    else{
                        if (green == 0) {
                             green=  .12;
                        }
                        annotation.pinColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
                    }
                }
                red = red - .12;
                green= green + .12;
                [sortedValues addObjectsFromArray:array];
            }];
            
            
            [self.mkMapView showAnnotations:sortedValues animated:YES];
            
         }
    }];
}

- (void)refreshMap:(id*)sender {
    self.isPageOne = NO;
    self.refresh ++;
    [self fetchGeoJsonData];
}

#pragma MKMAPVIEW DELEGATE Methods

- (MKPinAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MyMapAnnotation *)annotation
{
    
    if ([annotation isKindOfClass:[MyMapAnnotation class]])
    {
        //  dequeue an existing annotation view.
        MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomAnnotationView"];
        if (!annotationView)
        {
            // If identifier doesn't exist, create one.
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomAnnotationView"];

        }
        
        annotationView.annotation = annotation;
        
 
                annotationView.pinTintColor = annotation.pinColor;
        
        annotationView.canShowCallout = YES;
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}


@end
