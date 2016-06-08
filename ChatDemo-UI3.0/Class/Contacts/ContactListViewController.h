/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "GroupListViewController.h"

@interface ContactListViewController : EaseUsersListViewController

@property (strong, nonatomic) GroupListViewController *groupController;

//When a friend requests a change, updates the number of friends requested
- (void)reloadApplyView;

//When a group requests a change, updates the number of groupview
- (void)reloadGroupView;

//When the number of friends change, refresh the data
- (void)reloadDataSource;

//Add friend's action to be triggered
- (void)addFriendAction;

@end
