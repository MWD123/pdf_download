//
//  ViewController.m
//  PDF下载预览
//
//  Created by 孟卫东 on 2018/12/27.
//  Copyright © 2018 canshi. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "ReaderViewController.h"
#import "SVProgressHUD.h"
#define PDFURL @"http://qnfile.bidanet.com/%E4%BA%BA%E7%94%9F%E8%A7%84%E5%88%92new.pdf"
@interface ViewController ()<ReaderViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    


}
- (IBAction)DownPDF:(UIButton *)sender {
    
    [self downLoadPdfFileByUrl:PDFURL fileName:@"b.pdf"];
    
}

-(__kindof NSURLSessionTask *)downloadWithURL:(NSString *)URL
                                       fileDir:(NSString *)fileDir
                                      progress:(void(^)(NSProgress *progress))progress
                                       success:(void(^)(NSString *filePath))success
                                       failure:(void(^)(NSError *error))failure{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        progress ? progress(downloadProgress) : nil;
        NSLog(@"下载进度:%.2f%%",100.0*downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //拼接缓存目录
        NSString *downloadStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] ;
        
        //拼接文件路径
        NSString *filePath = [downloadStr stringByAppendingPathComponent:fileDir];
        
        NSLog(@"downloadStr = %@",downloadStr);
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"%@---%@", filePath, filePath.absoluteString);
       success ? success(filePath.absoluteString /** NSURL->NSString*/) : nil;
        failure && error ? failure(error) : nil;
    }];
    //开始下载
    [downloadTask resume];
    return downloadTask;
    
}

//下载pdf文件
-(void)downLoadPdfFileByUrl:(NSString *)url fileName:(NSString *)fileName
{
    //如果存在直接打开
    if ([self isFileExist:fileName]) {
        //获取路径
        NSString *documentsPath = [ReaderDocument documentsPath];
        //可根据路径command + shift + G查看该路径下的所有的pdf文件
        NSLog(@"%@", documentsPath);
        NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
        ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil];
        if (document != nil)
        {
            ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
            
            readerViewController.delegate = self;
            [self presentViewController:readerViewController animated:YES completion:NULL];
        }
    }else{
        [SVProgressHUD show];
        
        [self downloadWithURL:url fileDir:fileName progress:^(NSProgress *progress) {
            
        } success:^(NSString *filePath) {
            NSLog(@"%@", filePath);
            [SVProgressHUD dismiss];
            //下载完成直接打开
            [self downLoadPdfFileByUrl:url fileName:fileName];
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
        }];
    }

}
#pragma mark ReaderViewControllerDelegate因为PDF阅读器可能是push出来的，也可能是present出来的，为了更好的效果，这个代理方法可以实现很好的退出
- (void)dismissReaderViewController:(ReaderViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma 判断文件是否存在
-(BOOL)isFileExist:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    NSLog(@"这个文件已经存在：%@",result?@"是的":@"不存在");
    return result;
    
}


@end
