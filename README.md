# XCode Environment Setup

To use Facebook Image test directory, in Xcode/Product/Edit Scheme: add in Arguments, Environment Variable:

```
FB_REFERENCE_IMAGE_DIR $(SOURCE_ROOT)/connectstatstestapp/samples/ReferenceImages`
```

For RZRegressionManager add

```
RZ_REFERENCE_OBJECT_DIR $(SOURCE_ROOT)/GarminConnectTests/samples/ReferenceObjects
```

# Cocoapods

update pods upon check out

```
pod update
```

