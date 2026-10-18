/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTTextInputUtils.h"

#import <React/RCTConversions.h>

#import <vector>

using namespace facebook::react;

static NSAttributedString *RCTSanitizeAttributedString(NSAttributedString *attributedString)
{
  // Here we need to remove text attributes specific to particular kind of TextInput on iOS (e.g. limiting line number).
  // TODO: Implement it properly.
  return [[NSAttributedString alloc] initWithString:attributedString.string];
}

void RCTCopyBackedTextInput(
    UIView<RCTBackedTextInputViewProtocol> *fromTextInput,
    UIView<RCTBackedTextInputViewProtocol> *toTextInput)
{
  toTextInput.attributedText = RCTSanitizeAttributedString(fromTextInput.attributedText);
  toTextInput.placeholder = fromTextInput.placeholder;
  toTextInput.placeholderColor = fromTextInput.placeholderColor;
  toTextInput.tintColor = fromTextInput.tintColor;
  toTextInput.textContainerInset = fromTextInput.textContainerInset;
  toTextInput.inputAccessoryView = fromTextInput.inputAccessoryView;
  toTextInput.textInputDelegate = fromTextInput.textInputDelegate;
  toTextInput.placeholderColor = fromTextInput.placeholderColor;
  toTextInput.defaultTextAttributes = fromTextInput.defaultTextAttributes;
  toTextInput.autocapitalizationType = fromTextInput.autocapitalizationType;
  toTextInput.autocorrectionType = fromTextInput.autocorrectionType;
  toTextInput.contextMenuHidden = fromTextInput.contextMenuHidden;
  toTextInput.editable = fromTextInput.editable;
  toTextInput.enablesReturnKeyAutomatically = fromTextInput.enablesReturnKeyAutomatically;
  toTextInput.keyboardAppearance = fromTextInput.keyboardAppearance;
  toTextInput.spellCheckingType = fromTextInput.spellCheckingType;
  toTextInput.caretHidden = fromTextInput.caretHidden;
  toTextInput.clearButtonMode = fromTextInput.clearButtonMode;
  toTextInput.scrollEnabled = fromTextInput.scrollEnabled;
  toTextInput.secureTextEntry = fromTextInput.secureTextEntry;
  toTextInput.keyboardType = fromTextInput.keyboardType;
  toTextInput.returnKeyType = fromTextInput.returnKeyType;
  toTextInput.textContentType = fromTextInput.textContentType;
  toTextInput.smartInsertDeleteType = fromTextInput.smartInsertDeleteType;
  toTextInput.passwordRules = fromTextInput.passwordRules;
  toTextInput.disableKeyboardShortcuts = fromTextInput.disableKeyboardShortcuts;
  toTextInput.acceptDragAndDropTypes = fromTextInput.acceptDragAndDropTypes;

  [toTextInput setSelectedTextRange:fromTextInput.selectedTextRange notifyDelegate:NO];
}

UITextAutocorrectionType RCTUITextAutocorrectionTypeFromOptionalBool(std::optional<bool> autoCorrect)
{
  return autoCorrect.has_value() ? (*autoCorrect ? UITextAutocorrectionTypeYes : UITextAutocorrectionTypeNo)
                                 : UITextAutocorrectionTypeDefault;
}

UITextAutocapitalizationType RCTUITextAutocapitalizationTypeFromAutocapitalizationType(
    AutocapitalizationType autocapitalizationType)
{
  switch (autocapitalizationType) {
    case AutocapitalizationType::None:
      return UITextAutocapitalizationTypeNone;
    case AutocapitalizationType::Words:
      return UITextAutocapitalizationTypeWords;
    case AutocapitalizationType::Sentences:
      return UITextAutocapitalizationTypeSentences;
    case AutocapitalizationType::Characters:
      return UITextAutocapitalizationTypeAllCharacters;
  }
}

UIKeyboardAppearance RCTUIKeyboardAppearanceFromKeyboardAppearance(KeyboardAppearance keyboardAppearance)
{
  switch (keyboardAppearance) {
    case KeyboardAppearance::Default:
      return UIKeyboardAppearanceDefault;
    case KeyboardAppearance::Light:
      return UIKeyboardAppearanceLight;
    case KeyboardAppearance::Dark:
      return UIKeyboardAppearanceDark;
  }
}

