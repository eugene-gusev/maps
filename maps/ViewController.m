//
//  ViewController.m
//  maps
//
//  Created by Eugene Gusev on 08.05.16.
//  Copyright © 2016 Eugene Gusev. All rights reserved.
//

#import "ViewController.h"
#import "SignInViewController.h"
#import "AuthHelper.h"
@import GoogleMaps;

@interface ViewController () <GMSMapViewDelegate,CLLocationManagerDelegate, UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>
    @property GMSMapView *mapView_;
    @property GMSMarker * markerFrom;
    @property GMSMarker * markerTo;
    @property GMSPlacesClient * placesClient;
    @property CLLocationManager *locationManager;
    @property (strong, nonatomic) IBOutlet UIView *contentView;
    @property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
    @property (strong, nonatomic) IBOutlet UILabel *labelA;
    @property (strong, nonatomic) IBOutlet UILabel *labelB;
    @property (strong, nonatomic) IBOutlet UITextField *addressFrom;
    @property (strong, nonatomic) IBOutlet UITextField *addressTo;
    @property (strong, nonatomic) IBOutlet UITextField *passengers;
    @property (strong, nonatomic) UITextField *activeTextField;
    @property (strong, nonatomic) IBOutlet UIButton *makeOrderButton;
    @property (strong, nonatomic) IBOutlet UILabel *timeLabel;
    @property (strong, nonatomic) IBOutlet UITextField *timeTextField;
