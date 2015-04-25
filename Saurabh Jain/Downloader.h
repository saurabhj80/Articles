//
//  Downloader.h
//  Saurabh Jain
//
//  Created by Saurabh Jain on 4/22/15.
//  Copyright (c) 2015 Saurabh Jain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPSessionManager.h>

#define DOWNLOADED_KEY @"sj_downloadedArticles"
#define FAILED_KEY @"sj_fail"

@interface Downloader : NSObject

// Singleton support
+ (instancetype) sharedDownloader;

// Query for articles
- (void) queryForArticles:(NSString*)string;

@end
