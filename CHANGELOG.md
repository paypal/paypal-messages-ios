# Changelog

## [1.0.0-prerelease.4](https://github.com/paypal/paypal-messages-ios/compare/1.0.0-prerelease.3...1.0.0-prerelease.4) (2023-12-08)


### Bug Fixes

* disable code signing ([8b51a79](https://github.com/paypal/paypal-messages-ios/commit/8b51a798615f880421a77ee9df6037c46aa90506))
* inlcude Carthage json file and swift package checksum ([6a2aeae](https://github.com/paypal/paypal-messages-ios/commit/6a2aeae16c634ec0ff4a6ab3ead8323d27bf50ef))
* manually build and assemble xcframework ([c1699f3](https://github.com/paypal/paypal-messages-ios/commit/c1699f3c69da9b582782a78afcd9c1da35a8c8ff))


### Continuous Integration

* temporarily disable release prereq jobs ([53d5ed7](https://github.com/paypal/paypal-messages-ios/commit/53d5ed7f366e01ed76c05c9b0ef2f4ff7e5d3d51))

## [1.0.0-prerelease.3](https://github.com/paypal/paypal-messages-ios/compare/v1.0.0-prerelease.2...1.0.0-prerelease.3) (2023-11-29)


### Bug Fixes

* update git tag format ([877f7c2](https://github.com/paypal/paypal-messages-ios/commit/877f7c2020943c4c744a2b31bd568ea686561505))

## [1.0.0-prerelease.2](https://github.com/paypal/paypal-messages-ios/compare/v1.0.0-prerelease.1...v1.0.0-prerelease.2) (2023-11-28)


### Bug Fixes

* explicit assets included with git release commit ([a058498](https://github.com/paypal/paypal-messages-ios/commit/a058498797e99717ffb549a9a25f3e5b63d5e7d8))

## 1.0.0-prerelease.1 (2023-11-22)


### Bug Fixes

* correctly init AnyCodable for modal event properties ([#10](https://github.com/paypal/paypal-messages-ios/issues/10)) ([d4a0839](https://github.com/paypal/paypal-messages-ios/commit/d4a08399b9a55d115730c5c30a42f74e6e5abac4))
* disable opening modal until message rendered ([#4](https://github.com/paypal/paypal-messages-ios/issues/4)) ([3d09576](https://github.com/paypal/paypal-messages-ios/commit/3d095768746f75ea5079290e2d2210eb275cbab3))
* ensure modal shared key removed from individual events ([#13](https://github.com/paypal/paypal-messages-ios/issues/13)) ([32ae124](https://github.com/paypal/paypal-messages-ios/commit/32ae124bf92e1c51b4947ee4d8efa08a62782de3))
* message and modal accessibility improvements ([#7](https://github.com/paypal/paypal-messages-ios/issues/7)) ([86320e9](https://github.com/paypal/paypal-messages-ios/commit/86320e91c00f45e9ef71740d59a562e2037de33e))
* move credential override off main thread ([#11](https://github.com/paypal/paypal-messages-ios/issues/11)) ([b30c2f8](https://github.com/paypal/paypal-messages-ios/commit/b30c2f81af5dbb60c28059eccbedcbd758971bd5))
* unrecoverable error state after supplying valid client id ([#5](https://github.com/paypal/paypal-messages-ios/issues/5)) ([da5fe52](https://github.com/paypal/paypal-messages-ios/commit/da5fe52ff240624564b5fe561fbd693df9f0f351))


### Code Refactoring

* expose proxy and remove environment default param ([#3](https://github.com/paypal/paypal-messages-ios/issues/3)) ([a8d36d8](https://github.com/paypal/paypal-messages-ios/commit/a8d36d8bf069cc4165448b887026eff7515752b6))
* log endpoint schema and route changes ([#12](https://github.com/paypal/paypal-messages-ios/issues/12)) ([31ba3b5](https://github.com/paypal/paypal-messages-ios/commit/31ba3b5d0f49ea46cc1d1c9615a3094328550fc0))
* pass instance_id ([#9](https://github.com/paypal/paypal-messages-ios/issues/9)) ([6d0668b](https://github.com/paypal/paypal-messages-ios/commit/6d0668bccea0ecd5b3fd9fcc0a6b022f6da5fa2f))


### Tests

* expand unit tests  ([#8](https://github.com/paypal/paypal-messages-ios/issues/8)) ([48e6f0f](https://github.com/paypal/paypal-messages-ios/commit/48e6f0f9c06c3111dc3af0ad4a0e54747b8718c5))


### Continuous Integration

* add workflow_call hook for workflows ([13a0f81](https://github.com/paypal/paypal-messages-ios/commit/13a0f81edb177b3292bf5914960b152fdd97e931))
* initial GitHub Actions setup and test ([#1](https://github.com/paypal/paypal-messages-ios/issues/1)) ([43d9ff0](https://github.com/paypal/paypal-messages-ios/commit/43d9ff03e70e72d0676759cf88b761f4366715f8))
* prerelease prep ([#6](https://github.com/paypal/paypal-messages-ios/issues/6)) ([12cb440](https://github.com/paypal/paypal-messages-ios/commit/12cb4400675bfd0deb62bd8f8747abbfa8219063))
