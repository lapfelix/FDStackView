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

#import "FDStackViewAlignmentLayoutArrangement.h"
#import "FDStackViewExtensions.h"
#import "FDLayoutSpacer.h"

@interface FDStackViewAlignmentLayoutArrangement ()
@property (nonatomic, assign) BOOL spanningGuideConstraintsNeedUpdate;
@property (nonatomic, strong) FDLayoutSpacer *spanningLayoutGuide;
@end

@implementation FDStackViewAlignmentLayoutArrangement

#pragma mark - Setter / Getter

- (NSMutableDictionary *)alignmentConstraints {
    if (!_alignmentConstraints) {
        _alignmentConstraints = [NSMutableDictionary dictionary];
    }
    return _alignmentConstraints;
}

- (NSMapTable<UIView *,NSLayoutConstraint *> *)hiddingDimensionConstraints {
    if (!_hiddingDimensionConstraints) {
        _hiddingDimensionConstraints = [NSMapTable weakToWeakObjectsMapTable];
    }
    return _hiddingDimensionConstraints;
}

- (NSString *)alignmentConstraintsFirstKey {
    if (self.axis == FDLayoutConstraintAxisHorizontal) {
        switch (self.alignment) {
            case FDStackViewAlignmentFill:
                return @"Bottom";
            case FDStackViewAlignmentTop:
            case FDStackViewAlignmentCenter:
            case FDStackViewAlignmentBottom:
            case FDStackViewAlignmentFirstBaseline:
            case FDStackViewAlignmentLastBaseline:
                return @"Ambiguity Suppression";
            default:
                return @"Not Supported";
        }
    } else {
        switch (self.alignment) {
            case FDStackViewAlignmentFill:
                return @"Leading";
            case FDStackViewAlignmentLeading:
            case FDStackViewAlignmentCenter:
            case FDStackViewAlignmentTrailing:
                return @"Ambiguity Suppression";
            default:
                return @"Not Supported";
        }
    }
}

- (NSString *)alignmentConstraintsSecondKey {
    if (self.axis == FDLayoutConstraintAxisHorizontal) {
        switch (self.alignment) {
            case FDStackViewAlignmentBottom:
            case FDStackViewAlignmentLastBaseline:
                return @"Bottom";
            case FDStackViewAlignmentCenter:
                return @"CenterY";
            case FDStackViewAlignmentTop:
            case FDStackViewAlignmentFill:
            case FDStackViewAlignmentFirstBaseline:
                return @"Top";
            default:
                return @"Not Supported";
        }
    } else {
        switch (self.alignment) {
            case FDStackViewAlignmentLeading:
                return @"Leading";
            case FDStackViewAlignmentCenter:
                return @"CenterX";
            case FDStackViewAlignmentTrailing:
            case FDStackViewAlignmentFill:
                return @"Trailing";
            default:
                return @"Not Supported";
        }
    }
}

- (NSLayoutAttribute)alignmentConstraintsFirstAttribute {
    if (self.axis == FDLayoutConstraintAxisHorizontal) {
        switch (self.alignment) {
            case FDStackViewAlignmentFill:
                return NSLayoutAttributeBottom;
            case FDStackViewAlignmentTop:
            case FDStackViewAlignmentCenter:
            case FDStackViewAlignmentBottom:
            case FDStackViewAlignmentFirstBaseline:
            case FDStackViewAlignmentLastBaseline:
                return self.dimensionAttributeForCurrentAxis;
            default:
                return NSLayoutAttributeNotAnAttribute;
        }
    } else {
        switch (self.alignment) {
            case FDStackViewAlignmentFill:
                return NSLayoutAttributeLeading;
            case FDStackViewAlignmentLeading:
            case FDStackViewAlignmentCenter:
            case FDStackViewAlignmentTrailing:
                return self.dimensionAttributeForCurrentAxis;
            default:
                return NSLayoutAttributeNotAnAttribute;
        }
    }
}

- (NSLayoutAttribute)alignmentConstraintsSecondAttribute {
    if (self.axis == FDLayoutConstraintAxisHorizontal) {
        switch (self.alignment) {
            case FDStackViewAlignmentBottom:
                return NSLayoutAttributeBottom;
            case FDStackViewAlignmentCenter:
                return NSLayoutAttributeCenterY;
            case FDStackViewAlignmentTop:
            case FDStackViewAlignmentFill:
                return NSLayoutAttributeTop;
            case FDStackViewAlignmentFirstBaseline:
                return NSLayoutAttributeFirstBaseline;
            case FDStackViewAlignmentLastBaseline:
                return NSLayoutAttributeLastBaseline;
            default:
                return NSLayoutAttributeNotAnAttribute;
        }
    } else {
        switch (self.alignment) {
            case FDStackViewAlignmentLeading:
                return NSLayoutAttributeLeading;
            case FDStackViewAlignmentCenter:
                return NSLayoutAttributeCenterX;
            case FDStackViewAlignmentTrailing:
            case FDStackViewAlignmentFill:
                return NSLayoutAttributeTrailing;
            default:
                return NSLayoutAttributeNotAnAttribute;
        }
    }
}