@property NSTimer *pathfinder;
@property GMSPolyline *polyline;
@property NSString * path;
    @property UITableView *autocomplete;
    @property NSMutableArray *addresses;
    @property NSArray *passengersData;
    @property CLLocation *currentLocation;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    _placesClient = [[GMSPlacesClient alloc] init];
    
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.dataSource = self;
    picker.delegate = self;
    _passengers.inputView = picker;
    _passengersData = @[@"1",@"2",@"3",@"4"];
    
    _autocomplete = [[UITableView alloc] initWithFrame:CGRectMake(0,0,10,10) style:UITableViewStylePlain];
    _autocomplete.delegate = self;
    _autocomplete.dataSource = self;
    _autocomplete.scrollEnabled = YES;
    _autocomplete.hidden = YES;
    
    _activeTextField = [[UITextField alloc] init];
    _addresses = [[NSMutableArray alloc] init];
    
    _addressTo.delegate = self;
    _addressFrom.delegate = self;
    //круглые лэйблы А В
    
    _labelA.layer.borderWidth =1;
    _labelA.layer.borderColor = [[UIColor blackColor] CGColor];
    _labelA.layer.cornerRadius = 14;
    _labelB.layer.borderWidth =1;
    _labelB.layer.borderColor = [[UIColor blackColor] CGColor];
    _labelB.layer.cornerRadius = 14;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:56.2952
                                                            longitude:43.9451
                                                                 zoom:10];
    self.mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 105, self.view.frame.size.width, 415) camera:camera];
    self.mapView_.myLocationEnabled = YES;
    
    [self CurrentLocationIdentifier];
    
    self.mapView_.delegate = self;
    self.mapView_.settings.myLocationButton = YES;
    
    //GMSMutablePath *path = [GMSMutablePath pathFromEncodedPath:@"qyevIsnhkGaB_DS[OGWHoE`LaHfP_@bAq@kAwEwI{AmC}BgEqBkEkDyHa@{@kEuJiAqBoAcBe@i@eA}@gAs@uAo@}FyB{LuEqNsFgZeLcEeBq@]aAiAcAq@mCaAsCYq@[KYG]A]@YZ]j@q@Zw@Fi@Dy@Jk@f@iEFsAAmAs@gMUcCiBcOg@yFa@sFI{B@sAp@yKNaDCa@oC}Me@{CEm@@gAN_BtA{F^wARe@r@kAfAmAVUCOUyA_BeIoAwGy@qD{@qCu@mCqCuNkC_NUuAC_@Jg@dJmRJ]Ba@A]Og@mCmGJq@Bu@Cc@_CgJkEgQgDmNcB_HiAwDuAmDkA{B_BkBwAaAeBi@eC]uJKeICqGMu@IaAS_AWqAi@eBmAo@k@oAyAmBqCkBgD_AkBuF{KsJaRoD}FwBsCiAiAe@s@qA_AyA{@uB{@uCk@qBSiDIw@?}BLiGJuE?eIF_BAiCDqDEaEKeCLqAVk@RyDtAcH`CiH`CiBt@INa@JJAJDh@\\NLPxBj@|H^~F~Bj\\|Evq@xHhfApBvXpCr_@P|CBvAk@nNgDvy@KvB?Rk@nA_@p@OE~@V_AWsDaAgTqFwA]_BOgAG{FUeEQaLk@qHQsCIaAKoFcAyE_A{FoAmCm@IQOMq@U}@m@SOg@u@[g@gBqB{CcDy@kA_AkAqBsBg@c@CQ]oCEw@E_@MUwAgBwDgFs@c@U@KEMB_AZE@q@g@mAmAqA{ACpECdNGbAyAnMCVq@]u@]aFaCcJiEwGqCgHmCiHmCw@]OGGJLm@b@qC`AcFx@yC~BmGfB{DAe@Ca@c@[UQ]U}@[uA[uBOoAE_@?_@JI?GHIJ}B`Cy@dAcAbAgCvBg@TYDu@AkBk@i@Ms@@mAVy@RyEzAcAwLUaFU}Ic@cNIuDO}KHwEZcHRaDDeA?{BSiOEuBDqC|@qLVuDp@sOb@aH^iD^kBf@_Bf@}Ab@aBb@gBbEeMtGsQxDqK|DaLlByF\\s@HGR@dAt@`BrAzBlBVLrAJvCcWpAuK\\iDDaBCuE?iEZqHhCca@bA}NTaCp@wHf@iDh@oBzAmIbDmYdAsJ^uChAsEhB{GfAqCjAcCz@yAp@}@bBkBzAkAxAw@z@i@bA{@nBqBnA}A|GiJ`HoJ`ImLxAcBpAgAfAq@f@UTI|Ae@hAUxCSvEMpKW`DElB@dAH~B`@jBr@rBdBzMrMbGfExCjBt@d@jAf@bATh@BT?lBMnCYtCWxCa@nAWbDaArEiB?uH?kHl@@?SF[dE}Ir@_BqBiFG?CA"];
    GMSMutablePath *path = [GMSMutablePath pathFromEncodedPath:@"{|svIeztkGa@GQKIOOo@GWMMUIQCk@SLu@LeBLkCJk@Pw@b@iBJm@HaBJg@L]`@q@zDuE`G_HpBwBLSCIw@_FMkAdCsCvA{AlAyAf@_@xAm@~As@bHcCnBk@^Of@IzBc@`@Rb@\\p@zI`@hGh@xHnEfn@nApQpBdXpB|YbCv\\jAdPx@zKrAtQ^xFJfB@p@jEr@`Cf@dAPlGpAjEv@rKpBbEx@jB`@rCd@rE|@VHVR`AlAfBvC|CrE~@dA\\XXLh@LxDt@vAVlE|@NBFUDQBGnEuDnDuC~BoB~D}CrEqD|TuQdCqBdBoAfHuFnFiEjDuCdB}C~@kBlBaElCsFlAgCpAkCTQRKBTTtAbAhFfClM~AhIbBrFx@pD|@~EhAvF|@~EBNWTgAlAs@jASd@_@vAu@zC_@~AKz@EdADrAd@zCh@pC`BtHFf@AVSvEi@hIAb@A`A@v@\\~EX~DXpCbAlIl@`FLvAd@vHLnC@lAGrAYhCYjBMbBI\\QXk@p@i@f@STM\\CHfAf@p@ZtCfCdAb@pAV|AXZE^PhCjAnJpD|XtKtZhL~@^vBfAdAv@~@~@n@v@jAhBbAtBfBzDvDrIzAbD`BeElBwEvBiFx@hBfBjDR`@X|@Z~@^h@LNHBtDbHtBhE~A_EnBaFRID?HDNLxArC"];
     _polyline = [GMSPolyline polylineWithPath:path];
   // test.strokeColor = [UIColor greenColor];
    
    
    
    [self.contentView addSubview:self.mapView_];
   

    _polyline = [GMSPolyline polylineWithPath:path];
  
   // _polyline.map = self.mapView_;
 
    
      [self.view addSubview:_autocomplete];
    
    if ( [(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"userIsDriver"] isEqual:@"yes"]) {
        [self driver];
    }
    else {
        [self client];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(change)
                                   userInfo:nil
                                    repeats:YES];
    
    _pathfinder = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                   target:self
                                                 selector:@selector(targetMethod)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)change {
    if ( [(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"userIsDriver"] isEqual:@"yes"]) {
        [self driver];
    }
    else {
        [self client];
    }
}

