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
- (void) downloadContent:(NSString *)str;

@end

@implementation Downloader

#define APIKEY "02345b4316532bcd5264fdcf5e71db45:10:71928127"

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

- (void) downloadContent:(NSString *)str {
    
     AFHTTPSessionManager* manager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
     manager.responseSerializer = [AFJSONResponseSerializer serializer];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSString* str1 = [NSString stringWithFormat:@"http://api.nytimes.com/svc/search/v2/articlesearch.json?q=%@&sort=newest&fl=web_url", str];
    NSString* str2 = @"%2Csnippet%2Clead_paragraph%2Cheadline&api-key=02345b4316532bcd5264fdcf5e71db45:10:71928127";
    
     [manager GET:[str1 stringByAppendingString:str2] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {

     if ([responseObject isKindOfClass:[NSDictionary class]]) {

         [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOADEDKEY object:[responseObject mutableCopy]];
     }
     
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
     
         NSLog(@"%@", error);
     
     }];
    
}

- (void) queryForArticles:(NSString*)string
{
    [self downloadContent:string];
}

@end
