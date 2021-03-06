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
#import "FDStackView.h"

@protocol FDStackViewLayoutArrangementSubclassHook <NSObject>
@optional
@property (nonatomic, assign, readonly) NSLayoutAttribute dimensionAttributeForCurrentAxis;
@property (nonatomic, assign, readonly) NSLayoutAttribute minAttributeForCanvasConnections;
@property (nonatomic, assign, readonly) NSLayoutAttribute maxAttributeForCanvasConnections;
@property (nonatomic, assign, readonly) NSLayoutAttribute centerAttributeForCanvasConnections;

- (void)removeDeprecatedConstraints;
- (void)updateCanvasConnectionConstraintsIfNecessary;
- (NSLayoutRelation)layoutRelationForCanvasConnectionForAttribute:(NSLayoutAttribute)attribute;

@end

@interface FDStackViewLayoutArrangement : NSObject <FDStackViewLayoutArrangementSubclassHook>

@property (nonatomic, weak) UIView *canvas;
@property (nonatomic, assign) FDLayoutConstraintAxis axis;
@property (nonatomic, strong) NSMutableArray<UIView *> *mutableItems;
@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *canvasConnectionConstraints;

- (instancetype)initWithItems:(NSArray<UIView *> *)items onAxis:(FDLayoutConstraintAxis)axis;
- (void)insertItem:(UIView *)item atIndex:(NSUInteger)index;
- (void)removeItem:(UIView *)item;
- (void)addItem:(UIView *)item;

@property (nonatomic, copy, readonly) NSArray<UIView *> *items;

- (void)intrinsicContentSizeInvalidatedForItem:(id)item;
- (void)updateArrangementConstraints;

@end
