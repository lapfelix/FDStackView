// The MIT License (MIT)
//
// Copyright (c) 2015-2016 forkingdog ( https://github.com/forkingdog )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
#error "FDStackView must be compiled under iOS9 SDK at least"
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000
#warning "No need for FDStackView with a deploy iOS version greater than 9.0"
#endif

typedef NS_ENUM(NSInteger, FDLayoutConstraintAxis) {
    FDLayoutConstraintAxisHorizontal = 0,
    FDLayoutConstraintAxisVertical = 1
};
/* Distribution—the layout along the stacking axis.
 
 All FDStackViewDistribution enum values fit first and last arranged subviews tightly to the container,
 and except for FDStackViewDistributionFillEqually, fit all items to intrinsicContentSize when possible.
 */
typedef NS_ENUM(NSInteger, FDStackViewDistribution) {
    
    /* When items do not fit (overflow) or fill (underflow) the space available
     adjustments occur according to compressionResistance or hugging
     priorities of items, or when that is ambiguous, according to arrangement
     order.
     */
    FDStackViewDistributionFill = 0,
    
    /* Items are all the same size.
     When space allows, this will be the size of the item with the largest
     intrinsicContentSize (along the axis of the stack).
     Overflow or underflow adjustments are distributed equally among the items.
     */
    FDStackViewDistributionFillEqually,
    
    /* Overflow or underflow adjustments are distributed among the items proportional
     to their intrinsicContentSizes.
     */
    FDStackViewDistributionFillProportionally,
    
    /* Additional underflow spacing is divided equally in the spaces between the items.
     Overflow squeezing is controlled by compressionResistance priorities followed by
     arrangement order.
     */
    FDStackViewDistributionEqualSpacing,
    
    /* Equal center-to-center spacing of the items is maintained as much
     as possible while still maintaining a minimum edge-to-edge spacing within the
     allowed area.
     Additional underflow spacing is divided equally in the spacing. Overflow
     squeezing is distributed first according to compressionResistance priorities
     of items, then according to subview order while maintaining the configured
     (edge-to-edge) spacing as a minimum.
     */
    FDStackViewDistributionEqualCentering,
};

/* Alignment—the layout transverse to the stacking axis.
 */
typedef NS_ENUM(NSInteger, FDStackViewAlignment) {
    /* Align the leading and trailing edges of vertically stacked items
     or the top and bottom edges of horizontally stacked items tightly to the container.
     */
    FDStackViewAlignmentFill,
    
    /* Align the leading edges of vertically stacked items
     or the top edges of horizontally stacked items tightly to the relevant edge
     of the container
     */
    FDStackViewAlignmentLeading,
    FDStackViewAlignmentTop = FDStackViewAlignmentLeading,
    FDStackViewAlignmentFirstBaseline, // Valid for horizontal axis only
    
    /* Center the items in a vertical stack horizontally
     or the items in a horizontal stack vertically
     */
    FDStackViewAlignmentCenter,
    
    /* Align the trailing edges of vertically stacked items
     or the bottom edges of horizontally stacked items tightly to the relevant
     edge of the container
     */
    FDStackViewAlignmentTrailing,
    FDStackViewAlignmentBottom = FDStackViewAlignmentTrailing,
    FDStackViewAlignmentLastBaseline, // Valid for horizontal axis only
};

// No need to use this class directly, it is the internal class that actually works before iOS9.
@interface FDStackView : UIView

- (instancetype)initWithArrangedSubviews:(NSArray<__kindof UIView *> *)views;

@property (nonatomic, copy, readonly) NSArray<__kindof UIView *> *arrangedSubviews;

- (void)addArrangedSubview:(UIView *)view;
- (void)removeArrangedSubview:(UIView *)view;
- (void)insertArrangedSubview:(UIView *)view atIndex:(NSUInteger)stackIndex;

@property (nonatomic, assign) FDLayoutConstraintAxis axis;
@property (nonatomic, assign) FDStackViewDistribution distribution;
@property (nonatomic, assign) FDStackViewAlignment alignment;
@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, assign, getter=isBaselineRelativeArrangement) BOOL baselineRelativeArrangement;
@property (nonatomic, assign, getter=isLayoutMarginsRelativeArrangement) BOOL layoutMarginsRelativeArrangement;

@end
