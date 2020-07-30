//
//  VideoHandlingTool.m
//  TwiVideo
//
//  Created by Albus on 7/30/20.
//  Copyright © 2020 Albus. All rights reserved.
//

#import "VideoHandlingTool.h"
#import <mobileffmpeg/MobileFFmpegConfig.h>
#import <mobileffmpeg/MobileFFmpeg.h>

@implementation VideoHandlingTool

+ (void)combineVideoSlices {
//    int rc = [MobileFFmpeg execute: @"-i file1.mp4 -c:v mpeg4 file2.mp4"];
    int rc = [MobileFFmpeg execute:@"pwd"];

    if (rc == RETURN_CODE_SUCCESS) {
        NSLog(@"Command execution completed successfully.\n");
    } else if (rc == RETURN_CODE_CANCEL) {
        NSLog(@"Command execution cancelled by user.\n");
    } else {
        NSLog(@"Command execution failed with rc=%d and output=%@.\n", rc, [MobileFFmpegConfig getLastCommandOutput]);
    }
}

+ (void)downloadM3u8Video:(NSString *)m3u8VideoUrl completionHandler:(void (^) (int resultCode))completionHandler {
//    int rc = [MobileFFmpeg execute:[NSString stringWithFormat:@"-i %@ -c copy /Users/albus/Desktop/media.mp4", m3u8VideoUrl]];
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *videoPath = [documentsPath stringByAppendingString:@"/TwitterVideo.mp4"];
    [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];

    int rc = [MobileFFmpeg execute:[NSString stringWithFormat:@"-i %@ -c copy %@", m3u8VideoUrl, videoPath]];
    NSLog(@"MobileFFmpeg execute: %i", rc);
    
    if (completionHandler) {
        completionHandler(rc);
    }

    if (rc == RETURN_CODE_SUCCESS) {
        NSLog(@"Command execution completed successfully.\n");
    } else if (rc == RETURN_CODE_CANCEL) {
        NSLog(@"Command execution cancelled by user.\n");
    } else {
        NSLog(@"Command execution failed with rc=%d and output=%@.\n", rc, [MobileFFmpegConfig getLastCommandOutput]);
    }
    
    NSLog(@"videoPathvideoPath: %@", videoPath);
}

@end
