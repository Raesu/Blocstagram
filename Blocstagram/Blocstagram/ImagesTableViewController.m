//
//  ImagesTableViewController.m
//  Blocstagram
//
//  Created by Ryan Summe on 7/9/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import "ImagesTableViewController.h"
#import "MediaFullScreenViewController.h"
#import "CameraViewController.h"
#import "ImageLibraryViewController.h"
#import "PostToInstagramViewController.h"

@interface ImagesTableViewController () <MediaTableViewCellDelegate, UIScrollViewDelegate, CameraViewControllerDelegate, ImageLibraryViewControllerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) UIView *lastSelectedCommentView;
@property (nonatomic, assign) CGFloat lastKeyboardAdjustment;

@end

@implementation ImagesTableViewController

-(instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[DataSource sharedInstance] addObserver:self forKeyPath:@"mediaItems" options:0 context:nil];
    [self.tableView registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"imageCell"];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraPressed:)];
        self.navigationItem.rightBarButtonItem = cameraButton;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshControlDidFire:(UIRefreshControl *)sender {
    [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error) {
        [sender endRefreshing];
    }];
}

- (void)infiniteScrollIfNecessary {
    NSIndexPath *bottomIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    
    if (bottomIndexPath && bottomIndexPath.row == [self items].count - 1) {
        [[DataSource sharedInstance] requestOldItemsWithCompletionHandler:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"mediaItems"]) {
        NSKeyValueChange kindOfChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        if (kindOfChange == NSKeyValueChangeSetting) {
            [self.tableView reloadData];
        } else if (kindOfChange == NSKeyValueChangeInsertion ||
                   kindOfChange == NSKeyValueChangeRemoval ||
                   kindOfChange == NSKeyValueChangeReplacement) {
            
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            NSMutableArray *indexPathsThatChanged = [NSMutableArray new];
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:idx inSection:0];
                [indexPathsThatChanged addObject:newIndexPath];
            }];
            
            [self.tableView beginUpdates];
            
            switch (kindOfChange) {
                case NSKeyValueChangeInsertion:
                    [self.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                case NSKeyValueChangeRemoval:
                    [self.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                case NSKeyValueChangeReplacement:
                    [self.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                default:
                    break;
            }
            
            [self.tableView endUpdates];
        }
    }
}

- (void)dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *item = [[self items] objectAtIndex:indexPath.row];
    
    if (item.image) {
        return 450;
    } else {
        return 250;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self items].count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaTableViewCell *cell = (MediaTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell stopComposingComment];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *mediaItem = [[self items] objectAtIndex:indexPath.row];
    if (mediaItem.downloadState == MediaDownloadStateNeedsImage) {
        [[DataSource sharedInstance] downloadImageForMediaItem:mediaItem];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.mediaItem = [[self items] objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *item = [[self items] objectAtIndex:indexPath.row];
    return [MediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame) traitCollection:self.view.traitCollection];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Media *item = [[self items] objectAtIndex:indexPath.row];
        [[DataSource sharedInstance] deleteMediaItem:item];
        
        // [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self infiniteScrollIfNecessary];
//    NSLog(@"scrollViewDidScroll called");
//    NSLog(@"decelerationRate == RateNormal: %d", [scrollView decelerationRate] == UIScrollViewDecelerationRateNormal);
//    NSLog(@"isDragging: %d", [scrollView isDragging]);
//    
//    if ([scrollView decelerationRate] == UIScrollViewDecelerationRateNormal &&
//        [scrollView isDragging] == NO) {
//        NSLog(@"tests passed");
//        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
//        NSLog(@"indexPaths: %@", indexPaths);
//        for (NSIndexPath *indexPath in indexPaths) {
//            Media *mediaItem = [[self items] objectAtIndex:indexPath.row];
//            if (mediaItem.downloadState == MediaDownloadStateNeedsImage) {
//                [[DataSource sharedInstance] downloadImageForMediaItem:mediaItem];
//                NSLog(@"image fetched, row: %ld", (long)indexPath.row);
//            }
//        }
//    }
}

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//    if ([scrollView decelerationRate] == UIScrollViewDecelerationRateNormal) {
//        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
//        NSLog(@"visibile indexpaths: %@", indexPaths);
//        
//        for (NSIndexPath *indexPath in indexPaths) {
//            Media *mediaItem = [[self items] objectAtIndex:indexPath.row];
//            if (mediaItem.downloadState == MediaDownloadStateNeedsImage) {
//                [[DataSource sharedInstance] downloadImageForMediaItem:mediaItem];
//            }
//        }
//    }
//}

#pragma mark - Helper Methods

- (NSArray *)items {
    return [DataSource sharedInstance].mediaItems;
}

#pragma mark - MediaTableViewCellDelegate

