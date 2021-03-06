//
//  ImageViewWithCache.m
//  GrandBo
//
//  Created by Xu Menghua on 15/9/18.
//  Copyright (c) 2015年 Xu Menghua. All rights reserved.
//

#import "ImageViewWithCache.h"

@implementation ImageViewWithCache

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setDefaultImage:(NSString *)defaultImage {
    if (_defaultImage != defaultImage) {
        _defaultImage = defaultImage;
    }
    [self setImage:[UIImage imageNamed:_defaultImage]];
}

- (void)setImageURL:(NSString *)imageURL {
    if (_imageURL != imageURL) {
        _imageURL = imageURL;
    }
    
    if (_imageURL != nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSMutableString * path = [[NSMutableString alloc]initWithString:cacheDirectory];
        [path appendString:[NSString stringWithFormat:@"/%@", self.imageURL]];
        
        __block NSData *image = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"/%@.img", path]];
        if (image == nil) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self loadImage];
                
                while (image == nil) {
                    image = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"/%@.img", path]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setImage:[UIImage imageWithData:image]];
                });  
                
            });
        }else {
            [self setImage:[UIImage imageWithData:image]];
        }
        //NSLog(@"%@", image);
    }
}

#pragma mark - 从网络请求图片，缓存到本地

- (NSData *)loadImage {
    NSData *image = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageURL]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSMutableString *path = [[NSMutableString alloc]initWithString:cacheDirectory];
    [path appendString:[NSString stringWithFormat:@"/%@", self.imageURL]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:path]) {
        NSError *e = nil;
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&e];
        //NSLog(@"%@", e.localizedDescription);
    }
    
    if (![fm createFileAtPath:[NSString stringWithFormat:@"/%@.img", path] contents:image attributes:nil]) {
        return nil;
    }
    //NSLog(@"download");
    return image;
}

@end
