//
//  Downloader.m
//  Saurabh Jain
//
//  Created by Saurabh Jain on 4/22/15.
//  Copyright (c) 2015 Saurabh Jain. All rights reserved.
//

#import "Downloader.h"

@interface Downloader ()

// Download the articles
- (void) downloadContent:(NSString *)str andType:(SJArticleType)type;

#define APIKEY @"02345b4316532bcd5264fdcf5e71db45:10:71928127"
#define MOSTPOPULAR_APIKEY @"905b390fe5812800b014c6baccbdc990:2:71928127"

@end

@implementation Downloader

+ (instancetype) sharedDownloader {
    
    static dispatch_once_t once;
    static Downloader* sharedDownloader = nil;
    dispatch_once(&once, ^{
        if (!sharedDownloader) {
            sharedDownloader = [[self alloc] init];
        }
    });
    
    return sharedDownloader;
}

- (void) queryForArticles:(NSString*)string andType:(SJArticleType)type;
{
    [self downloadContent:string andType:type];
}

#pragma mark - 
#pragma mark - Helper Method

- (void) downloadContent:(NSString *)str andType:(SJArticleType)type{
    
    // The Manager
    AFHTTPSessionManager* manager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    // The endpoint
    NSString* initialString = [NSString stringWithFormat:@"http://api.nytimes.com/svc/search/v2/articlesearch.json?q=%@&sort=newest&fl=web_url", str];
    NSString* finalString = [@"%2Csnippet%2Clead_paragraph%2Cheadline&api-key=" stringByAppendingString:APIKEY];
    
    NSString* apiEndPoint = nil;
    
    // Check the type
    if (type == SJArticleTypeSearch)
        apiEndPoint = [initialString stringByAppendingString:finalString];
    else if (type == SJArticleTypeMostViewed)
        apiEndPoint = [NSString stringWithFormat:@"http://api.nytimes.com/svc/mostpopular/v2/mostviewed/Health/7.json?api-key=%@", MOSTPOPULAR_APIKEY];
    else
        return;
    
    // If needed in the future
    // __weak typeof(self) weakSelf = self;
    [manager GET:apiEndPoint parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        // introspection
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            // Dispatch to the main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOADED_KEY object:[responseObject mutableCopy] userInfo:@{@"type": @(type)}];
            });
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        // Fail notification
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:FAILED_KEY object:nil];
        });
    }];
    
}

@end
