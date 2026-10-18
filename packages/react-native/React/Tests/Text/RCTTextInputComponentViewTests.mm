/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <React/RCTBackedTextInputDelegate.h>
#import <React/RCTBackedTextInputViewProtocol.h>
#import <React/RCTTextInputComponentView.h>
#import <React/RCTUITextField.h>
#import <React/RCTUITextView.h>
#import <XCTest/XCTest.h>

#if TARGET_OS_IOS

@interface RCTTextInputComponentView (Tests)
- (void)_setAttributedStringFromJS:(NSAttributedString *)attributedString;
@end

// Inserts `text` where the caret is and tells the delegate, as UIKit does for a key.
static void
RCTTestTypeKeys(UIView<RCTBackedTextInputViewProtocol> *input, NSString *text, void (^setText)(NSAttributedString *))
{
  NSMutableAttributedString *typed = [input.attributedText mutableCopy];
  NSInteger caret = [input offsetFromPosition:input.beginningOfDocument toPosition:input.selectedTextRange.start];
  [typed replaceCharactersInRange:NSMakeRange(caret, 0)
             withAttributedString:[[NSAttributedString alloc] initWithString:text attributes:input.typingAttributes]];
  setText(typed);
  UITextPosition *end = [input positionFromPosition:input.beginningOfDocument offset:caret + text.length];
  [input setSelectedTextRange:[input textRangeFromPosition:end toPosition:end] notifyDelegate:NO];
  [input.textInputDelegate textInputDidChange];
}

// A text field that, like UIKit, delivers the keys queued behind -setAttributedText: inside it: before the new text
// is assigned (a text field), or after (a text view can).
@interface RCTKeysDuringWriteTextField : RCTUITextField
@property (nonatomic, copy, nullable) NSString *keysDuringNextWrite;
@property (nonatomic, assign) BOOL keysArriveAfterAssignment;
@end

@implementation RCTKeysDuringWriteTextField

- (void)setAttributedText:(NSAttributedString *)attributedText
{
  NSString *keys = self.keysDuringNextWrite;
  self.keysDuringNextWrite = nil;
  void (^setText)(NSAttributedString *) = ^(NSAttributedString *text) {
    [super setAttributedText:text];
  };
  if (keys != nil && !self.keysArriveAfterAssignment) {
    RCTTestTypeKeys(self, keys, setText);
  }
  [super setAttributedText:attributedText];
  if (keys != nil && self.keysArriveAfterAssignment) {
    RCTTestTypeKeys(self, keys, setText);
  }
}

@end

@interface RCTTextInputComponentViewTests : XCTestCase
@end

@implementation RCTTextInputComponentViewTests {
  RCTTextInputComponentView *_view;
  RCTKeysDuringWriteTextField *_field;
}

- (void)setUp
{
  [super setUp];
  _view = [[RCTTextInputComponentView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
  UIView *original = [_view valueForKey:@"_backedTextInputView"];
  [original removeFromSuperview];
  _field = [[RCTKeysDuringWriteTextField alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
  _field.textInputDelegate = (id<RCTBackedTextInputDelegate>)_view;
  [_view setValue:_field forKey:@"_backedTextInputView"];
  [_view addSubview:_field];
}

- (void)typeIntoField:(NSString *)text
{
  RCTTestTypeKeys(_field, text, ^(NSAttributedString *typed) {
    self->_field.attributedText = typed;
  });
}

static NSAttributedString *RCTTestStyled(NSString *text, UIColor *color)
{
  return [[NSAttributedString alloc] initWithString:text
                                         attributes:@{
                                           NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
                                           NSForegroundColorAttributeName : color,
                                         }];
}

- (void)testKeysTypedWhileJSRestylesTheTextAreKept
{
  // A nested <Text> styles the first character: JS writes "p" with the child's attributes, and "ri" arrive meanwhile.
  [self typeIntoField:@"p"];
  _field.keysDuringNextWrite = @"ri";

  [_view _setAttributedStringFromJS:RCTTestStyled(@"p", UIColor.blueColor)];

  XCTAssertEqualObjects(_field.attributedText.string, @"pri");
  // JS's style was applied, and the restored keys take it too.
  XCTAssertEqualObjects(
      [_field.attributedText attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL],
      UIColor.blueColor);
  XCTAssertEqualObjects(
      [_field.attributedText attribute:NSForegroundColorAttributeName atIndex:2 effectiveRange:NULL],
      UIColor.blueColor);
}

- (void)testKeysTypedWhileJSTransformsTheTextAreKept
{
  // onChangeText upper-cases: JS writes "ABC" while "d" arrives.
  [self typeIntoField:@"abc"];
  _field.keysDuringNextWrite = @"d";

  [_view _setAttributedStringFromJS:[[NSAttributedString alloc] initWithString:@"ABC"]];

  XCTAssertEqualObjects(_field.attributedText.string, @"ABCd");
}

- (void)testKeysThatArriveAfterTheWriteAreNotDuplicated
{
  [self typeIntoField:@"#a Hello"];
  UITextPosition *afterA = [_field positionFromPosition:_field.beginningOfDocument offset:2];
  [_field setSelectedTextRange:[_field textRangeFromPosition:afterA toPosition:afterA] notifyDelegate:NO];
  _field.keysDuringNextWrite = @"b";
  _field.keysArriveAfterAssignment = YES;

  [_view _setAttributedStringFromJS:RCTTestStyled(@"#a Hello", UIColor.blueColor)];

  NSString *text = _field.attributedText.string;
  XCTAssertEqual([text componentsSeparatedByString:@"b"].count, 2u, @"%@", text);
  XCTAssertEqual(text.length, 9u, @"%@", text);
}

- (void)testAWriteWithNoKeysTypedLeavesJSText
{
  [self typeIntoField:@"abc"];

  [_view _setAttributedStringFromJS:[[NSAttributedString alloc] initWithString:@"ABC"]];

  XCTAssertEqualObjects(_field.attributedText.string, @"ABC");
}

@end

#endif
