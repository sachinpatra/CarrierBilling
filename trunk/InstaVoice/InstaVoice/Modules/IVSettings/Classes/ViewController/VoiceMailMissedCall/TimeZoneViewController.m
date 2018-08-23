//
//  TimeZoneViewController.m
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 30/06/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "TimeZoneViewController.h"
#import "Common.h"
#import "Profile.h"

@interface TimeZoneViewController (){
    NSMutableArray *knownTimezones;
}

@end

@implementation TimeZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Time Zone", nil);
    self.timeZoneTableView.delegate = self;
    self.timeZoneTableView.dataSource = self;
    knownTimezones = [[NSMutableArray alloc]init];
    [knownTimezones addObjectsFromArray:[NSTimeZone knownTimeZoneNames]];
    [knownTimezones insertObject:@"" atIndex:0];
    // Do any additional setup after loading the view from its nib.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return knownTimezones.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"TimeZone";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    NSString *currentTimeZone = [[NSTimeZone localTimeZone] name];
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    NSString *profileTimeZone = currentUserProfileDetails.emailTimeZone;
    NSInteger indexNumber = 0;
    for (int i = 0; i<[knownTimezones count]; i++) {
        if ([profileTimeZone isEqualToString:[knownTimezones objectAtIndex:i]]) {
            indexNumber = i;
        }
    }
    if(indexPath.row == 0){
        cell.textLabel.text = currentTimeZone;
    }else{
        cell.textLabel.text = [knownTimezones objectAtIndex:indexPath.row];
    }
    
    if (indexPath.row == indexNumber) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else if ([profileTimeZone isEqualToString:currentTimeZone]){
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0) {
        UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
        currentUserProfileDetails.emailTimeZone = [knownTimezones objectAtIndex:indexPath.row];
    }else{
        UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
        currentUserProfileDetails.emailTimeZone = [[NSTimeZone localTimeZone] name];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
