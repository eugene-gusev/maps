//
//  SettingsViewController.m
//  maps
//
//  Created by Eugene Gusev on 15.06.16.
//  Copyright © 2016 Eugene Gusev. All rights reserved.
//

#import "SettingsViewController.h"
#import "AuthHelper.h"
#import "SSKeychain.h"

@interface SettingsViewController ()

@property (strong, nonatomic) UIButton *button;


@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Client", @"Driver", nil]];
    segmentedControl.frame = CGRectMake(100, 20, 120, 30);
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.tintColor = [UIColor blackColor];
    [segmentedControl addTarget:self action:@selector(valueChanged:) forControlEvents: UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    
    UIButton *addProject = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    addProject.frame = CGRectMake(100, 70, 100, 18);
    [addProject setTitle:@"Logout" forState:UIControlStateNormal];
    [addProject addTarget:self action:@selector(logoutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addProject];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)logoutButtonClicked:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:@"userLoggedIn"];
    [userDefaults setObject:nil forKey:@"userHasOrder"];
    [userDefaults setObject:nil forKey:@"userHasRoute"];
    [userDefaults setObject:nil forKey:@"userIsDriver"];
    [SSKeychain deletePasswordForService:@"MapsService" account:@"Auth_Token"];
    [SSKeychain deletePasswordForService:@"MapsService" account:@"Auth_Token_Exiry"];
    [userDefaults synchronize];
    [self.parentViewController performSegueWithIdentifier:@"onlogout" sender:self];
}


- (void)valueChanged:(UISegmentedControl *)segment {
    
    if(segment.selectedSegmentIndex == 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"no" forKey:@"userIsDriver"];
        [userDefaults synchronize];
    }else if(segment.selectedSegmentIndex == 1){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"yes" forKey:@"userIsDriver"];
        [userDefaults synchronize];
    }
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
