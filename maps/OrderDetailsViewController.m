//
//  OrderDetailsViewController.m
//  maps
//
//  Created by Eugene Gusev on 14.06.16.
//  Copyright © 2016 Eugene Gusev. All rights reserved.
//

#import "OrderDetailsViewController.h"
#import "AuthHelper.h"

@import GoogleMaps;
@interface OrderDetailsViewController ()
    @property (strong, nonatomic) IBOutlet UILabel *originLabel;
    @property (strong, nonatomic) UILabel *destinationLabel;
    @property (strong, nonatomic) UILabel *passengersLabel;
    @property (strong, nonatomic) UILabel *arriveLabel;
    @property (strong, nonatomic) UILabel *priceLabel;
    @property (strong, nonatomic) UILabel *originDataLabel;
    @property (strong, nonatomic) UILabel *destinationDataLabel;
    @property (strong, nonatomic) UILabel *passengersDataLabel;
    @property (strong, nonatomic) UILabel *arriveDataLabel;
    @property (strong, nonatomic) UILabel *priceDataLabel;
@end

@implementation OrderDetailsViewController

@synthesize originDataLabel;
@synthesize destinationDataLabel;
@synthesize passengersDataLabel;
@synthesize arriveDataLabel;
@synthesize priceDataLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // NSLog([[[AuthHelper alloc] init] getApiToken]);
    
    _originLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 40)];
    [_originLabel setBackgroundColor:[UIColor clearColor]];
    [_originLabel setText:@"Origin:"];
    [[self view] addSubview:_originLabel];
    
    _destinationLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 200, 40)];
    [_destinationLabel setBackgroundColor:[UIColor clearColor]];
    [_destinationLabel setText:@"Destination:"];
    [[self view] addSubview:_destinationLabel];
    
    _passengersLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 200, 40)];
    [_passengersLabel setBackgroundColor:[UIColor clearColor]];
    [_passengersLabel setText:@"Passengers:"];
    [[self view] addSubview:_passengersLabel];
    
    _arriveLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 200, 40)];
    [_arriveLabel setBackgroundColor:[UIColor clearColor]];
    [_arriveLabel setText:@"A Car will arrive in:"];
    [[self view] addSubview:_arriveLabel];
    
    _priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 200, 40)];
    [_priceLabel setBackgroundColor:[UIColor clearColor]];
    [_priceLabel setText:@"Car number:"];
    [[self view] addSubview:_priceLabel];
    
    originDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 40)];
    [originDataLabel setBackgroundColor:[UIColor clearColor]];
    [originDataLabel setText:@"Updating..."];
    [[self view] addSubview:originDataLabel];
    
    destinationDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 20, 200, 40)];
    [destinationDataLabel setBackgroundColor:[UIColor clearColor]];
    [destinationDataLabel setText:@"Updating..."];
    [[self view] addSubview:destinationDataLabel];
    
    passengersDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 40, 200, 40)];
    [passengersDataLabel setBackgroundColor:[UIColor clearColor]];
    [passengersDataLabel setText:@"Updating..."];
    [[self view] addSubview:passengersDataLabel];
    
    arriveDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 60, 200, 40)];
    [arriveDataLabel setBackgroundColor:[UIColor clearColor]];
    [arriveDataLabel setText:@"Updating..."];
    [[self view] addSubview:arriveDataLabel];
    
    priceDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 80, 200, 40)];
    [priceDataLabel setBackgroundColor:[UIColor clearColor]];
    [priceDataLabel setText:@"Updating..."];
    [[self view] addSubview:priceDataLabel];
    
    if ( [(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"userHasOrder"] isEqual:@"has"]) {
        [self targetMethod];
        [NSTimer scheduledTimerWithTimeInterval:60.0
                                         target:self
                                       selector:@selector(targetMethod)
                                       userInfo:nil
                                        repeats:YES];
    }
    else {
        _originLabel.hidden=true;
        originDataLabel.hidden=true;
        destinationDataLabel.hidden=true;
        passengersDataLabel.hidden=true;
        arriveDataLabel.hidden=true;
        priceDataLabel.hidden=true;
        _destinationLabel.hidden=true;
        _passengersLabel.hidden=true;
        _arriveLabel.hidden=true;
        _priceLabel.hidden=true;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)targetMethod {
    NSString *post = [NSString stringWithFormat:@"token=%@",[[[AuthHelper alloc] init] getApiToken]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://46.101.141.190:2000/getorderinfo?%@",post]]];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([str isEqualToString:@"error"]==false) {
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions  error:&jsonError];
                if (jsonError == nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CLLocationCoordinate2D origin,destination;
                        
                        
                        NSArray *listItems = [(NSString*)[json valueForKey:@"origin"] componentsSeparatedByString:@","];
                        origin.latitude = [listItems.firstObject doubleValue];
                        origin.longitude = [listItems.lastObject doubleValue];
                        
                        NSArray *listItems2 = [(NSString*)[json valueForKey:@"destination"] componentsSeparatedByString:@","];
                        destination.latitude = [listItems2.firstObject doubleValue];
                        destination.longitude = [listItems2.lastObject doubleValue];
                        [[[GMSGeocoder alloc]init]reverseGeocodeCoordinate:origin completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
                            if (error==nil) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    originDataLabel.text = response.results[0].thoroughfare;
                                });
                            }
                            
                        }];
                        [[[GMSGeocoder alloc]init]reverseGeocodeCoordinate:destination completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
                            if (error==nil) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    destinationDataLabel.text = response.results[0].thoroughfare;
                                });
                            }
                            
                        }];
                        //originDataLabel.text = ;
                        destinationDataLabel.text = [json valueForKey:@"destination"];
                        passengersDataLabel.text = [json valueForKey:@"passengers"];
                        arriveDataLabel.text = [json valueForKey:@"time"];
                        priceDataLabel.text = [json valueForKey:@"price"];
                    });
                }

            }
        }
    }];
    [dataTask resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
