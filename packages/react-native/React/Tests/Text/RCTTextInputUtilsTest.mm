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

#pragma mark - RCTTextInputChangedRange

- (void)testChangedRangeOfAnInsertion
{
  // "p" typed, then "ri" delivered during a write: inserted at 1, nothing replaced.
  NSRange range = RCTTextInputChangedRange(@"p", @"pri");
  XCTAssertEqual(range.location, 1u);
  XCTAssertEqual(range.length, 0u);
}

- (void)testChangedRangeOfAnInsertionInTheMiddle
{
  NSRange range = RCTTextInputChangedRange(@"Hello World", @"Hello #tag World");
  XCTAssertEqual(range.location, 6u);
  XCTAssertEqual(range.length, 0u);
}

- (void)testChangedRangeOfAReplacement
{
  NSRange range = RCTTextInputChangedRange(@"abcdef", @"abXYef");
  XCTAssertEqual(range.location, 2u);
  XCTAssertEqual(range.length, 2u);
}

- (void)testChangedRangeOfADeletion
{
  NSRange range = RCTTextInputChangedRange(@"abcdef", @"abef");
  XCTAssertEqual(range.location, 2u);
  XCTAssertEqual(range.length, 2u);
}

- (void)testChangedRangeOfARepeatedCharacter
{
  NSRange range = RCTTextInputChangedRange(@"aa", @"aaa");
  XCTAssertEqual(range.length, 0u);
  XCTAssertEqual(range.location, 2u);
}

- (void)testChangedRangeDoesNotSplitAnEmoji
{
  // 👨 and 👩 share their high surrogate.
  NSRange range = RCTTextInputChangedRange(@"a\U0001F468b", @"a\U0001F469b");
  XCTAssertEqual(range.location, 1u);
  XCTAssertEqual(range.length, 2u);
}

- (void)testChangedRangeKeepsACombiningMarkWithItsLetter
{
  // A combining acute accent typed after "e": the edit replaces "e" with "e\u0301".
  NSRange range = RCTTextInputChangedRange(@"cafe", @"cafe\u0301");
  XCTAssertEqual(range.location, 3u);
  XCTAssertEqual(range.length, 1u);
}

- (void)testChangedRangeOfAFlagAndASkinTone
{
  NSRange flag = RCTTextInputChangedRange(@"ab", @"a\U0001F1EF\U0001F1F5b");
  XCTAssertEqual(flag.location, 1u);
  XCTAssertEqual(flag.length, 0u);
  // A skin tone added to 👍 changes that emoji as a whole.
  NSRange tone = RCTTextInputChangedRange(@"\U0001F44D", @"\U0001F44D\U0001F3FD");
  XCTAssertEqual(tone.location, 0u);
  XCTAssertEqual(tone.length, 2u);
}

#pragma mark - RCTTextInputTextToRestore

- (void)testRestoresKeysTypedDuringAnAttributeOnlyWrite
{
  // "p" typed; while JS restyles it (a nested <Text>), "ri" arrive and the write replaces them.
  NSRange range;
  NSString *text;
  XCTAssertTrue(RCTTextInputTextToRestore(@"p", @"pri", @"p", &range, &text));
  XCTAssertEqual(range.location, 1u);
  XCTAssertEqual(range.length, 0u);
  XCTAssertEqualObjects(text, @"ri");
}

- (void)testRestoresABackspaceTypedDuringAnAttributeOnlyWrite
{
  NSRange range;
  NSString *text;
  XCTAssertTrue(RCTTextInputTextToRestore(@"abc", @"ab", @"abc", &range, &text));
  XCTAssertEqual(range.location, 2u);
  XCTAssertEqual(range.length, 1u);
  XCTAssertEqualObjects(text, @"");
}

- (void)testRestoresAnInsertionMadeInTheMiddleDuringAnAttributeOnlyWrite
{
  NSRange range;
  NSString *text;
  XCTAssertTrue(RCTTextInputTextToRestore(@"#a Hello", @"#ab Hello", @"#a Hello", &range, &text));
  XCTAssertEqual(range.location, 2u);
  XCTAssertEqualObjects(text, @"b");
}

- (void)testRestoresKeysTypedDuringAnUpperCasingWrite
{
  // "abc" was typed; JS writes "ABC"; "d" arrived during the write.
  NSRange range;
  NSString *text;
  XCTAssertTrue(RCTTextInputTextToRestore(@"abc", @"abcd", @"ABC", &range, &text));
  XCTAssertEqual(range.location, 3u);
  XCTAssertEqual(range.length, 0u);
  XCTAssertEqualObjects(text, @"d");
}

- (void)testRestoresAnInsertionInTheMiddleAtTheSameDistanceFromTheEnd
{
  // The caret is before "F": "x" was typed, JS upper-cases it, "y" arrived during the write.
  NSRange range;
  NSString *text;
  XCTAssertTrue(RCTTextInputTextToRestore(@"ABCDExF", @"ABCDExyF", @"ABCDEXF", &range, &text));
  XCTAssertEqual(range.location, 6u);
  XCTAssertEqualObjects(text, @"y");
}

- (void)testRestoresAnInsertionWhenJSShortensTheText
{
  // JS strips spaces: "a b" becomes "ab", "c" arrived during the write.
  NSRange range;
  NSString *text;
  XCTAssertTrue(RCTTextInputTextToRestore(@"a b", @"a bc", @"ab", &range, &text));
  XCTAssertEqual(range.location, 2u);
  XCTAssertEqualObjects(text, @"c");
}

