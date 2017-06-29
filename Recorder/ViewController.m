//
//  ViewController.m
//  Recorder
//
//  Created by liuxu on 2017/6/28.
//  Copyright © 2017年 liuxu. All rights reserved.
//

#import "ViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "LVRecordTool.h"

@interface ViewController ()<LVRecordToolDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *deletebutton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIImageView *recordImageView;
/** 录音工具 */
@property (nonatomic, strong) LVRecordTool *recordTool;
@property (nonatomic, assign) NSInteger recordStatus;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSString *audioStatus;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor =self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:223 / 255.0 green:77 / 255.0 blue:79 / 255.0 alpha:1];

    if ([[NSUserDefaults standardUserDefaults] arrayForKey:@"dataArray"].count == 0) {
        _dataArray = [NSMutableArray array];
    } else {
        _dataArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"dataArray"]];
    }


    [SVProgressHUD setMinimumDismissTimeInterval:1];
    
    [self loadUI];
    _recordStatus = 0;
    
}

- (void)loadUI {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 46, 46)];
    [button setImage:[UIImage imageNamed:@"marvel"] forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
    button.tag = 1;
    [button addTarget:self action:@selector(barButtonItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = buttonItem;
    
    UIButton *button2 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 46, 46)];
    button2.tag = 2;
    [button2 setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [button2 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -25)];
    [button2 addTarget:self action:@selector(barButtonItemClick:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *buttonItem2 = [[UIBarButtonItem alloc]initWithCustomView:button2];
    self.navigationItem.rightBarButtonItem = buttonItem2;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(164);
    }];
    
    
    _titleTextField = [UITextField new];
    _titleTextField.placeholder = @"please input title";
    _titleTextField.returnKeyType = UIReturnKeyDone;
    _titleTextField.delegate = self;
    _titleTextField.textColor = [UIColor whiteColor];
    _titleTextField.text = @"new file";
    _titleTextField.font = [UIFont systemFontOfSize:25];
    _titleTextField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleTextField];
    [_titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(imageView.mas_bottom).offset(30);
        make.size.mas_equalTo(CGSizeMake(self.view.frame.size.width, 40));
    }];
    
    _timerLabel = [UILabel new];
    _timerLabel.textColor = [UIColor whiteColor];
    _timerLabel.font = [UIFont systemFontOfSize:45];
    _timerLabel.text = @"00:00:00";
    _timerLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_timerLabel];
    [_timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(self.view.frame.size.width);
        make.top.equalTo(_titleTextField.mas_bottom).offset(30);
    }];
    
    _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _recordButton.tag = 4;
    [_recordButton setImage:[UIImage imageNamed:@"mic_0"] forState:UIControlStateNormal];
    [_recordButton setImage:[UIImage imageNamed:@"mic_0"] forState:UIControlStateHighlighted];
    [_recordButton setImage:[UIImage imageNamed:@"square"] forState:UIControlStateSelected];
    [_recordButton addTarget:self action:@selector(barButtonItemClick:) forControlEvents:UIControlEventTouchDown];
    _recordButton.selected = NO;
    [self.view addSubview:_recordButton];
    [_recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(120, 120));
        make.bottom.equalTo(self.view).offset(-70);
        make.centerX.equalTo(self.view);
    }];
    
    _deletebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deletebutton.tag = 3;
    [_deletebutton setImage:[UIImage imageNamed:@"delete1"] forState:UIControlStateDisabled];
    [_deletebutton addTarget:self action:@selector(barButtonItemClick:) forControlEvents:UIControlEventTouchUpInside];
    _deletebutton.enabled = NO;
    [self.view addSubview:_deletebutton];
    [_deletebutton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.right.equalTo(_recordButton.mas_left).offset(-30);
        make.centerY.equalTo(_recordButton);
    }];
    
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveButton.tag = 5;
    [_saveButton setImage:[UIImage imageNamed:@"save1"] forState:UIControlStateDisabled];
    [_saveButton addTarget:self action:@selector(barButtonItemClick:) forControlEvents:UIControlEventTouchUpInside];
    _saveButton.enabled = NO;
    [self.view addSubview:_saveButton];
    [_saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.left.equalTo(_recordButton.mas_right).offset(30);
        make.centerY.equalTo(_recordButton);
    }];
    
    _overlayView = [UIView new];
    _overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _overlayView.alpha = 0;
    [self.view addSubview:_overlayView];
    [_overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.center.equalTo(self.view);
    }];
    
    _recordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mic_1"]];
    [_overlayView addSubview:_recordImageView];
    [_recordImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.center.equalTo(_overlayView);
    }];
    
    self.recordTool = [LVRecordTool sharedRecordTool];
    self.recordTool.delegate = self;
    
    
}