- (FDLayoutSpacer *)spanningLayoutGuide {
    if (!_spanningLayoutGuide) {
        [self createSpanningLayoutGuide];
        _spanningGuideConstraintsNeedUpdate = YES;
        [self updateSpanningLayoutGuideConstraintsIfNecessary];
    }
    return _spanningLayoutGuide;
}

- (void)setAxis:(FDLayoutConstraintAxis)axis {
    if (self.axis != axis) {
        [super setAxis:axis];
        [self.spanningLayoutGuide removeFromSuperview];
        self.spanningLayoutGuide = nil;
        [self configureValidAlignment:&_alignment forAxis:axis];
    }
}

- (void)setAlignment:(FDStackViewAlignment)alignment {
    if (_alignment != alignment) {
        [self configureValidAlignment:&alignment forAxis:self.axis];
        _alignment = alignment;
        _spanningGuideConstraintsNeedUpdate = YES;
    }
}

#pragma mark - Override Methods

- (void)removeDeprecatedConstraints {
    [self.alignmentConstraints enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMapTable *mapTable, BOOL *stop) {
        [self.canvas removeConstraints:mapTable.fd_allObjects];
    }];
    [self.alignmentConstraints removeAllObjects];
    [self.canvas removeConstraints:self.hiddingDimensionConstraints.fd_allObjects];
    [self.hiddingDimensionConstraints removeAllObjects];
}

- (NSLayoutAttribute)minAttributeForCanvasConnections {
    return self.axis == FDLayoutConstraintAxisHorizontal ? NSLayoutAttributeTop : NSLayoutAttributeLeading;
}

- (NSLayoutAttribute)centerAttributeForCanvasConnections {
    return self.axis == FDLayoutConstraintAxisHorizontal ? NSLayoutAttributeCenterY : NSLayoutAttributeCenterX;
}

- (NSLayoutAttribute)maxAttributeForCanvasConnections {
    return self.axis == FDLayoutConstraintAxisHorizontal ? NSLayoutAttributeBottom : NSLayoutAttributeTrailing;
}

- (NSLayoutAttribute)dimensionAttributeForCurrentAxis {
    return self.axis == FDLayoutConstraintAxisHorizontal ? NSLayoutAttributeHeight : NSLayoutAttributeWidth;
}

- (NSLayoutRelation)layoutRelationForCanvasConnectionForAttribute:(NSLayoutAttribute)attribute {
    switch (self.alignment) {
        case FDStackViewAlignmentFirstBaseline: {
            if (attribute == self.minAttributeForCanvasConnections) {
                return NSLayoutRelationGreaterThanOrEqual;
            }
            break;
        }
        case FDStackViewAlignmentLastBaseline: {
            if (attribute == self.maxAttributeForCanvasConnections) {
                return NSLayoutRelationLessThanOrEqual;
            }
            break;
        }
        default:
            break;
    }
    return NSLayoutRelationEqual;
}

- (NSLayoutRelation)layoutRelationForItemConnectionForAttribute:(NSLayoutAttribute)attribute {
    switch (self.alignment) {
        case FDStackViewAlignmentCenter:
        case FDStackViewAlignmentFirstBaseline:
        case FDStackViewAlignmentLastBaseline: {
            if (attribute == self.minAttributeForCanvasConnections) {
                return NSLayoutRelationLessThanOrEqual;
            } else if (attribute == self.maxAttributeForCanvasConnections) {
                return NSLayoutRelationGreaterThanOrEqual;
            }
            break;
        }
        case FDStackViewAlignmentTop: {
            if (attribute == self.maxAttributeForCanvasConnections) {
                return NSLayoutRelationGreaterThanOrEqual;
            }
            break;
        }
        case FDStackViewAlignmentBottom: {
            if (attribute == self.minAttributeForCanvasConnections) {
                return NSLayoutRelationLessThanOrEqual;
            }
            break;
        }
        default:
            break;
    }
    return NSLayoutRelationEqual;
}

- (void)updateArrangementConstraints {
    [self updateSpanningLayoutGuideConstraintsIfNecessary];
    [super updateArrangementConstraints];
    [self updateAlignmentItemsConstraintsIfNecessary];
}

