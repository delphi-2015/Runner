#import "WeightViewController.h"

@interface WeightViewController ()

@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *weightPicker;
- (IBAction)saveWeight:(id)sender;

@property (strong, nonatomic) NSMutableArray *weightArray;

@end

@implementation WeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    _weightArray = [NSMutableArray array];
    for (int i = 70; i <= 200; i++ )
    {
        [_weightArray addObject:[NSString stringWithFormat:@"%.1f",(double)i*0.5]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.weightPicker selectRow:(self.weightArray.count/2) inComponent:0 animated:YES];
}

#pragma mark Picker Data Souce Methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0){
        return [self.weightArray count];
    }else{
        return 1;
    }
}
#pragma mark Picker Delegate Methods
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0){
        return self.weightArray[row];
    }else{
        return @"kg";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        self.weightLabel.text = [self.weightArray[row] stringByAppendingString:@"kg"];
    }
}

- (IBAction)saveWeight:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:[self.weightArray[[self.weightPicker selectedRowInComponent:0]] floatValue] forKey:@"weight"];
    [defaults synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
