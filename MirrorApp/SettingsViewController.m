//
//  SettingsViewController.m
//  MirrorApp
//
//  Created by Suhail Bhat on 14/12/14.
//  Copyright (c) 2014 Suhail Bhat. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *settingsTable;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.settingsTable setFrame:CGRectMake(0, navBar.frame.size.height, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - navBar.frame.size.height)];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
-(void)dismissSelf :(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TableView Delegate & DS

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return @"If you have previously disbabled ads, tap above to restore your purchase.";
        }break;
        case 1:{
            return @"Please review our app, if you like it.";
        }
            break;
        case 2: {
            return @"Please let us know if you encounter any bugsor if there's anything we can do to make MirrorApp a better app.";
        }
            break;
        default:
            return @"";
            break;
    }
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"settingscell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settingscell"];
    }
    switch (indexPath.section) {
        case 0:
        {
            cell.textLabel.text = @"Block Ads";
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"Review App";
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"Feedback";
        }
            break;
        case 3:
        {

            // Create a UICollectionView and Add cells to display apps.
            cell.frame = CGRectMake(0, 0, cell.frame.size.width, 200);

        }
        default:
            break;
    }
    cell.textLabel.textColor = [UIColor blueColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        return 150;
    }
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Go to respective stuff
}

- (IBAction)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
