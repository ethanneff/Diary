//
//  NewEntryViewController.m
//  Diary
//
//  Created by Ethan Neff on 6/9/14.
//  Copyright (c) 2014 Ethan Neff. All rights reserved.
//

#import "EntryViewController.h"
#import "DiaryEntry.h"
#import "CoreDataStack.h"
#import <CoreLocation/CoreLocation.h>

@interface EntryViewController()  <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate>

@property (assign, nonatomic) enum DiaryEntryMood pickedMood;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *goodButton;
@property (weak, nonatomic) IBOutlet UIButton *averageButton;
@property (weak, nonatomic) IBOutlet UIButton *badButton;
@property (strong, nonatomic) IBOutlet UIView *accessoryView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *imageButton; // weak b/c owned by the view and not this file

@property (strong, nonatomic) UIImage *pickedImage;
@property (strong, nonatomic) NSNumber *imagePicked;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSString *location;

@end

@implementation EntryViewController

#pragma mark - Load
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDate *date;
    
    if (self.entry != nil) {
        self.textView.text = self.entry.body; // passed body object from the segue to the textfield (entire entry passed)
        self.pickedMood = self.entry.mood;  // passed mood from entry list
        date = [NSDate dateWithTimeIntervalSince1970:self.entry.date];
        if (self.entry.image) {
            [self.imageButton setImage:[UIImage imageWithData:self.entry.image] forState:UIControlStateNormal];
        }
    } else {
        self.pickedMood = DiaryEntryMoodGood;
        date = [NSDate date];
        [self loadLocation];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d, yyyy"];
    self.dateLabel.text = [dateFormatter stringFromDate:date];
    
    self.textView.inputAccessoryView = self.accessoryView;  // on top of the keyboard
    
    self.imageButton.layer.cornerRadius = CGRectGetWidth(self.imageButton.frame) / 2.0f; // round the corners of image
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder]; // autoselect textview
}

#pragma mark - Nav Button Actions
- (IBAction)doneWasPressed:(id)sender {
    if (self.entry != nil) {
        [self updateDiaryEntry];
    } else {
        [self insertDiaryEntry];
    }
    [self dismissSelf];
}

- (IBAction)cancelWasPressed:(id)sender {
    [self dismissSelf];
}

#pragma mark - Insert Data
- (void)insertDiaryEntry { // creates in core data
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    DiaryEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:@"DiaryEntry" inManagedObjectContext:coreDataStack.managedObjectContext]; // insert new object in datastack
    entry.body = self.textView.text; // no self b/c creating (no existing object)
    entry.mood = self.pickedMood;
    entry.date = [[NSDate date] timeIntervalSince1970];
    entry.image = UIImageJPEGRepresentation(self.pickedImage, 0.75);
    entry.location = self.location;
    [coreDataStack saveContext];
}

#pragma mark - Update Data
- (void)updateDiaryEntry { // modifys in core data
    self.entry.body = self.textView.text;
    self.entry.mood = self.pickedMood;
    if ([self.imagePicked boolValue] == YES) {
        self.entry.image = UIImageJPEGRepresentation(self.pickedImage, 0.75);
    }
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    [coreDataStack saveContext];
}

#pragma mark - Exit View
-(void)dismissSelf {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];  // b/c a modual
}

#pragma mark - Mood Buttons
- (IBAction)goodWasPressed:(id)sender { // changes the mood button (calls setPickedMood() b/c of self.pickedMood)
    self.pickedMood = DiaryEntryMoodGood;
}
- (IBAction)averageWasPressed:(id)sender {
    self.pickedMood = DiaryEntryMoodAverage;
}
- (IBAction)badWasPressed:(id)sender {
    self.pickedMood = DiaryEntryMoodBad;
}

#pragma mark - Set Mood
- (void)setPickedMood:(enum DiaryEntryMood)pickedMood {  // setter
    _pickedMood = pickedMood; //set the private instance property to the picked mood
    
    self.badButton.alpha = 0.5f;    // reset all
    self.averageButton.alpha = 0.5f;
    self.goodButton.alpha = 0.5f;
    
    switch (pickedMood) {
        case DiaryEntryMoodGood:
            self.goodButton.alpha = 1.0f;
            break;
        case DiaryEntryMoodAverage:
            self.averageButton.alpha = 1.0f;
            break;
        case DiaryEntryMoodBad:
            self.badButton.alpha = 1.0f;
            break;
    }
}

#pragma mark - Image Selection
- (IBAction)imageButtonWasPressed:(id)sender {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self promptForSource];
    }else {
        [self promptForPhotoRoll];
    }
}

- (void)promptForSource {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Image Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Roll", nil];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex != actionSheet.firstOtherButtonIndex) {
            [self promptForCamera];
        } else {
            [self promptForPhotoRoll];
        }
    }
}

- (void)promptForCamera {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera; // camera
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)promptForPhotoRoll {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; // camera
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info { // select source
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.pickedImage = image; // calls setter method
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPickedImage:(UIImage *)pickedImage { // setter
    _pickedImage = pickedImage; // set instance variable
    self.imagePicked = [NSNumber numberWithBool:YES];
    
    if (pickedImage == nil) {
        [self.imageButton setImage:[UIImage imageNamed:@"icn_noimage"] forState:UIControlStateNormal];
    } else {
        [self.imageButton setImage:pickedImage forState:UIControlStateNormal];
    }
}

#pragma mark - Location Finding
- (void)loadLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = 1000; // 1000m 0.6miles
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations { // respond to the delegate method
    [self.locationManager stopUpdatingLocation];
    
    CLLocation *location = [locations firstObject];
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks firstObject]; // able to get an array of locations.. just grab first
        self.location = placemark.name; // placemark has a lot of attributes to pull (command click CLPlacemark)
    }];
}
@end