-(void)driver {
    [_makeOrderButton setTitle:@"Create route" forState:UIControlStateNormal];
    [_makeOrderButton addTarget:self action:@selector(createRoute:) forControlEvents:UIControlEventTouchUpInside];
    //[self targetMethod];
 
    
    
    _timeLabel.hidden = false;
    _timeTextField.hidden = false;
}

-(void)client {
    _polyline.map = nil;
    _timeLabel.hidden = true;
    _timeTextField.hidden = true;
    [_makeOrderButton setTitle:@"Make order" forState:UIControlStateNormal];
    [_makeOrderButton addTarget:self action:@selector(makeOrder:) forControlEvents:UIControlEventTouchUpInside];
    
}


#pragma mark - USER LOCATION

-(void)CurrentLocationIdentifier
{
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

//получение текущей локации и перевод карты на неё
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations objectAtIndex:0];
    [self.locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
            // CLLocation *a =placemark.location;
             self.currentLocation = placemark.location;
             
             GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude
                                                                     longitude:self.currentLocation.coordinate.longitude
                                                                          zoom:14];
             NSLog(@"current: %f, %f",self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
             self.mapView_.camera = camera;
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
         }
     }];
}

#pragma mark - MARKERS

-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Добавление точки"
                                                                   message:@"Построить маршрут:"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* actionFrom = [UIAlertAction actionWithTitle:@"Отсюда"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self moveMarker:@"from" Coordinate:coordinate];
                                                           [self onMarker:@"from" MoveToCoordinate:coordinate];
                                                       }];
    UIAlertAction* actionTo = [UIAlertAction actionWithTitle:@"Сюда"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                          [self moveMarker:@"to" Coordinate:coordinate];
                                                          [self onMarker:@"to" MoveToCoordinate:coordinate];
                                                     }];
    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Отмена"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:actionFrom];
    [alert addAction:actionTo];
    [alert addAction:actionCancel];
    [self presentViewController:alert animated:YES completion:nil];
    [self sendRoute];
}

-(IBAction)changeTextFields:(id)sender {
    if (_markerTo == nil) {
        _markerTo = [[GMSMarker alloc] init];
        _markerTo.title = @"Cюда";
        _markerTo.map = _mapView_;
    }
    if (_markerFrom == nil) {
        _markerFrom = [[GMSMarker alloc] init];
        _markerFrom.title = @"Отсюда";
        _markerFrom.map = _mapView_;
        _markerFrom.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    }
    CLLocationCoordinate2D bufCoordinate = _markerFrom.position;
    _markerFrom.position = _markerTo.position;
    _markerTo.position = bufCoordinate;
    NSString *bufString = _addressFrom.text;
    _addressFrom.text = _addressTo.text;
    _addressTo.text = bufString;
}

