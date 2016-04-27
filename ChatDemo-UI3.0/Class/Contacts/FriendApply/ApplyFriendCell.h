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

#import <UIKit/UIKit.h>

@protocol ApplyFriendCellDelegate;

@interface ApplyFriendCell : UITableViewCell

@property (nonatomic) id<ApplyFriendCellDelegate> delegate;

@property (strong, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) UIImageView *headerImageView;//头像,avatar
@property (strong, nonatomic) UILabel *titleLabel;//标题,title
@property (strong, nonatomic) UILabel *contentLabel;//详情,content
@property (strong, nonatomic) UIButton *addButton;//接受按钮,accept button
@property (strong, nonatomic) UIButton *refuseButton;//拒绝按钮,refuse button
@property (strong, nonatomic) UIView *bottomLineView;

+ (CGFloat)heightWithContent:(NSString *)content;

@end

@protocol ApplyFriendCellDelegate <NSObject>

- (void)applyCellAddFriendAtIndexPath:(NSIndexPath *)indexPath;
- (void)applyCellRefuseFriendAtIndexPath:(NSIndexPath *)indexPath;

@end