- (void)barButtonItemClick:(UIButton *)button {
    switch (button.tag) {
        case 1: {
            LeftViewController *vc = [[LeftViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2: {
            RightViewController *vc = [[RightViewController alloc] init];
            vc.dataArray = self.dataArray;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
            _recordButton.selected = NO;
            _deletebutton.enabled = NO;
            _saveButton.enabled = NO;
            [_deletebutton setImage:[UIImage imageNamed:@"delete1"] forState:UIControlStateDisabled];
            [_saveButton setImage:[UIImage imageNamed:@"save1"] forState:UIControlStateDisabled];
            [_recordTool destructionRecordingFile];
            [SVProgressHUD showSuccessWithStatus:@"delete success"];
            break;
        case 4:
            [self.recordTool stopRecording];
            [self checkAudioStatus];
            if ([_audioStatus isEqualToString:@"AVAuthorizationStatusAuthorized"]) {
                button.selected = !button.isSelected;
                if (button.selected) {
                    _count = 0;
                    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSecond) userInfo:nil repeats:YES];
                    [self.recordTool startRecording];
                    self.overlayView.alpha = 1;
                    _deletebutton.enabled = NO;
                    _saveButton.enabled = NO;
                    [_deletebutton setImage:[UIImage imageNamed:@"delete1"] forState:UIControlStateDisabled];
                    [_saveButton setImage:[UIImage imageNamed:@"save1"] forState:UIControlStateDisabled];
                } else {
                    if (_timer) {
                        [_timer invalidate];
                        _timer = nil;
                        [self.recordTool stopRecording];
                        self.overlayView.alpha = 0;
                        self.timerLabel.text = @"00:00:00";
                        _deletebutton.enabled = YES;
                        _saveButton.enabled = YES;
                        [_deletebutton setImage:[UIImage imageNamed:@"delete2"] forState:UIControlStateNormal];
                        [_saveButton setImage:[UIImage imageNamed:@"save2"] forState:UIControlStateNormal];
                    }
                }
            } else {
                [self.recordTool startRecording];
                [self.recordTool stopRecording];
                [self.recordTool destructionRecordingFile];
            }
            break;
        case 5:
            if (_titleTextField.text.length == 0) {
                [SVProgressHUD showErrorWithStatus:@"please input title"];
                return;
            } else {
                _recordButton.selected = NO;
                _deletebutton.enabled = NO;
                _saveButton.enabled = NO;
                [_deletebutton setImage:[UIImage imageNamed:@"delete1"] forState:UIControlStateDisabled];
                [_saveButton setImage:[UIImage imageNamed:@"save1"] forState:UIControlStateDisabled];
                [_dataArray addObject:@{@"title":self.titleTextField.text, @"time":[self.recordTool getTimeStamp], @"url":[self.recordTool getVideoPath].absoluteString, @"timerBetween":[self.recordTool getTimerBetween]}];
                [[NSUserDefaults standardUserDefaults] setObject:_dataArray forKey:@"dataArray"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [SVProgressHUD showSuccessWithStatus:@"save success"];
            }
            break;
        default:
            break;
    }
}

- (void)updateSecond {
    _count ++;
    _timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", _count / 3600, _count / 60, _count % 60];
}

- (void) checkAudioStatus{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
            //没有询问是否开启麦克风
            self.audioStatus = @"AVAuthorizationStatusNotDetermined";
            break;
        case AVAuthorizationStatusRestricted:
            //未授权，家长限制
            self.audioStatus = @"AVAuthorizationStatusRestricted";
            break;
        case AVAuthorizationStatusDenied:
            //玩家未授权
            self.audioStatus = @"AVAuthorizationStatusDenied";
            break;
        case AVAuthorizationStatusAuthorized:
            //玩家授权
            self.audioStatus = @"AVAuthorizationStatusAuthorized";
            break;
        default:
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [_titleTextField endEditing:YES];
}

#pragma mark - LVRecordToolDelegate
- (void)recordTool:(LVRecordTool *)recordTool didstartRecoring:(int)no {
    NSLog(@"%d", no);
    if (no >= 7) {
        no = 7;
    }
    if (no <= 1) {
        no = 1;
    }
    NSString *imageName = [NSString stringWithFormat:@"mic_%d", no];
    self.recordImageView.image = [UIImage imageNamed:imageName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
