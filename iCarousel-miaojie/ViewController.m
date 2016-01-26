//
//  ViewController.m
//  iCarousel-miaojie
//
//  Created by dl on 16/1/26.
//  Copyright © 2016年 dl. All rights reserved.
//

#import "ViewController.h"
#import "iCarousel.h"

#define TAG_COVER_VIEW 9999

@interface ViewController () <iCarouselDataSource, iCarouselDelegate>
@property (nonatomic, strong) iCarousel *carousel;
@property (nonatomic, assign) CGSize cardSize;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat cardWidth = [UIScreen mainScreen].bounds.size.height*0.5f;
    CGFloat cardHeight = [UIScreen mainScreen].bounds.size.width;
    self.cardSize = CGSizeMake(cardWidth, cardHeight);
    
    self.view.backgroundColor = [UIColor blackColor];
    self.carousel = [[iCarousel alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    self.carousel.bounceDistance = 0.2f;
    self.carousel.type = iCarouselTypeCustom;
    self.carousel.vertical = YES;
    [self.view addSubview:self.carousel];
}

#pragma mark -
#pragma mark iCarouselDataSource
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 15;
}

- (CGFloat) carouselItemWidth:(iCarousel *)carousel
{
    return self.cardSize.width;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable UIView *)view
{
    UIView *cardView = view;
    if (!cardView) {
        cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cardSize.width, self.cardSize.height)];
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:cardView.bounds];
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.backgroundColor = [UIColor whiteColor];
        [cardView addSubview:img];
        
        cardView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:img.frame cornerRadius:5.0f].CGPath;
        cardView.layer.shadowRadius = 3.0f;
        cardView.layer.shadowColor = [UIColor blackColor].CGColor;
        cardView.layer.shadowOpacity = 0.5f;
        cardView.layer.shadowOffset = CGSizeMake(0, 0);
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = img.frame;
        layer.path = [UIBezierPath bezierPathWithRoundedRect:img.frame cornerRadius:5.0f].CGPath;
        img.layer.mask = layer;
        
        UILabel *label = [[UILabel alloc] initWithFrame:cardView.frame];
        label.text = [@(index) stringValue];
                label.font = [UIFont boldSystemFontOfSize:200];
        label.textAlignment = NSTextAlignmentCenter;
        [cardView addSubview:label];
        
        UIView *cover = [[UIView alloc] initWithFrame:cardView.bounds];
        cover.backgroundColor = [UIColor blackColor];
        cover.layer.opacity = 0.3f;
        cover.tag = TAG_COVER_VIEW;
        [cardView addSubview:cover];
    }
    return cardView;
}

#pragma mark -
#pragma mark iCarouselDelegate
- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    CGFloat scale = [self scaleByOffset:offset];
    CGFloat translation = [self translationyOffset:offset];
    transform = CATransform3DRotate(transform, M_PI/2, 0, 0, 1);
    transform = CATransform3DTranslate(transform, translation*self.cardSize.width, 0, offset);
    transform = CATransform3DScale(transform, scale, scale, 1.0f);
    return transform;
}

- (void) carouselDidScroll:(iCarousel *)carousel
{
    for (UIView *v in carousel.visibleItemViews) {
        CGFloat offset = [carousel offsetForItemAtIndex:[carousel indexOfItemView:v]];
        UIView *cover = [v viewWithTag:TAG_COVER_VIEW];
        if (fabs(offset)>1.0f) {
            offset = 1.0f;
        }
        cover.layer.opacity = fabs(offset*0.3f);
    }
}

- (void) carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"didSelectItemAtIndex:%ld", index);
}

- (CGFloat) carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option) {
        case iCarouselOptionVisibleItems:
            return 15;
            break;
        case iCarouselOptionWrap:
            return YES;
            break;
        default:
            break;
    }
    return value;
}
#pragma mark -
#pragma mark custom func
//形变是线性的就ok了
- (CGFloat) scaleByOffset:(CGFloat) offset
{
    return 1.0f;
}

//位移通过得到的公式来计算
- (CGFloat) translationyOffset:(CGFloat) offset
{
    if (offset>=0 && offset<1) {
        return offset-0.5f;
    } else if (offset<0) {
        return offset*0.5f-0.5f;
    }
    return 0.5f+(offset-1.f)*5.0f/12.0f;
}

@end