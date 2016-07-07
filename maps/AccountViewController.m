//
//  AccountViewController.m
//  maps
//
//  Created by Eugene Gusev on 10.06.16.
//  Copyright © 2016 Eugene Gusev. All rights reserved.
//

#import "AccountViewController.h"
#import "OrderDetailsViewController.h"
#import "SettingsViewController.h"


@interface AccountViewController () <UIScrollViewDelegate>
    @property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
    @property (strong, nonatomic) IBOutlet UIView *buttonsContainerView;
    @property UIView *line;
    @property (strong, nonatomic) IBOutlet UIButton *historyButton;
    @property (strong, nonatomic) IBOutlet UIButton *settingsButton;

@property (strong, nonatomic) OrderDetailsViewController * odvc;
@property (strong, nonatomic) SettingsViewController * svc;
@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollView.delegate = self;
    _scrollView.frame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height-50);
    
    float scrollViewHeight = _scrollView.frame.size.height;
    float scrollViewWidth = _scrollView.frame.size.width;
    
    //UIImageView *img1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    //UIImageView *img2 = [[UIImageView alloc]initWithFrame:CGRectMake(scrollViewWidth, 0, scrollViewWidth, scrollViewHeight)];
    _svc = [[SettingsViewController  alloc] init];
    _odvc = [[OrderDetailsViewController alloc]init];
    _odvc.view.frame = CGRectMake(scrollViewWidth, 0, scrollViewWidth, scrollViewHeight);
    _svc.view.frame = CGRectMake(0, 0, scrollViewWidth, scrollViewHeight);
    //odvc.la
    
    _line = [[UIView alloc]initWithFrame:CGRectMake(0, 48,scrollViewWidth/2, 2)];
    _line.backgroundColor = [UIColor blackColor];
    
    [_buttonsContainerView addSubview:_line];
    
    _scrollView.contentSize = CGSizeMake(scrollViewWidth*2, scrollViewHeight);
   
    [self addChildViewController:_odvc];
     [self addChildViewController:_svc];
    [_scrollView addSubview:_odvc.view];
    [_scrollView addSubview:_svc.view];
    [_odvc didMoveToParentViewController:self];
    [_svc didMoveToParentViewController:self];
    [_historyButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}
- (IBAction)scrollByButton:(id)sender {

    if (sender == _historyButton) {
        [_scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
    }
    else {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
  //  NSLog(@"%f",scrollView.contentOffset.x);
    _line.frame = CGRectMake(scrollView.contentOffset.x / 2, 48, (self.view.frame.size.width / 2)+5, 2);
    if (scrollView.contentOffset.x > 160) {
        [_historyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_settingsButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else {
        [_historyButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_settingsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