- (void)updateCanvasConnectionConstraintsIfNecessary {
    if (self.mutableItems.count == 0) {
        return;
    }
    
    [self.canvas removeConstraints:self.canvasConnectionConstraints];
    [self.canvasConnectionConstraints removeAllObjects];
    
    NSArray<NSNumber *> *canvasAttributes = @[@(self.minAttributeForCanvasConnections), @(self.maxAttributeForCanvasConnections)];
    if (self.alignment == FDStackViewAlignmentCenter) {
        canvasAttributes = [canvasAttributes arrayByAddingObject:@(self.centerAttributeForCanvasConnections)];
    } else if (self.isBaselineAlignment) {
        NSLayoutConstraint *canvasFitConstraint = [NSLayoutConstraint constraintWithItem:self.canvas attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
        canvasFitConstraint.identifier = @"FDSV-canvas-fit";
        canvasFitConstraint.priority = 49;
        [self.canvas addConstraint:canvasFitConstraint];
        [self.canvasConnectionConstraints addObject:canvasFitConstraint];
    }
    
    [canvasAttributes enumerateObjectsUsingBlock:^(NSNumber *canvasAttribute, NSUInteger idx, BOOL *stop) {
        NSLayoutAttribute attribute = canvasAttribute.integerValue;
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:[self viewOrGuideForLocationAttribute:attribute] attribute:attribute relatedBy:[self layoutRelationForCanvasConnectionForAttribute:attribute] toItem:self.canvas attribute:attribute multiplier:1 constant:0];
        constraint.identifier = @"FDSV-canvas-connection";
        [self.canvas addConstraint:constraint];
        [self.canvasConnectionConstraints addObject:constraint];
    }];
}

- (UIView *)viewOrGuideForLocationAttribute:(NSLayoutAttribute)attribute {
    switch (self.alignment) {
        case FDStackViewAlignmentFill:
            return self.mutableItems.firstObject;
        case FDStackViewAlignmentTop:
        case FDStackViewAlignmentFirstBaseline: {
            if (attribute == self.minAttributeForCanvasConnections) {
                return self.mutableItems.firstObject;
            }
            break;
        }
        case FDStackViewAlignmentCenter: {
            if (attribute == self.centerAttributeForCanvasConnections) {
                return self.mutableItems.firstObject;
            }
            break;
        }
        case FDStackViewAlignmentBottom:
        case FDStackViewAlignmentLastBaseline: {
            if (attribute == self.maxAttributeForCanvasConnections) {
                return self.mutableItems.firstObject;
            }
            break;
        }
        default:
            break;
    }
    return self.spanningLayoutGuide;
}

#pragma mark - Private Methods

- (void)createSpanningLayoutGuide {
    [_spanningLayoutGuide removeFromSuperview];
    _spanningLayoutGuide = [FDLayoutSpacer new];
    _spanningLayoutGuide.translatesAutoresizingMaskIntoConstraints = NO;
    [self.canvas addSubview:_spanningLayoutGuide];
    _spanningLayoutGuide.horizontal = self.axis == FDLayoutConstraintAxisHorizontal;
}

- (BOOL)spanningGuideConstraintsNeedUpdate {
    if (self.alignment != FDStackViewAlignmentFill && _spanningGuideConstraintsNeedUpdate) {
        _spanningGuideConstraintsNeedUpdate = NO;
        return YES;
    }
    return NO;
}

- (BOOL)isBaselineAlignment {
    return self.axis == FDLayoutConstraintAxisHorizontal && (self.alignment == FDStackViewAlignmentFirstBaseline || self.alignment == FDStackViewAlignmentLastBaseline);
}

- (void)configureValidAlignment:(FDStackViewAlignment *)alignment forAxis:(FDLayoutConstraintAxis)axis {
    if (axis == FDLayoutConstraintAxisVertical && (*alignment == FDStackViewAlignmentFirstBaseline || *alignment == FDStackViewAlignmentLastBaseline)) {
        NSLog(@"Invalid for vertical axis. Use Leading or Trailing instead.");
        *alignment = *alignment == FDStackViewAlignmentFirstBaseline ? FDStackViewAlignmentLeading : FDStackViewAlignmentTrailing;
    }
}

