//
//  CreateNewSingleChatViewController.m
//  InstaVoice
//
//  Created by Kieraj Mumick on 6/26/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "CreateNewSingleChatViewController.h"
#import "IVColors.h"
#import "MyNotesScreen.h"
#import "MyVoboloScreen.h"
#import "ChatGridViewController.h"

@interface CreateNewSingleChatViewController ()

@property (strong, nonatomic) UISegmentedControl *navSegmentedControl;

@end

@implementation CreateNewSingleChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationController.navigationBar.barTintColor = [IVColors redColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    // set up what the navigation controllers should contain in each one of the screens.
    UISegmentedControl *selectWhichTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[[UIImage imageNamed:@"chat-icon-seg"], [UIImage imageNamed:@"new-group-chat"], [UIImage imageNamed:@"new-mobile-chat"]]];
    for (int i = 0; i < selectWhichTypeSegmentedControl.numberOfSegments; i++) {
        [selectWhichTypeSegmentedControl setWidth:70 forSegmentAtIndex:i];
    }
    self.navSegmentedControl = selectWhichTypeSegmentedControl;

    [selectWhichTypeSegmentedControl sendActionsForControlEvents:UIControlEventTouchUpInside];
    [selectWhichTypeSegmentedControl addTarget:self action:@selector(segmentedControlTapped:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = selectWhichTypeSegmentedControl;
    
     UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel-circle"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissThisViewController)];

    self.navigationItem.leftBarButtonItem = cancelButton;

    self.hidesBottomBarWhenPushed = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    [self updateNavigationBarTintColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIStateMachine sharedStateMachineObj]setCurrentPresentedUI:self];
    [super viewWillAppear:animated];
    [self.navSegmentedControl setSelectedSegmentIndex:0];
    self.navigationItem.rightBarButtonItem = nil;
    self.hidesBottomBarWhenPushed = YES;
    self.homeTab = YES;
}

-(void) viewWillDisappear:(BOOL)animated
{
    //OCT 5, 2016 [[UIStateMachine sharedStateMachineObj]setCurrentPresentedUI:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    //DC MEMLEAK MAY 25 2016
    [super viewDidAppear:animated];

    friendTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    //DC MEMLEAK MAY 25 2016
    [super viewDidDisappear:animated];
    KLog(@"viewDidDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentedControlTapped:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    [self.tabBarController setSelectedViewController:[self.tabBarController.viewControllers objectAtIndex:segmentedControl.selectedSegmentIndex]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    // get the navigation controller at the zero-th index of the tab bar controller
    //UINavigationController *chatsNavigationController = (UINavigationController *)[[self.callingTabBarController viewControllers] objectAtIndex:0];

    // set that as the current navigation controller - this sets that navigation stack to be the stack that gets pushed onto
    self.callingTabBarController.selectedIndex = 0;
    
    // then perform the selection process
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
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