- (void)testDoesNotRestoreAReplacementWhenJSChangedTheCharacters
{
  NSRange range;
  NSString *text;
  XCTAssertFalse(RCTTextInputTextToRestore(@"abc", @"ab", @"ABC", &range, &text));
  XCTAssertFalse(RCTTextInputTextToRestore(@"abc", @"abc", @"ABC", &range, &text));
}

- (void)testRestoresAnEmojiWithoutSplittingJSText
{
  // An emoji typed after a flag; JS upper-cased "a" so the characters changed.
  NSString *flag = @"\U0001F1EF\U0001F1F5";
  NSString *family = @"\U0001F468\u200D\U0001F469\u200D\U0001F467";
  NSRange range;
  NSString *text;
  XCTAssertTrue(RCTTextInputTextToRestore(
      [@"a" stringByAppendingString:flag],
      [[@"a" stringByAppendingString:flag] stringByAppendingString:family],
      [@"A" stringByAppendingString:flag],
      &range,
      &text));
  XCTAssertEqual(range.location, 1 + flag.length);
  XCTAssertEqualObjects(text, family);
}

#pragma mark - Attribute variants

- (void)testTextShowsAttributedStringWithLetterSpacing
{
  NSMutableDictionary<NSAttributedStringKey, id> *spaced = [RCTTestTextAttributes() mutableCopy];
  spaced[NSKernAttributeName] = @3;
  NSAttributedString *state = [[NSAttributedString alloc] initWithString:@"abc" attributes:spaced];
  NSMutableDictionary<NSAttributedStringKey, id> *fieldAttributes = [spaced mutableCopy];
  fieldAttributes[NSParagraphStyleAttributeName] = RCTTestTypedParagraphStyle();
  NSAttributedString *field = [[NSAttributedString alloc] initWithString:@"abc" attributes:fieldAttributes];
  XCTAssertTrue(RCTTextInputTextShowsAttributedString(field, state, RCTTestTextAttributes()));

  // JS removing the letter spacing is a change.
  NSAttributedString *plain = [[NSAttributedString alloc] initWithString:@"abc" attributes:RCTTestTextAttributes()];
  XCTAssertFalse(RCTTextInputTextShowsAttributedString(field, plain, RCTTestTextAttributes()));
}

- (void)testTextShowsAttributedStringAlignedRight
{
  NSMutableParagraphStyle *right = [NSParagraphStyle.defaultParagraphStyle mutableCopy];
  right.alignment = NSTextAlignmentRight;
  NSMutableParagraphStyle *shown = [right mutableCopy];
  shown.lineBreakMode = NSLineBreakByTruncatingTail;
  shown.baseWritingDirection = NSWritingDirectionLeftToRight;
  XCTAssertTrue(RCTTextInputTextShowsAttributedString(
      RCTTestStringWithParagraphStyle(@"abc", shown), RCTTestStringWithParagraphStyle(@"abc", right), nil));

  NSMutableParagraphStyle *center = [right mutableCopy];
  center.alignment = NSTextAlignmentCenter;
  XCTAssertFalse(RCTTextInputTextShowsAttributedString(
      RCTTestStringWithParagraphStyle(@"abc", shown), RCTTestStringWithParagraphStyle(@"abc", center), nil));
}

- (void)testTextShowsAttributedStringWrittenRightToLeft
{
  NSString *hebrew = @"\u05E9\u05DC\u05D5\u05DD";
  NSMutableParagraphStyle *rtl = [NSParagraphStyle.defaultParagraphStyle mutableCopy];
  rtl.baseWritingDirection = NSWritingDirectionRightToLeft;
  rtl.alignment = NSTextAlignmentRight;
  NSMutableParagraphStyle *shown = [rtl mutableCopy];
  shown.lineBreakMode = NSLineBreakByTruncatingTail;
  XCTAssertTrue(RCTTextInputTextShowsAttributedString(
      RCTTestStringWithParagraphStyle(hebrew, shown), RCTTestStringWithParagraphStyle(hebrew, rtl), nil));

  // A natural direction that UIKit resolved to right-to-left is not a change; an explicit left-to-right is.
  NSMutableParagraphStyle *natural = [rtl mutableCopy];
  natural.baseWritingDirection = NSWritingDirectionNatural;
  XCTAssertTrue(RCTTextInputTextShowsAttributedString(
      RCTTestStringWithParagraphStyle(hebrew, shown), RCTTestStringWithParagraphStyle(hebrew, natural), nil));
  NSMutableParagraphStyle *ltr = [rtl mutableCopy];
  ltr.baseWritingDirection = NSWritingDirectionLeftToRight;
  XCTAssertFalse(RCTTextInputTextShowsAttributedString(
      RCTTestStringWithParagraphStyle(hebrew, shown), RCTTestStringWithParagraphStyle(hebrew, ltr), nil));
}

- (void)testTextShowsAttributedStringWithEmoji
{
  NSString *emoji =
      @"a\U0001F468\u200D\U0001F469\u200D\U0001F467\u200D\U0001F466b\U0001F44D\U0001F3FDc\U0001F1EF\U0001F1F5de\u0301f";
  NSAttributedString *state = [[NSAttributedString alloc] initWithString:emoji attributes:RCTTestTextAttributes()];
  NSAttributedString *field = RCTTestStringWithParagraphStyle(emoji, RCTTestTypedParagraphStyle());
  XCTAssertTrue(RCTTextInputTextShowsAttributedString(field, state, RCTTestTextAttributes()));
  NSString *precomposed = [emoji stringByReplacingOccurrencesOfString:@"e\u0301" withString:@"\u00E9"];
  XCTAssertFalse(RCTTextInputTextShowsAttributedString(
      RCTTestStringWithParagraphStyle(precomposed, RCTTestTypedParagraphStyle()), state, RCTTestTextAttributes()));
}

@end
