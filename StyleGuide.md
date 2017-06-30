# Stripe iOS Objective-C Style Guide

## Ground Rules

### Spacing

- Indent using 4 spaces. No tabs.

- Avoid starting methods with an empty line

- There should not be a need to use multiple consecutive empty lines

- Asterisks should be attached to the variable name `NSString *text` unless it's `NSString * const TextConstant`

### Variable Naming

- Lean towards clarity over compactness

```objc
NSString *title: It is reasonable to assume a “title” is a string.
NSString *titleHTML: This indicates a title that may contain HTML which needs parsing for display. “HTML” is needed for a programmer to use this variable effectively.
NSAttributedString *titleAttributedString: A title, already formatted for display. AttributedString hints that this value is not just a vanilla title, and adding it could be a reasonable choice depending on context.
NSDate *now: No further clarification is needed.
NSDate *lastModifiedDate: Simply lastModified can be ambiguous; depending on context, one could reasonably assume it is one of a few different types.
NSURL *URL vs. NSString *URLString: In situations when a value can reasonably be represented by different classes, it is often useful to disambiguate in the variable’s name.
NSString *releaseDateString: Another example where a value could be represented by another class, and the name can help disambiguate.
```

- Avoid single letter variables. Try using `idx` / `jdx` instead of `i` / `j` in for loops.

- Prefer `urlString` over `URLString`, `baseURLString` over `baseUrlString`, and `stripeID` over `stripeId`

### Control Flow

- Place `else if` and `else` on their own lines

```objc
if (condition) {
    // A
}
else if (condition) {
    // B
}
else {
    // C
}
```

- Always wrap conditional bodies with curly braces

- Use ternary operators sparingly for simple conditions including `a ?: b`

- Something about switches with optional curlys

### Documentation

- Use doc generating syntax

```objc
/// This is a one line description for a simple method
- (void)title;

/**
 This is a multi-line description for a complicated method

 @param

 @see https://...
 */
- (void)title;
```

### Literals

- Use literals for immutable instances of `NSString`, `NSDictionary`, `NSArray`, `NSNumber`:

```objc
NSArray *brands = @[@"visa", @"mastercard", @"discover"];

NSDictionary *parameters = @{
                              @"currency": @"usd",
                              @"amount": @1000,
                            };
```

- Dictionary colons should be attached to the key

- Align multi-line literals using default Xcode indentation

### Constants

- Use static constants

```objc
static NSString * const Thing = @"lol";

static const CGFloat height = 100.0;
```

### Folders

- We use a mostly flat folder structure on disk

- Separate `Stripe` and `StripeTests`

- Separate `PublicHeaders` inside `Stripe/` for Cocoapods compatibility

## Design Patterns

### Imports

- Header imports
  - Import system frameworks
  - Import superclasses and protocols sorted alphabetically
  - Use `@class` for everything else

```objc
#import <Foundation/Foundation.h>

#import "STPAPIResponseDecodable.h"
#import "STPBankAccountParams.h"

@class STPAddress, @STPToken;
```

- Implementation imports
  - Import system frameworks
  - Import corresponding headers
  - Import everything else sorted alphabetically

```objc
#import <PassKit/PassKit.h>

#import "STPSource.h"
#import "STPSource+Private.h"

#import "NSDictionary+Stripe.h"
#import "STPSourceOwner.h"
#import "STPSourceReceiver.h"
#import "STPSourceRedirect.h"
#import "STPSourceVerification.h"
```

### Interfaces and Protocols

- Stick to Xcode default spacing for interfaces, categories, and protocols

- Always use `NS_ASSUME_NON_NULL_BEGIN` / `NS_ASSUME_NON_NULL_END` in headers

```objc
NS_ASSUME_NON_NULL_BEGIN

@protocol STPSourceProtocol <NSObject>

//

@end

...

@interface STPSource : NSObject<STPAPIResponseDecodable, STPSourceProtocol>

//

@end

...

@interface STPSource () <STPInternalAPIResponseDecodable>

//

@end

NS_ASSUME_NON_NULL_END
```

- Category methods on certain classes should be prefixed with `stp_` to avoid collision:

```
@interface NSDictionary (Stripe)

- (NSDictionary *)stp_jsonDictionary;

@end
```

- Define private properties in the class extension of the implementation when necessary

- Use a class extension in a `+Private.h` file to access methods internal to the framework

### Properties

- Properties should be defined using this syntax:

```
@property (<nonatomic / atomic>, <weak / copy / _>, <readonly / readwrite / _>, <nullable / _>) <class> *<name>;

@property (<nonatomic / atomic>, <assign>, <readonly / readwrite / _>) <type> <name>;
```

- Use `copy` for classes with mutable counterparts such as `NSString`, `NSArray`, `NSDictionary`

- Leverage auto property synthesis whenever possible

- Declare `@synthesize` and `@dynamic` on separate lines for shorter diffs

### Init

```objc
- (instancetype)init {
    self = [super init];
    if (self) {
        //
    }
    return self;
}
```

- `[STPCard new]` vs `[[STPCard alloc] init]`

### Methods

```
- (void)setExampleText:(NSString *)text image:(UIImage *)image {

}
```

### Implementation

- In long implementation files, use `#pragma mark -` to group methods

```
#pragma mark - Button Handlers

#pragma mark - UITableViewDataSource

#pragma mark - UITableViewDelegate
```