- (void) mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    marker.snippet = [NSString stringWithFormat:@"%f,%f",marker.position.latitude,marker.position.longitude];
    if (marker == _markerTo) {
        [self onMarker:@"to" MoveToCoordinate:marker.position];
    }
    else {
        [self onMarker:@"from" MoveToCoordinate:marker.position];
    }
}

-(void) onMarker:(NSString*)marker MoveToCoordinate:(CLLocationCoordinate2D)coordinate {
    [[[GMSGeocoder alloc]init]reverseGeocodeCoordinate:coordinate completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
        if ([marker  isEqual: @"to"]) {
            _addressTo.text = response.results[0].thoroughfare;
        }
        else {
            _addressFrom.text = response.results[0].thoroughfare;
        }
    }];
}

-(void)moveMarker:(NSString *)marker Coordinate:(CLLocationCoordinate2D)coordinate {
    if ([marker  isEqual: @"to"]) {
        if (self.markerTo==nil) {
            self.markerTo = [[GMSMarker alloc] init];
        }
        self.markerTo.position = coordinate;
        self.markerTo.title = @"Cюда";
        self.markerTo.snippet = [NSString stringWithFormat:@"%f,%f",coordinate.latitude,coordinate.longitude];
        self.markerTo.map = self.mapView_;
        self.markerTo.draggable = YES;
    }
    else {
        if (self.markerFrom==nil) {
            self.markerFrom = [[GMSMarker alloc] init];
        }
        self.markerFrom.position = coordinate;
        self.markerFrom.title = @"Отсюда";
        self.markerFrom.snippet = [NSString stringWithFormat:@"%f,%f",coordinate.latitude,coordinate.longitude];
        self.markerFrom.map = self.mapView_;
        self.markerFrom.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        self.markerTo.draggable = YES;
    }
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:15];
    
    self.mapView_.camera = camera;
}

#pragma mark - TABLEVIEW

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
   
    return [self.addresses count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_addresses count]>0) {
        _activeTextField.text = [[_addresses[indexPath.row] attributedPrimaryText ]string];
        [_placesClient lookUpPlaceID:[_addresses[indexPath.row] placeID] callback:^(GMSPlace *place, NSError *error) {
            if (error != nil) {
                NSLog(@"Place Details error %@", [error localizedDescription]);
                return;
            }
                
            if (place != nil) {
                if (_activeTextField == _addressTo) {
                    [self moveMarker:@"to" Coordinate:place.coordinate];
                }
                else {
                    [self moveMarker:@"from" Coordinate:place.coordinate];
                }
            }
        }];
        
        _autocomplete.hidden = YES;
    }
}

