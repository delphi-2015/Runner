#import "HeightViewController.h"

@interface HeightViewController ()

@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *heightPicker;
- (IBAction)saveHeight:(id)sender;
@property (strong, nonatomic) NSMutableArray *heightArray;

@end

@implementation HeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _heightArray = [NSMutableArray array];
    for (int i = 280; i <= 400; i++ )
    {
        [_heightArray addObject:[NSString stringWithFormat:@"%.1f",(double)i*0.5]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.heightPicker selectRow:(self.heightArray.count/2) inComponent:0 animated:YES];
}

#pragma mark Picker Data Souce Methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0){
        return [self.heightArray count];
    }else{
        return 1;
    }
}
#pragma mark Picker Delegate Methods
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0){
        return self.heightArray[row];
    }else{
        return @"cm";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        self.heightLabel.text = [self.heightArray[row] stringByAppendingString:@"cm"];
    }
}

- (IBAction)saveHeight:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:[self.heightArray[[self.heightPicker selectedRowInComponent:0]] floatValue] forKey:@"height"];
    [defaults synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
