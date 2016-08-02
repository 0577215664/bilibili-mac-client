//
//  VideoProvider.h
//  bilibili
//
//  Created by TYPCN on 2016/3/3.
//  Copyright © 2016 TYPCN. All rights reserved.
//


// Don't use this class directly , Inherit it

#import <Foundation/Foundation.h>

#ifndef vp_h
#define vp_h

#define VP_RESOLVE_ERROR "Video Resolve Error"
#define VP_PARAM_ERROR "Input Param Error"

#endif

@class VideoAddress;

@interface VideoProvider : NSObject

+ (instancetype) sharedInstance;

- (NSDictionary *) generateParamsFromURL: (NSString *)url;
- (VideoAddress *) getVideoAddress: (NSDictionary *)params;

@end
