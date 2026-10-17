/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <React/RCTTextInputUtils.h>
#import <React/RCTUITextField.h>
#import <React/RCTUITextView.h>
#import <XCTest/XCTest.h>

@interface RCTTextInputUtilsTest : XCTestCase
@end

@implementation RCTTextInputUtilsTest

- (void)testCopyBackedTextInputPreservesTintColor
{
  RCTUITextField *source = [RCTUITextField new];
  RCTUITextView *destination = [RCTUITextView new];
  source.tintColor = UIColor.redColor;

  RCTCopyBackedTextInput(source, destination);

  XCTAssertEqualObjects(destination.tintColor, UIColor.redColor);
}

- (void)testCopyBackedTextInputPreservesReturnKeyType
{
  RCTUITextField *source = [RCTUITextField new];
  RCTUITextView *destination = [RCTUITextView new];
  source.returnKeyType = UIReturnKeyDone;

  RCTCopyBackedTextInput(source, destination);

  XCTAssertEqual(destination.returnKeyType, UIReturnKeyDone);
}

#pragma mark - RCTTextInputTextShowsAttributedString

static NSDictionary<NSAttributedStringKey, id> *RCTTestTextAttributes(void)
{
  return @{
    NSFontAttributeName : [UIFont systemFontOfSize:14],
    NSForegroundColorAttributeName : UIColor.blackColor,
  };
}

// What UIKit gives text typed into a field whose text attributes set no paragraph style.
static NSParagraphStyle *RCTTestTypedParagraphStyle(void)
{
  NSMutableParagraphStyle *style = [NSParagraphStyle.defaultParagraphStyle mutableCopy];
  style.lineBreakMode = NSLineBreakByTruncatingTail;
  style.baseWritingDirection = NSWritingDirectionLeftToRight;
  return style;
}

