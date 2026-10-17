/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <optional>

#import <React/RCTBackedTextInputViewProtocol.h>
#import <react/renderer/components/iostextinput/primitives.h>

NS_ASSUME_NONNULL_BEGIN

void RCTCopyBackedTextInput(
    UIView<RCTBackedTextInputViewProtocol> *fromTextInput,
    UIView<RCTBackedTextInputViewProtocol> *toTextInput);

UITextAutocorrectionType RCTUITextAutocorrectionTypeFromOptionalBool(std::optional<bool> autoCorrect);

UITextAutocapitalizationType RCTUITextAutocapitalizationTypeFromAutocapitalizationType(
    facebook::react::AutocapitalizationType autocapitalizationType);

UIKeyboardAppearance RCTUIKeyboardAppearanceFromKeyboardAppearance(
    facebook::react::KeyboardAppearance keyboardAppearance);

UITextSpellCheckingType RCTUITextSpellCheckingTypeFromOptionalBool(std::optional<bool> spellCheck);

UITextFieldViewMode RCTUITextFieldViewModeFromTextInputAccessoryVisibilityMode(
    facebook::react::TextInputAccessoryVisibilityMode mode);

UIKeyboardType RCTUIKeyboardTypeFromKeyboardType(facebook::react::KeyboardType keyboardType);

UIReturnKeyType RCTUIReturnKeyTypeFromReturnKeyType(facebook::react::ReturnKeyType returnKeyType);

UITextContentType RCTUITextContentTypeFromString(const std::string &contentType);

UITextInputPasswordRules *RCTUITextInputPasswordRulesFromString(const std::string &passwordRules);

UITextSmartInsertDeleteType RCTUITextSmartInsertDeleteTypeFromOptionalBool(std::optional<bool> smartInsertDelete);

/*
 * Whether `textInputText`, the text a backed text input shows, already shows `attributedString`: the same characters,
 * every attribute `attributedString` sets has the same value in `textInputText`, and every attribute only
 * `textInputText` has is a default: its value in `defaultTextAttributes`, or UIKit's default paragraph style (which
 * UIKit gives typed text when the text attributes set no paragraph style). Paragraph styles are compared as UIKit
 * shows them: its line break mode, a natural writing direction resolved, and no line height in a single-line text
 * field. An attribute that `attributedString` removes is not a default, so that change still counts as a difference.
 */
BOOL RCTTextInputTextShowsAttributedString(
    NSAttributedString *textInputText,
    NSAttributedString *attributedString,
    NSDictionary<NSAttributedStringKey, id> *_Nullable defaultTextAttributes);

#if !TARGET_OS_TV
UIDataDetectorTypes RCTUITextViewDataDetectorTypesFromStringVector(const std::vector<std::string> &dataDetectorTypes);
#endif

NS_ASSUME_NONNULL_END