UITextSpellCheckingType RCTUITextSpellCheckingTypeFromOptionalBool(std::optional<bool> spellCheck)
{
  return spellCheck.has_value() ? (*spellCheck ? UITextSpellCheckingTypeYes : UITextSpellCheckingTypeNo)
                                : UITextSpellCheckingTypeDefault;
}

UITextFieldViewMode RCTUITextFieldViewModeFromTextInputAccessoryVisibilityMode(
    facebook::react::TextInputAccessoryVisibilityMode mode)
{
  switch (mode) {
    case TextInputAccessoryVisibilityMode::Never:
      return UITextFieldViewModeNever;
    case TextInputAccessoryVisibilityMode::WhileEditing:
      return UITextFieldViewModeWhileEditing;
    case TextInputAccessoryVisibilityMode::UnlessEditing:
      return UITextFieldViewModeUnlessEditing;
    case TextInputAccessoryVisibilityMode::Always:
      return UITextFieldViewModeAlways;
  }
}

UIKeyboardType RCTUIKeyboardTypeFromKeyboardType(KeyboardType keyboardType)
{
  switch (keyboardType) {
    // Universal
    case KeyboardType::Default:
      return UIKeyboardTypeDefault;
    case KeyboardType::EmailAddress:
      return UIKeyboardTypeEmailAddress;
    case KeyboardType::Numeric:
      return UIKeyboardTypeDecimalPad;
    case KeyboardType::PhonePad:
      return UIKeyboardTypePhonePad;
    case KeyboardType::NumberPad:
      return UIKeyboardTypeNumberPad;
    case KeyboardType::DecimalPad:
      return UIKeyboardTypeDecimalPad;
    // iOS-only
    case KeyboardType::ASCIICapable:
      return UIKeyboardTypeASCIICapable;
    case KeyboardType::NumbersAndPunctuation:
      return UIKeyboardTypeNumbersAndPunctuation;
    case KeyboardType::URL:
      return UIKeyboardTypeURL;
    case KeyboardType::NamePhonePad:
      return UIKeyboardTypeNamePhonePad;
    case KeyboardType::Twitter:
      return UIKeyboardTypeTwitter;
    case KeyboardType::WebSearch:
      return UIKeyboardTypeWebSearch;
    case KeyboardType::ASCIICapableNumberPad:
      return UIKeyboardTypeASCIICapableNumberPad;
    // Android-only
    case KeyboardType::VisiblePassword:
      return UIKeyboardTypeDefault;
  }
}

UIReturnKeyType RCTUIReturnKeyTypeFromReturnKeyType(ReturnKeyType returnKeyType)
{
  switch (returnKeyType) {
    case ReturnKeyType::Default:
      return UIReturnKeyDefault;
    case ReturnKeyType::Done:
      return UIReturnKeyDone;
    case ReturnKeyType::Go:
      return UIReturnKeyGo;
    case ReturnKeyType::Next:
      return UIReturnKeyNext;
    case ReturnKeyType::Search:
      return UIReturnKeySearch;
    case ReturnKeyType::Send:
      return UIReturnKeySend;
    // iOS-only
    case ReturnKeyType::EmergencyCall:
      return UIReturnKeyEmergencyCall;
    case ReturnKeyType::Google:
      return UIReturnKeyGoogle;
    case ReturnKeyType::Join:
      return UIReturnKeyJoin;
    case ReturnKeyType::Route:
      return UIReturnKeyRoute;
    case ReturnKeyType::Yahoo:
      return UIReturnKeyYahoo;
    case ReturnKeyType::Continue:
      return UIReturnKeyContinue;
    // Android-only
    case ReturnKeyType::None:
    case ReturnKeyType::Previous:
      return UIReturnKeyDefault;
  }
}

