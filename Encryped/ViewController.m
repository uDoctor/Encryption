//
//  ViewController.m
//  Encryped
//
//  Created by pangpangpig-Mac on 2017/10/25.
//  Copyright © 2017年 _Doctor. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonCrypto.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *encrytedTypeTF;
@property (weak, nonatomic) IBOutlet UITextField *encrytedString;
@property (weak, nonatomic) IBOutlet UITextField *encodingKeyTF;
@property (weak, nonatomic) IBOutlet UITextField *decodingKeyTF;
@property (weak, nonatomic) IBOutlet UILabel *decodingString;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}



- (NSString*)encryptionType:(CCAlgorithm)encryptionType encodingStr:(NSString *)originStr key:(NSString*)key
{
    // 1, 将 str装换成 data数据
    NSData * baseData = [originStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    size_t dataOutOffset = 0;
    NSUInteger dataLength = baseData.length +10+[key dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length;
    unsigned char buffer[dataLength];
    memset(buffer, 0,sizeof(char));
    
   CCCryptorStatus cryptorStatus = CCCrypt(
                                   kCCEncrypt,          // 解密还是解密
                                   encryptionType,      // 加密的方式 DES, 3DES, AES
                                   kCCOptionPKCS7Padding|kCCOptionECBMode,
                                   [key UTF8String],    //把key转换为C串
                                   keyLength,           //秘钥的size，固定的 kCCKeySizeDES,kCCKeySize3DES
                                   nil,
                                   [baseData bytes],
                                   [baseData length],
                                   buffer,              // 注意接收加密的buffer的大小
                                   dataLength,          //
                                   &dataOutOffset       //
                                   );
    
    NSString * encoding=@"";
    if (cryptorStatus == kCCSuccess) {
        NSData * data = [NSData dataWithBytes:buffer length:dataOutOffset];
        encoding = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSLog(@"加密后的串：[%@]", encoding);
    }else
        NSLog(@"加密失败！%d",cryptorStatus);
    
    return encoding;
}

//2， 解密与加密对应
- (NSString *)decryptionType:(CCAlgorithm)decryptionType decryptionStr:(NSString *)baseStr key:(NSString*)key
{
    //因为加密后的data 是用 base64 显示的，所以这里要先将baseStr 用 base64解密成data。
    NSData * baseData =  [[NSData alloc]initWithBase64EncodedString:baseStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSUInteger dataLength = baseData.length +10+[key dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES].length;
    unsigned char buffer[dataLength];
    memset(buffer, 0,sizeof(char));
    size_t dataOffset = 0;
    
    CCCryptorStatus status = CCCrypt(kCCDecrypt,
                                     decryptionType,
                                     kCCOptionPKCS7Padding|kCCOptionECBMode,
                                     [key UTF8String],
                                     keyLength,
                                     nil,
                                     [baseData bytes],
                                     [baseData length],
                                     buffer,
                                     dataLength,
                                     &dataOffset );
    NSString * decodingStr =nil;
    if (status == 0) {
        NSData * data = [[NSData alloc]initWithBytes:buffer length:dataOffset];
        decodingStr =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"解密后的串：[%@]", decodingStr);
    }
    else
        NSLog(@"解密失败；");
    
    return decodingStr;
//    CCCryptorStatus status = CCCrypt(CCOperation op,
//                                     CCAlgorithm alg,
//                                     CCOptions options,
//                                     const void *key,
//                                     size_t keyLength,
//                                     const void *iv,
//                                     const void *dataIn,
//                                     size_t dataInLength,
//                                     void *dataOut,
//                                     size_t dataOutAvailable,
//                                     size_t *dataOutMoved   )
}

static int keyLength = 8;
- (IBAction)decodingClick:(id)sender {
    
    NSString * str = self.encrytedString.text;
    NSString * enkey = @"mnki";
    NSString * dekey = @"mnki";
    
    CCAlgorithm cryptionType = 0 ;
    
    switch ([self.encrytedTypeTF.text intValue]) {
        case 0: cryptionType = kCCAlgorithmAES ; keyLength =kCCKeySizeAES128; break;
        case 1: cryptionType = kCCAlgorithmDES ; keyLength =kCCKeySizeDES; break;
        case 2: cryptionType = kCCAlgorithm3DES; keyLength =kCCKeySize3DES;  break;
    }
    NSString * enStr = [self encryptionType:cryptionType encodingStr:str key:enkey];
    NSString * decryptionString =[self decryptionType:cryptionType decryptionStr:enStr key:dekey];
    
    self.decodingString.text = [NSString stringWithFormat:@"加密的内容：【%@】\n加密后的串：【%@】\n 解密后的串：【%@】",str,enStr,decryptionString];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.decodingKeyTF resignFirstResponder];
    [self.encrytedTypeTF resignFirstResponder];
    [self.encodingKeyTF resignFirstResponder];
    [self.encrytedString resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
