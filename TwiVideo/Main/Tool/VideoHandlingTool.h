//
//  VideoHandlingTool.h
//  TwiVideo
//
//  Created by Albus on 7/30/20.
//  Copyright © 2020 Albus. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoHandlingTool : NSObject

+ (void)combineVideoSlices;

+ (void)downloadM3u8Video:(NSString *)m3u8VideoUrl completionHandler:(void (^) (int resultCode))completionHandler;

@end

NS_ASSUME_NONNULL_END