-(UITableViewCell*)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    cell.textLabel.font=[UIFont fontWithName:@"Arial" size:10];
    cell.textLabel.text = [[_addresses[indexPath.row] attributedPrimaryText ]string];
    return cell;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *substring = [NSString stringWithString:textField.text];
    textField.textColor = [UIColor blackColor];
    substring = [substring
                 stringByReplacingCharactersInRange:range withString:string];
    if ([substring length]>3) {
        _activeTextField = textField;
        _autocomplete.frame = CGRectMake(textField.frame.origin.x, textField.frame.origin.y+textField.frame.size.height,textField.frame.size.width, 120);
        [self searchAutocompleteEntriesWithSubstring:substring];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _autocomplete.hidden = YES;
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
        [_addresses removeAllObjects];
    
        GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
        filter.type = kGMSPlacesAutocompleteTypeFilterNoFilter;
        CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake(56.363314, 43.869177);
        CLLocationCoordinate2D coord2 = CLLocationCoordinate2DMake(56.155942, 44.096868);
                [_placesClient autocompleteQuery:substring
                                  bounds:[[GMSCoordinateBounds alloc] initWithCoordinate:coord1 coordinate:coord2]
                                  filter:filter
                                callback:^(NSArray *results, NSError *error) {
                                    if (error != nil) {
                                        NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                        return;
                                    }
                                    if (results.count > 0) {
                                        for (GMSAutocompletePrediction* result in results) {
                                            if ([result.attributedFullText.string containsString:@"Нижний Новгород"]) {
                                                [_addresses addObject:result];
                                            }
                                        }
                                        _autocomplete.hidden = NO;
                                    }
                                    if (_addresses.count==0) {
                                        _activeTextField.textColor = [UIColor redColor];
                                    }
                                    [_autocomplete reloadData];
                                }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /*CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             // CLLocation *a =placemark.location;
             self.currentLocation = placemark.location;
             
             GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude
                                                                     longitude:self.currentLocation.coordinate.longitude
                                                                          zoom:14];
             
             self.mapView_.camera = camera;
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
         }
     }];
*/
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - PICKER VIEW

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _passengersData.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _passengersData[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _passengers.text = _passengersData[row];
    [_passengers resignFirstResponder];
}

#pragma mark - ROUTING

-(void)sendRoute {
    if (_markerTo != nil && _markerFrom != nil) {
        NSString *post = [NSString stringWithFormat:@"origin=%f,%f&destination=%f,%f&passengers=%@&token=%@",self.markerFrom.position.latitude,self.markerFrom.position.longitude,self.markerTo.position.latitude,self.markerTo.position.longitude,_passengers.text,[[[AuthHelper alloc] init] getApiToken]];
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://46.101.141.190:2000/neworder?%@",post]]];
        request.HTTPMethod = @"GET";
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error == nil) {
                 NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if ([str isEqualToString:@"error"]==false) {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:@"has" forKey:@"userHasOrder"];
                    [userDefaults synchronize];
                    
                }
                else {
                    _makeOrderButton.hidden = false;
                }
            }
            else {
                _makeOrderButton.hidden = false;
            }
        }];
        [dataTask resume];
    }
    else {
        _makeOrderButton.hidden = false;
    }
}

-(IBAction)makeOrder:(id)sender {
    [self sendRoute];
    _makeOrderButton.hidden = true;
}

-(IBAction)createRoute:(id)sender {
  //  [self makeRoute];
    _makeOrderButton.hidden = true;
    if (_markerTo != nil && _markerFrom != nil) {
        NSString *post = [NSString stringWithFormat:@"origin=%f,%f&destination=%f,%f&seats=%@&token=%@&drivermode=oneway&maxtime=60",self.markerFrom.position.latitude,self.markerFrom.position.longitude,self.markerTo.position.latitude,self.markerTo.position.longitude,_passengers.text,[[[AuthHelper alloc] init] getApiToken]];
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://46.101.141.190:2000/createroute?%@",post]]];
        request.HTTPMethod = @"GET";
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error == nil) {
                NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if ([str isEqualToString:@"error"]==false) {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:@"has" forKey:@"userHasRoute"];
                    [userDefaults synchronize];
                    
                   
                    
                }
                else {
                    _makeOrderButton.hidden = false;
                }
            }
            else {
                _makeOrderButton.hidden = false;
            }
        }];
        [dataTask resume];
    }
    else {
        _makeOrderButton.hidden = false;
    }
}

-(void)targetMethod {
    NSString *post = [NSString stringWithFormat:@"token=%@",[[[AuthHelper alloc] init] getApiToken]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://46.101.141.190:2000/getrouteinfo?%@",post]]];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([str isEqualToString:@"error"]==false) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _polyline.map = nil;
                    GMSMutablePath *path = [GMSMutablePath pathFromEncodedPath:str];
                    _polyline = [GMSPolyline polylineWithPath:path];
                    _polyline.map = self.mapView_;
                });
                //test.map = self.mapView_;
            }
        }
    }];
    [dataTask resume];
}


    @end

