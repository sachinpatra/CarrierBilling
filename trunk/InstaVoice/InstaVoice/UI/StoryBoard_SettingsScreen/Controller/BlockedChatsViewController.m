//
//  BlockedChatsViewController.m
//  InstaVoice
//
//  Created by Kieraj Mumick on 8/4/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "BlockedChatsViewController.h"

@interface BlockedChatsViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation BlockedChatsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _displayUserType = 3; //ChatTypeBlocked;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    // set this screen's display type to be the blocked users and then filter the chats
    _displayUserType = 3;//ChatTypeBlocked;
    _currentFilteredList = [cc filterChatsForDisplayType:_displayUserType];

    // get rid of the filter options on the top of the screen, adn set the title to be blocked chats.
    //Sept 2017
//    self.navigationItem.titleView = nil;
//    self.title = NSLocalizedString(@"Blocked Contacts", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    _displayUserType = 3;//ChatTypeBlocked;
    [super viewWillAppear:animated];
    
    if ([self.tableView indexPathForSelectedRow]) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
    
    self.navigationItem.titleView = nil;
    self.title = NSLocalizedString(@"Blocked Contacts", nil);
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    _displayUserType = 2;//ChatTypeAll;
    appDelegate.stateMachineObj.tabIndex = 2;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=0;
    if(0==indexPath.section) {
        // set up a normal, default iOS Table view cell.
        cell = [tableView dequeueReusableCellWithIdentifier:@"blockedConversationCell"];
        
        // if the cell isn't already there, create it with the appropriate identifier.
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"blockedConversationCell"];
        }
        
        // get the object for this cell
        NSMutableDictionary *cellObject = [_currentFilteredList objectAtIndex:indexPath.row];
        
        // put the user's name into the cell
        NSString* remoteUserName = [cellObject valueForKey:REMOTE_USER_NAME];
        //FEB 14, 2017
        NSString *name = [Common setPlusPrefix:remoteUserName];
        if(name != nil) {
            cell.textLabel.text = [Common getFormattedNumber:name withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        } else {
            cell.textLabel.text = remoteUserName;
        }
        //
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //Set the font.
        cell.textLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    else {
        KLog(@"Debug");
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentTile = (int)indexPath.row;
    UITableViewRowAction *unblockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Unblock" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {

        UIButton *btn = [UIButton new];
        btn.tag = 1;

        [self buttonTappedRespond:btn withUniqueIdentifier:@"chatGrid_menuTapped"];

    }];
    return @[unblockAction];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _currentFilteredList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {
    
    [self.tableView reloadData];
}


//Clean Up Methods
- (void)dealloc {
    
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    
}


@end