UITextContentType RCTUITextContentTypeFromString(const std::string &contentType)
{
  static dispatch_once_t onceToken;
  static NSDictionary<NSString *, NSString *> *contentTypeMap;

  dispatch_once(&onceToken, ^{
    NSMutableDictionary<NSString *, NSString *> *mutableContentTypeMap = [NSMutableDictionary new];
    [mutableContentTypeMap addEntriesFromDictionary:@{
      @"" : @"",
      @"none" : @"",
      @"URL" : UITextContentTypeURL,
      @"addressCity" : UITextContentTypeAddressCity,
      @"addressCityAndState" : UITextContentTypeAddressCityAndState,
      @"addressState" : UITextContentTypeAddressState,
      @"countryName" : UITextContentTypeCountryName,
      @"creditCardNumber" : UITextContentTypeCreditCardNumber,
      @"emailAddress" : UITextContentTypeEmailAddress,
      @"familyName" : UITextContentTypeFamilyName,
      @"fullStreetAddress" : UITextContentTypeFullStreetAddress,
      @"givenName" : UITextContentTypeGivenName,
      @"jobTitle" : UITextContentTypeJobTitle,
      @"location" : UITextContentTypeLocation,
      @"middleName" : UITextContentTypeMiddleName,
      @"name" : UITextContentTypeName,
      @"namePrefix" : UITextContentTypeNamePrefix,
      @"nameSuffix" : UITextContentTypeNameSuffix,
      @"nickname" : UITextContentTypeNickname,
      @"organizationName" : UITextContentTypeOrganizationName,
      @"postalCode" : UITextContentTypePostalCode,
      @"streetAddressLine1" : UITextContentTypeStreetAddressLine1,
      @"streetAddressLine2" : UITextContentTypeStreetAddressLine2,
      @"sublocality" : UITextContentTypeSublocality,
      @"telephoneNumber" : UITextContentTypeTelephoneNumber,
      @"username" : UITextContentTypeUsername,
      @"password" : UITextContentTypePassword,
      @"newPassword" : UITextContentTypeNewPassword,
      @"oneTimeCode" : UITextContentTypeOneTimeCode,
    }];

    if (@available(iOS 15.0, tvOS 15.0, *)) {
      [mutableContentTypeMap addEntriesFromDictionary:@{
        @"dateTime" : UITextContentTypeDateTime,
        @"flightNumber" : UITextContentTypeFlightNumber,
        @"shipmentTrackingNumber" : UITextContentTypeShipmentTrackingNumber,
      }];
    }

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 170000 /* __IPHONE_17_0 */
    if (@available(iOS 17.0, tvOS 17.0, *)) {
      [mutableContentTypeMap addEntriesFromDictionary:@{
        @"creditCardExpiration" : UITextContentTypeCreditCardExpiration,
        @"creditCardExpirationMonth" : UITextContentTypeCreditCardExpirationMonth,
        @"creditCardExpirationYear" : UITextContentTypeCreditCardExpirationYear,
        @"creditCardSecurityCode" : UITextContentTypeCreditCardSecurityCode,
        @"creditCardType" : UITextContentTypeCreditCardType,
        @"creditCardName" : UITextContentTypeCreditCardName,
        @"creditCardGivenName" : UITextContentTypeCreditCardGivenName,
        @"creditCardMiddleName" : UITextContentTypeCreditCardMiddleName,
        @"creditCardFamilyName" : UITextContentTypeCreditCardFamilyName,
        @"birthdate" : UITextContentTypeBirthdate,
        @"birthdateDay" : UITextContentTypeBirthdateDay,
        @"birthdateMonth" : UITextContentTypeBirthdateMonth,
        @"birthdateYear" : UITextContentTypeBirthdateYear,
      }];
    }

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 170400 /* __IPHONE_17_4 */
    if (@available(iOS 17.4, *)) {
      [mutableContentTypeMap addEntriesFromDictionary:@{
        @"cellularEID" : UITextContentTypeCellularEID,
        @"cellularIMEI" : UITextContentTypeCellularIMEI,
      }];
    }
#endif
#endif

    contentTypeMap = mutableContentTypeMap;
  });

  return contentTypeMap[RCTNSStringFromString(contentType)] ?: @"";
}

UITextInputPasswordRules *RCTUITextInputPasswordRulesFromString(const std::string &passwordRules)
{
  return [UITextInputPasswordRules passwordRulesWithDescriptor:RCTNSStringFromStringNilIfEmpty(passwordRules)];
}

