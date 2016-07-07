//
//  SignInViewController.m
//  maps
//
//  Created by Eugene Gusev on 11.06.16.
//  Copyright © 2016 Eugene Gusev. All rights reserved.
//

#import "SignInViewController.h"
#import "AuthHelper.h"

@interface SignInViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *logoTopConsraint;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _usernameTextField.delegate = self;
    _passwordTextField.delegate = self;
   }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showErrorMessageWithText:(NSString*)message {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Error"
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

-(IBAction)loginAction:(id)sender {
    if (_passwordTextField.text.length==0 || _usernameTextField.text.length==0) {
        [self showErrorMessageWithText:@"Some of the required parameters are missing"];
    }
    //create user action
    
    //login user action
    NSString *post = [NSString stringWithFormat:@"username=%@&password=%@",_usernameTextField.text,_passwordTextField.text];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://46.101.141.190:2000/?%@",post]]];//46.101.141.190
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
                    AuthHelper* helper = [[AuthHelper alloc]init];
                    [helper saveApiTokenInKeychainWithDictionary:json];
                    [helper updateUserLoggedInFlag];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performSegueWithIdentifier:@"LoggedIn" sender:self];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showErrorMessageWithText:@"Try again"];
                    });
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showErrorMessageWithText:@"Uncorrect data"];
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showErrorMessageWithText:@"Cannot connect to server"];
            });
        }
        
    }];
    [dataTask resume];

    
}

-(void)viewDidAppear:(BOOL)animated {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userLoggedIn"]!=nil) {
        [self performSegueWithIdentifier:@"LoggedIn" sender:self];
    }
    else {
        [UIView animateWithDuration:0.75 animations:^{
            _logoTopConsraint.constant = -100;
            _usernameTextField.hidden = NO;
            _passwordTextField.hidden = NO;
            _signInButton.hidden = NO;
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