static NSAttributedString *RCTTestStringWithParagraphStyle(NSString *string, NSParagraphStyle *style)
{
  NSMutableDictionary<NSAttributedStringKey, id> *attributes = [RCTTestTextAttributes() mutableCopy];
  attributes[NSParagraphStyleAttributeName] = style;
  return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

- (void)testTextShowsAttributedStringWhenTheTextInputOnlyAddsUIKitsDefaultParagraphStyle
{
  // The state built from a controlled `value` has no paragraph style; the typed text has UIKit's default one.
  NSAttributedString *state = [[NSAttributedString alloc] initWithString:@"abc" attributes:RCTTestTextAttributes()];
  NSAttributedString *field = RCTTestStringWithParagraphStyle(@"abc", RCTTestTypedParagraphStyle());

  XCTAssertTrue(RCTTextInputTextShowsAttributedString(field, state, RCTTestTextAttributes()));
}

- (void)testTextShowsAttributedStringWhenTheTextInputOnlyAddsItsDefaultTextAttributes
{
  // The first character typed into an empty field gets the field's default attributes after it reached JS.
  NSMutableDictionary<NSAttributedStringKey, id> *defaults = [RCTTestTextAttributes() mutableCopy];
  defaults[NSBackgroundColorAttributeName] = UIColor.clearColor;
  NSMutableDictionary<NSAttributedStringKey, id> *fieldAttributes = [defaults mutableCopy];
  fieldAttributes[NSParagraphStyleAttributeName] = RCTTestTypedParagraphStyle();
  NSAttributedString *state = [[NSAttributedString alloc] initWithString:@"/" attributes:RCTTestTextAttributes()];
  NSAttributedString *field = [[NSAttributedString alloc] initWithString:@"/" attributes:fieldAttributes];

  XCTAssertTrue(RCTTextInputTextShowsAttributedString(field, state, defaults));
}

- (void)testTextShowsAttributedStringWhoseParagraphStyleASingleLineTextFieldAdjusts
{
  // A controlled single-line input with `lineHeight`: the state's paragraph style has the line height and a natural
  // writing direction; the text field shows it without the line height and with the direction resolved.
  NSMutableParagraphStyle *stateStyle = [NSParagraphStyle.defaultParagraphStyle mutableCopy];
  stateStyle.minimumLineHeight = 26;
  stateStyle.maximumLineHeight = 26;
  stateStyle.lineBreakMode = NSLineBreakByWordWrapping;
  NSMutableParagraphStyle *fieldStyle = [stateStyle mutableCopy];
  fieldStyle.minimumLineHeight = 0;
  fieldStyle.maximumLineHeight = 0;
  fieldStyle.baseWritingDirection = NSWritingDirectionLeftToRight;
  NSAttributedString *state = RCTTestStringWithParagraphStyle(@"p", stateStyle);
  NSAttributedString *field = RCTTestStringWithParagraphStyle(@"p", fieldStyle);

  XCTAssertTrue(RCTTextInputTextShowsAttributedString(field, state, RCTTestTextAttributes()));
}

- (void)testTextDoesNotShowAttributedStringWithAnotherLineHeight
{
  // A multiline input keeps the line height, so a new one from JS is a change.
  NSMutableParagraphStyle *stateStyle = [NSParagraphStyle.defaultParagraphStyle mutableCopy];
  stateStyle.minimumLineHeight = 30;
  stateStyle.maximumLineHeight = 30;
  NSMutableParagraphStyle *fieldStyle = [stateStyle mutableCopy];
  fieldStyle.minimumLineHeight = 26;
  fieldStyle.maximumLineHeight = 26;
  NSAttributedString *state = RCTTestStringWithParagraphStyle(@"abc", stateStyle);
  NSAttributedString *field = RCTTestStringWithParagraphStyle(@"abc", fieldStyle);

  XCTAssertFalse(RCTTextInputTextShowsAttributedString(field, state, RCTTestTextAttributes()));
}

- (void)testTextDoesNotShowAttributedStringWithAnotherAlignment
{
  NSMutableParagraphStyle *centered = [NSParagraphStyle.defaultParagraphStyle mutableCopy];
  centered.alignment = NSTextAlignmentCenter;
  NSAttributedString *state = RCTTestStringWithParagraphStyle(@"abc", centered);
  NSAttributedString *field = RCTTestStringWithParagraphStyle(@"abc", RCTTestTypedParagraphStyle());

  XCTAssertFalse(RCTTextInputTextShowsAttributedString(field, state, RCTTestTextAttributes()));
}

- (void)testTextShowsAttributedStringWithMultipleAttributeRuns
{
  NSMutableAttributedString *state = [[NSMutableAttributedString alloc] initWithString:@"abcd"
                                                                            attributes:RCTTestTextAttributes()];
  [state addAttribute:NSForegroundColorAttributeName value:UIColor.redColor range:NSMakeRange(0, 2)];
  NSMutableAttributedString *field = [state mutableCopy];
  [field addAttribute:NSParagraphStyleAttributeName value:RCTTestTypedParagraphStyle() range:NSMakeRange(0, 4)];

  XCTAssertTrue(RCTTextInputTextShowsAttributedString(field, state, RCTTestTextAttributes()));

  [field addAttribute:NSForegroundColorAttributeName value:UIColor.redColor range:NSMakeRange(2, 1)];
  XCTAssertFalse(RCTTextInputTextShowsAttributedString(field, state, RCTTestTextAttributes()));
}

- (void)testTextShowsAttributedStringForEmptyText
{
  NSAttributedString *empty = [NSAttributedString new];

  XCTAssertTrue(RCTTextInputTextShowsAttributedString(empty, empty, RCTTestTextAttributes()));
}

- (void)testTextDoesNotShowAttributedStringWithOtherCharacters
{
  NSAttributedString *state = [[NSAttributedString alloc] initWithString:@"abc" attributes:RCTTestTextAttributes()];
  NSAttributedString *field = [[NSAttributedString alloc] initWithString:@"abd" attributes:RCTTestTextAttributes()];

  XCTAssertFalse(RCTTextInputTextShowsAttributedString(field, state, RCTTestTextAttributes()));
}

- (void)testTextDoesNotShowAttributedStringThatChangesAnAttribute
{
  NSMutableDictionary<NSAttributedStringKey, id> *restyled = [RCTTestTextAttributes() mutableCopy];
  restyled[NSForegroundColorAttributeName] = UIColor.redColor;
  NSAttributedString *state = [[NSAttributedString alloc] initWithString:@"abc" attributes:restyled];
  NSAttributedString *field = RCTTestStringWithParagraphStyle(@"abc", RCTTestTypedParagraphStyle());

  XCTAssertFalse(RCTTextInputTextShowsAttributedString(field, state, RCTTestTextAttributes()));
}

- (void)testTextDoesNotShowAttributedStringThatRemovesAnAttribute
{
  NSMutableDictionary<NSAttributedStringKey, id> *underlined = [RCTTestTextAttributes() mutableCopy];
  underlined[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
  NSAttributedString *state = [[NSAttributedString alloc] initWithString:@"abc" attributes:RCTTestTextAttributes()];
  NSAttributedString *field = [[NSAttributedString alloc] initWithString:@"abc" attributes:underlined];

  XCTAssertFalse(RCTTextInputTextShowsAttributedString(field, state, RCTTestTextAttributes()));
}

- (void)testTextDoesNotShowAttributedStringWithoutANonDefaultParagraphStyle
{
  NSMutableParagraphStyle *centered = [NSParagraphStyle.defaultParagraphStyle mutableCopy];
  centered.alignment = NSTextAlignmentCenter;
  NSAttributedString *state = [[NSAttributedString alloc] initWithString:@"abc" attributes:RCTTestTextAttributes()];
  NSAttributedString *field = RCTTestStringWithParagraphStyle(@"abc", centered);

  XCTAssertFalse(RCTTextInputTextShowsAttributedString(field, state, RCTTestTextAttributes()));
}

@end