UITextSmartInsertDeleteType RCTUITextSmartInsertDeleteTypeFromOptionalBool(std::optional<bool> smartInsertDelete)
{
  return smartInsertDelete.has_value()
      ? (*smartInsertDelete ? UITextSmartInsertDeleteTypeYes : UITextSmartInsertDeleteTypeNo)
      : UITextSmartInsertDeleteTypeDefault;
}

// Whether a text input showing `style` shows the paragraph style `expected` (nil: UIKit's default paragraph style).
// UIKit adjusts the paragraph style of the text a field shows: it sets its own line break mode, resolves a natural
// writing direction, and a single-line text field drops the minimum and maximum line height. None of these are
// changes to write back.
static BOOL RCTTextInputParagraphStyleShows(NSParagraphStyle *_Nullable style, NSParagraphStyle *_Nullable expected)
{
  NSParagraphStyle *shown = style ?: NSParagraphStyle.defaultParagraphStyle;
  NSMutableParagraphStyle *adjusted = [(expected ?: NSParagraphStyle.defaultParagraphStyle) mutableCopy];
  adjusted.lineBreakMode = shown.lineBreakMode;
  if (adjusted.baseWritingDirection == NSWritingDirectionNatural) {
    adjusted.baseWritingDirection = shown.baseWritingDirection;
  }
  if (shown.minimumLineHeight == 0 && shown.maximumLineHeight == 0) {
    adjusted.minimumLineHeight = 0;
    adjusted.maximumLineHeight = 0;
  }
  return [shown isEqual:adjusted];
}

BOOL RCTTextInputTextShowsAttributedString(
    NSAttributedString *textInputText,
    NSAttributedString *attributedString,
    NSDictionary<NSAttributedStringKey, id> *_Nullable defaultTextAttributes)
{
  if (![attributedString.string isEqualToString:textInputText.string]) {
    return NO;
  }
  NSUInteger index = 0;
  while (index < attributedString.length) {
    NSRange range;
    NSRange textInputRange;
    NSDictionary<NSAttributedStringKey, id> *attributes = [attributedString attributesAtIndex:index
                                                                               effectiveRange:&range];
    NSDictionary<NSAttributedStringKey, id> *textInputAttributes = [textInputText attributesAtIndex:index
                                                                                     effectiveRange:&textInputRange];
    for (NSAttributedStringKey key in attributes) {
      if (![key isEqualToString:NSParagraphStyleAttributeName] && ![attributes[key] isEqual:textInputAttributes[key]]) {
        return NO;
      }
    }
    for (NSAttributedStringKey key in textInputAttributes) {
      if (![key isEqualToString:NSParagraphStyleAttributeName] && attributes[key] == nil &&
          ![textInputAttributes[key] isEqual:defaultTextAttributes[key]]) {
        return NO;
      }
    }
    // The paragraph style: the one the string sets, or if it sets none, UIKit's default or the input's default.
    id style = textInputAttributes[NSParagraphStyleAttributeName];
    id expected = attributes[NSParagraphStyleAttributeName];
    if (style != nil && ![style isKindOfClass:[NSParagraphStyle class]]) {
      return NO;
    }
    if (expected != nil
            ? !RCTTextInputParagraphStyleShows(style, expected)
            : !(RCTTextInputParagraphStyleShows(style, nil) ||
                RCTTextInputParagraphStyleShows(style, defaultTextAttributes[NSParagraphStyleAttributeName]))) {
      return NO;
    }
    index = MIN(NSMaxRange(range), NSMaxRange(textInputRange));
  }
  return YES;
}

// The end of the composed character sequence (an emoji, a letter with combining marks) that `index` falls in.
static NSUInteger RCTComposedSequenceBoundaryAtOrAfter(NSString *text, NSUInteger index)
{
  if (index == 0 || index >= text.length) {
    return index;
  }
  NSRange sequence = [text rangeOfComposedCharacterSequenceAtIndex:index];
  return sequence.location < index ? NSMaxRange(sequence) : index;
}

