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

#import <Foundation/Foundation.h>

typedef void (^RealtimeSearchResultsBlock)(NSArray *results);

@interface RealtimeSearchUtil : NSObject

/**
 *  Whether continuous search or not, the default YES (to search for the string as a whole)
 */
@property (nonatomic) BOOL asWholeSearch;

/*!
 *  the entity for the search
 *
 *  @return the entity
 */
+ (instancetype)currentUtil;

/*!
 *  start to search,with realtimeSearchStop to use
 *
 *  @param source      the source for search
 *  @param searchText  the text for search
 *  @param selector    Method for obtaining a field to be compared in an element
 *  @param resultBlock the callback,get result
 */
- (void)realtimeSearchWithSource:(id)source searchText:(NSString *)searchText collationStringSelector:(SEL)selector resultBlock:(RealtimeSearchResultsBlock)resultBlock;

/*!
 *  Does the search from fromString contain searchString
 *
 *  @param searchString The string to search
 *  @param fromString   From which string search
 *
 *  @return whether contain searchString or not
 */
- (BOOL)realtimeSearchString:(NSString *)searchString fromString:(NSString *)fromString;

/*!
 * The end of the search, only need to call once, in [realtimeSearchBegin...:] after the use, mainly for release the resources
 */
- (void)realtimeSearchStop;

@end