- (void)cell:(MediaTableViewCell *)cell didTapImage:(UIImageView *)imageView {
    MediaFullScreenViewController *fullscreenVC = [[MediaFullScreenViewController alloc] initWithMedia:cell.mediaItem];
    [fullscreenVC setImagesVC:self];
    [fullscreenVC setCell:cell];
    
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        fullscreenVC.modalPresentationStyle = UIModalPresentationFormSheet;
    } else {
        fullscreenVC.transitioningDelegate = self;
        fullscreenVC.modalPresentationStyle = UIModalPresentationCustom;
    }
    [self presentViewController:fullscreenVC animated:YES completion:nil];
}

- (void)cell:(MediaTableViewCell *)cell didDoubleTapImage:(UIImageView *)imageView {
    [[DataSource sharedInstance] downloadImageForMediaItem:cell.mediaItem];
}

- (void)cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (cell.mediaItem.caption.length > 0) {
        [itemsToShare addObject:cell.mediaItem.caption];
    }
    
    if (cell.mediaItem.image) {
        [itemsToShare addObject:cell.mediaItem.image];
    }
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (void)cellDidPressLikeButton:(MediaTableViewCell *)cell {
    Media *item = cell.mediaItem;
    
    [[DataSource sharedInstance] toggleLikeOnMediaItem:item withCompletionHandler:^{
        if (cell.mediaItem == item) {
            cell.mediaItem = item;
        }
    }];
    
    cell.mediaItem = item;
}

- (void)cellWillStartComposingComment:(MediaTableViewCell *)cell {
    self.lastSelectedCommentView = (UIView *)cell.commentView;
}

- (void)cell:(MediaTableViewCell *)cell didComposeComment:(NSString *)comment {
    [[DataSource sharedInstance] commentOnMediaItem:cell.mediaItem withCommentText:comment];
}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification {
    // Get the frame of the keyboard within self.view's coordinate system
    NSValue *frameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameInScreenCoordinates = frameValue.CGRectValue;
    CGRect keyboardFrameInViewCoordinates = [self.navigationController.view convertRect:keyboardFrameInScreenCoordinates fromView:nil];
    
    // Get the frame of the comment view in the same coordinate system
    CGRect commentViewFrameInViewCoordinates = [self.navigationController.view convertRect:self.lastSelectedCommentView.bounds fromView:self.lastSelectedCommentView];
    
    CGPoint contentOffset = self.tableView.contentOffset;
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    CGFloat heightToScroll = 0;
    
    CGFloat keyboardY = CGRectGetMinY(keyboardFrameInViewCoordinates);
    CGFloat commentViewY = CGRectGetMinY(commentViewFrameInViewCoordinates);
    CGFloat difference = commentViewY - keyboardY;
    
    if (difference > 0) {
        heightToScroll += difference;
    }
    
    if (CGRectIntersectsRect(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates)) {
        // The two frames intersect (the keyboard would block the view)
        CGRect intersectionRect = CGRectIntersection(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates);
        heightToScroll += CGRectGetHeight(intersectionRect);
    }
    
    if (heightToScroll > 0) {
        contentInsets.bottom += heightToScroll;
        scrollIndicatorInsets.bottom += heightToScroll;
        contentOffset.y += heightToScroll;
        
        NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        
        NSTimeInterval duration = durationNumber.doubleValue;
        UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
        UIViewAnimationOptions options = curve << 16;
        
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
            self.tableView.contentOffset = contentOffset;
        } completion:nil];
    }
    
    self.lastKeyboardAdjustment = heightToScroll;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    contentInsets.bottom -= self.lastKeyboardAdjustment;
    
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom -= self.lastKeyboardAdjustment;
    
    NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    NSTimeInterval duration = durationNumber.doubleValue;
    UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
    UIViewAnimationOptions options = curve << 16;
    
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
    } completion:nil];
}

#pragma mark - Camera, CameraViewControllerDelegate and ImageLibraryViewControllerDelegate

- (void)cameraPressed:(UIBarButtonItem *)sender {
    UIViewController *imageVC;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        CameraViewController *cameraVC = [[CameraViewController alloc] init];
        cameraVC.delegate = self;
        imageVC = cameraVC;
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        ImageLibraryViewController *imageLibraryVC = [[ImageLibraryViewController alloc] init];
        imageLibraryVC.delegate = self;
        imageVC = imageLibraryVC;
    }
    
    if (imageVC) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imageVC];
        
        nav.modalPresentationStyle = UIModalPresentationPopover;
        UIPopoverPresentationController *popoverController = nav.popoverPresentationController;
        popoverController.barButtonItem = sender;
        
        [self presentViewController:nav animated:YES completion:nil];
    }
    return;
}

- (void)cameraViewController:(CameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image {
    [self handleImage:image withNavigationController:cameraViewController.navigationController];
}

- (void)imageLibraryViewController:(ImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image {
    [self handleImage:image withNavigationController:imageLibraryViewController.navigationController];
}

- (void)handleImage:(UIImage *)image withNavigationController:(UINavigationController *)nav {
    if (image) {
        PostToInstagramViewController *postVC = [[PostToInstagramViewController alloc] initWithImage:image];
        
        [nav pushViewController:postVC animated:YES];
    } else {
        [nav dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
