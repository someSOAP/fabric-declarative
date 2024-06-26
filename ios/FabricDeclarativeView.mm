#import "FabricDeclarativeView.h"

#import <react/renderer/components/RNFabricDeclarativeViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNFabricDeclarativeViewSpec/EventEmitters.h>
#import <react/renderer/components/RNFabricDeclarativeViewSpec/Props.h>
#import <react/renderer/components/RNFabricDeclarativeViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

#if __has_include("react_native_fabric_declarative/react_native_fabric_declarative-Swift.h")
#import "react_native_fabric_declarative/react_native_fabric_declarative-Swift.h"
#else
#import "react_native_fabric_declarative-Swift.h"
#endif

using namespace facebook::react;

@interface FabricDeclarativeView () <RCTFabricDeclarativeViewViewProtocol>

@end

@implementation FabricDeclarativeView {
    SwiftUIViewManager* _manager;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<FabricDeclarativeViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const FabricDeclarativeViewProps>();
    _props = defaultProps;

    _manager = [[SwiftUIViewManager alloc] init];


    self.contentView = [_manager getView];

    _manager.onSubmit = ^(NSString* inputString, double selectedNumber, NSArray<NSNumber*>* restNumbers) {
      [self handleSubmit:inputString selectedNumber:selectedNumber restNumbers:restNumbers];
    };

  }

  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<FabricDeclarativeViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<FabricDeclarativeViewProps const>(props);

    if(oldViewProps.title != newViewProps.title) {
        NSString* newTitle = [[NSString alloc] initWithUTF8String: newViewProps.title.c_str()];

        [_manager updateTitleWithNewTitle:newTitle];
    }

    if(oldViewProps.options != newViewProps.options) {
        NSMutableArray<NSNumber*> *newOptions = [[NSMutableArray alloc] init];

        for (double option : newViewProps.options) {
            [newOptions addObject:@(option)];
        }

        [_manager updateOptionsWithNewOptions:newOptions];
    }

    [super updateProps:props oldProps:oldProps];
}

Class<RCTComponentViewProtocol> FabricDeclarativeViewCls(void)
{
    return FabricDeclarativeView.class;
}


- (void)handleSubmit:(NSString*)inputString selectedNumber:(double)selectedNumber restNumbers:(NSArray<NSNumber*>*) restNumbers
{
  if(!_eventEmitter) {
    return;
  }

  std::vector<double> restNumbersVector = {};

  for (NSNumber* num in restNumbers) {
      restNumbersVector.push_back([num doubleValue]);
  }

  FabricDeclarativeViewEventEmitter::OnSubmit event = {
    .input = [inputString UTF8String],
    .selectedNumber = selectedNumber,
    .objectResults = {
      .restNumbers = restNumbersVector,
      .uppercaseInput = [[inputString uppercaseString] UTF8String]
    }
  };

  std::dynamic_pointer_cast<const FabricDeclarativeViewEventEmitter>(self->_eventEmitter)->onSubmit(event);
}


@end