NSRange RCTTextInputChangedRange(NSString *oldText, NSString *newText)
{
  std::vector<unichar> oldCharacters(oldText.length);
  std::vector<unichar> newCharacters(newText.length);
  [oldText getCharacters:oldCharacters.data() range:NSMakeRange(0, oldText.length)];
  [newText getCharacters:newCharacters.data() range:NSMakeRange(0, newText.length)];
  NSUInteger shorter = MIN(oldCharacters.size(), newCharacters.size());
  NSUInteger prefix = 0;
  while (prefix < shorter && oldCharacters[prefix] == newCharacters[prefix]) {
    prefix++;
  }
  NSUInteger suffix = 0;
  while (suffix < shorter - prefix &&
         oldCharacters[oldCharacters.size() - 1 - suffix] == newCharacters[newCharacters.size() - 1 - suffix]) {
    suffix++;
  }
  // Don't split a composed character sequence: the edit starts and ends on sequence boundaries of both texts.
  if (prefix < oldText.length) {
    prefix = MIN(prefix, [oldText rangeOfComposedCharacterSequenceAtIndex:prefix].location);
  }
  if (prefix < newText.length) {
    prefix = MIN(prefix, [newText rangeOfComposedCharacterSequenceAtIndex:prefix].location);
  }
  suffix = MIN(suffix, MIN(oldText.length, newText.length) - prefix);
  NSUInteger oldEnd = RCTComposedSequenceBoundaryAtOrAfter(oldText, oldText.length - suffix);
  NSUInteger newEnd = RCTComposedSequenceBoundaryAtOrAfter(newText, newText.length - suffix);
  suffix = MIN(oldText.length - oldEnd, newText.length - newEnd);
  return NSMakeRange(prefix, oldText.length - prefix - suffix);
}

BOOL RCTTextInputTextToRestore(
    NSString *textBeforeUpdate,
    NSString *typedText,
    NSString *writtenText,
    NSRange *range,
    NSString *_Nullable *_Nonnull text)
{
  if ([typedText isEqualToString:textBeforeUpdate]) {
    return NO;
  }
  NSRange replaced = RCTTextInputChangedRange(textBeforeUpdate, typedText);
  NSUInteger insertedLength = typedText.length - (textBeforeUpdate.length - replaced.length);
  NSString *inserted = [typedText substringWithRange:NSMakeRange(replaced.location, insertedLength)];
  if (![writtenText isEqualToString:textBeforeUpdate]) {
    // JS changed the characters: put back an insertion only, at the same distance from the end of the text.
    if (replaced.length > 0 || insertedLength == 0) {
      return NO;
    }
    NSUInteger distanceFromEnd = textBeforeUpdate.length - replaced.location;
    NSUInteger location = writtenText.length > distanceFromEnd ? writtenText.length - distanceFromEnd : 0;
    if (location < writtenText.length) {
      location = [writtenText rangeOfComposedCharacterSequenceAtIndex:location].location;
    }
    replaced = NSMakeRange(location, 0);
  }
  *range = replaced;
  *text = inserted;
  return YES;
}

#if !TARGET_OS_TV
UIDataDetectorTypes RCTUITextViewDataDetectorTypesFromStringVector(const std::vector<std::string> &dataDetectorTypes)
{
  static dispatch_once_t onceToken;
  static NSDictionary<NSString *, NSNumber *> *dataDetectorTypesMap = nil;

  dispatch_once(&onceToken, ^{
    dataDetectorTypesMap = @{
      @"link" : @(UIDataDetectorTypeLink),
      @"phoneNumber" : @(UIDataDetectorTypePhoneNumber),
      @"address" : @(UIDataDetectorTypeAddress),
      @"calendarEvent" : @(UIDataDetectorTypeCalendarEvent),
      @"trackingNumber" : @(UIDataDetectorTypeShipmentTrackingNumber),
      @"flightNumber" : @(UIDataDetectorTypeFlightNumber),
      @"lookupSuggestion" : @(UIDataDetectorTypeLookupSuggestion),
      @"all" : @(UIDataDetectorTypeAll)
    };
  });

  UIDataDetectorTypes ret = UIDataDetectorTypeNone;
  for (const auto &dataType : dataDetectorTypes) {
    NSNumber *val = dataDetectorTypesMap[RCTNSStringFromString(dataType)];
    if (val) {
      ret |= (UIDataDetectorTypes)val.unsignedIntegerValue;
    }
  }
  return ret;
}
#endif