- (void)updateSpanningLayoutGuideConstraintsIfNecessary {
    if (self.mutableItems.count == 0) {
        return;
    }
    
    if (self.spanningLayoutGuide && self.spanningGuideConstraintsNeedUpdate) {
        [self.canvas removeConstraints:self.spanningLayoutGuide.systemConstraints];
        [self.spanningLayoutGuide.systemConstraints removeAllObjects];
        
        //FD-spanning-fit
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.spanningLayoutGuide attribute:self.spanningLayoutGuide.isHorizontal ? NSLayoutAttributeWidth : NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
        constraint.priority = 51;
        constraint.identifier = @"FDSV-spanning-fit";
        [self.canvas addConstraint:constraint];
        [self.spanningLayoutGuide.systemConstraints addObject:constraint];
        
        //FDSV-spanning-boundary
        [self.mutableItems enumerateObjectsUsingBlock:^(UIView *item, NSUInteger idx, BOOL *stop) {
            NSLayoutConstraint *minConstraint = [NSLayoutConstraint constraintWithItem:self.spanningLayoutGuide attribute:self.minAttributeForCanvasConnections relatedBy:[self layoutRelationForItemConnectionForAttribute:self.minAttributeForCanvasConnections] toItem:item attribute:self.minAttributeForCanvasConnections multiplier:1 constant:0];
            minConstraint.identifier = @"FDSV-spanning-boundary";
            minConstraint.priority = 999.5;
            [self.canvas addConstraint:minConstraint];
            [self.spanningLayoutGuide.systemConstraints addObject:minConstraint];
            
            NSLayoutConstraint *maxConstraint = [NSLayoutConstraint constraintWithItem:self.spanningLayoutGuide attribute:self.maxAttributeForCanvasConnections relatedBy:[self layoutRelationForItemConnectionForAttribute:self.maxAttributeForCanvasConnections] toItem:item attribute:self.maxAttributeForCanvasConnections multiplier:1 constant:0];
            maxConstraint.identifier = @"FDSV-spanning-boundary";
            maxConstraint.priority = 999.5;
            [self.canvas addConstraint:maxConstraint];
            [self.spanningLayoutGuide.systemConstraints addObject:maxConstraint];
        }];
    }
}

- (void)updateAlignmentItemsConstraintsIfNecessary {
    if (self.mutableItems.count == 0) {
        return;
    }
    
    [self.alignmentConstraints setObject:[NSMapTable weakToWeakObjectsMapTable] forKey:self.alignmentConstraintsFirstKey];
    [self.alignmentConstraints setObject:[NSMapTable weakToWeakObjectsMapTable] forKey:self.alignmentConstraintsSecondKey];
    [self.canvas removeConstraints:self.hiddingDimensionConstraints.fd_allObjects];
    [self.hiddingDimensionConstraints removeAllObjects];
    self.hiddingDimensionConstraints = [NSMapTable weakToStrongObjectsMapTable];
    
    UIView *guardView = self.mutableItems.firstObject;
    [self.mutableItems enumerateObjectsUsingBlock:^(UIView *item, NSUInteger idx, BOOL *stop) {
        if (self.alignment != FDStackViewAlignmentFill) {
            NSLayoutConstraint *ambiguitySuppressionConstraint = [NSLayoutConstraint constraintWithItem:item attribute:self.alignmentConstraintsFirstAttribute relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
            ambiguitySuppressionConstraint.identifier = @"FDSV-ambiguity-suppression";
            ambiguitySuppressionConstraint.priority = 25;
            [item addConstraint:ambiguitySuppressionConstraint];
            [self.alignmentConstraints[self.alignmentConstraintsFirstKey] setObject:ambiguitySuppressionConstraint forKey:item];
        } else {
            if (item != guardView) {
                NSLayoutConstraint *firstConstraint = [NSLayoutConstraint constraintWithItem:guardView attribute:self.alignmentConstraintsFirstAttribute relatedBy:NSLayoutRelationEqual toItem:item attribute:self.alignmentConstraintsFirstAttribute multiplier:1 constant:0];
                firstConstraint.identifier = @"FDSV-alignment";
                [self.canvas addConstraint:firstConstraint];
                [self.alignmentConstraints[self.alignmentConstraintsFirstKey] setObject:firstConstraint forKey:item];
            }
        }
        if (item != guardView) {
            NSLayoutConstraint *secondConstraint = [NSLayoutConstraint constraintWithItem:guardView attribute:self.alignmentConstraintsSecondAttribute relatedBy:NSLayoutRelationEqual toItem:item attribute:self.alignmentConstraintsSecondAttribute multiplier:1 constant:0];
            secondConstraint.identifier = @"FDSV-alignment";
            [self.canvas addConstraint:secondConstraint];
            [self.alignmentConstraints[self.alignmentConstraintsSecondKey] setObject:secondConstraint forKey:item];
        }
        if (item.hidden) {
            NSLayoutConstraint *hiddenConstraint = [NSLayoutConstraint constraintWithItem:item attribute:self.axis == FDLayoutConstraintAxisHorizontal ? NSLayoutAttributeHeight : NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
            hiddenConstraint.priority = [item contentCompressionResistancePriorityForAxis:self.axis == FDLayoutConstraintAxisHorizontal ? FDLayoutConstraintAxisVertical : FDLayoutConstraintAxisHorizontal];
            hiddenConstraint.identifier = @"FDSV-hiding";
            [self.canvas addConstraint:hiddenConstraint];
            [self.hiddingDimensionConstraints setObject:hiddenConstraint forKey:item];
        }
    }];
}

@end
