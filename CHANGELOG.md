# Changelog

## 1.0.0-alpha.1 (2024-04-22)


### Features

* message and modal close button alternative a11y text ([#28](https://github.com/paypal/paypal-messages-ios/issues/28)) ([f017015](https://github.com/paypal/paypal-messages-ios/commit/f01701556f4dcf4b9ec8776caa50ab3550e4d820))


### Bug Fixes

* correctly init AnyCodable for modal event properties ([#10](https://github.com/paypal/paypal-messages-ios/issues/10)) ([d4a0839](https://github.com/paypal/paypal-messages-ios/commit/d4a08399b9a55d115730c5c30a42f74e6e5abac4))
* disable opening modal until message rendered ([#4](https://github.com/paypal/paypal-messages-ios/issues/4)) ([3d09576](https://github.com/paypal/paypal-messages-ios/commit/3d095768746f75ea5079290e2d2210eb275cbab3))
* ensure modal shared key removed from individual events ([#13](https://github.com/paypal/paypal-messages-ios/issues/13)) ([32ae124](https://github.com/paypal/paypal-messages-ios/commit/32ae124bf92e1c51b4947ee4d8efa08a62782de3))
* logger uses updated message and modal properties ([#21](https://github.com/paypal/paypal-messages-ios/issues/21)) ([6b9e949](https://github.com/paypal/paypal-messages-ios/commit/6b9e949e01d0550ba578ed6c44fe656ef5a728e4))
* message and modal accessibility improvements ([#7](https://github.com/paypal/paypal-messages-ios/issues/7)) ([86320e9](https://github.com/paypal/paypal-messages-ios/commit/86320e91c00f45e9ef71740d59a562e2037de33e))
* move credential override off main thread ([#11](https://github.com/paypal/paypal-messages-ios/issues/11)) ([b30c2f8](https://github.com/paypal/paypal-messages-ios/commit/b30c2f81af5dbb60c28059eccbedcbd758971bd5))
* pass env param to log functions ([#31](https://github.com/paypal/paypal-messages-ios/issues/31)) ([610d9e3](https://github.com/paypal/paypal-messages-ios/commit/610d9e32f0dcaeec220460997369334510b57bc4))
* unrecoverable error state after supplying valid client id ([#5](https://github.com/paypal/paypal-messages-ios/issues/5)) ([da5fe52](https://github.com/paypal/paypal-messages-ios/commit/da5fe52ff240624564b5fe561fbd693df9f0f351))


### Code Refactoring

* add privacy manifest file and remove tracking IDs ([#30](https://github.com/paypal/paypal-messages-ios/issues/30)) ([8400d96](https://github.com/paypal/paypal-messages-ios/commit/8400d96c13f7ba481a00e521bff8135dcfa0df03))
* expose proxy and remove environment default param ([#3](https://github.com/paypal/paypal-messages-ios/issues/3)) ([a8d36d8](https://github.com/paypal/paypal-messages-ios/commit/a8d36d8bf069cc4165448b887026eff7515752b6))
* include default device ID and session ID values ([#25](https://github.com/paypal/paypal-messages-ios/issues/25)) ([e34fc94](https://github.com/paypal/paypal-messages-ios/commit/e34fc947433459b08c08ec6f7e164465d92ba589))
* include response details when message failure ([#29](https://github.com/paypal/paypal-messages-ios/issues/29)) ([dd1c478](https://github.com/paypal/paypal-messages-ios/commit/dd1c478b4a9558c17d8285abbad6e121141add83))
* log endpoint schema and route changes ([#12](https://github.com/paypal/paypal-messages-ios/issues/12)) ([31ba3b5](https://github.com/paypal/paypal-messages-ios/commit/31ba3b5d0f49ea46cc1d1c9615a3094328550fc0))
* move stageTag and devTouchpoint options to Environment enum ([#15](https://github.com/paypal/paypal-messages-ios/issues/15)) ([d4a9d4a](https://github.com/paypal/paypal-messages-ios/commit/d4a9d4a7b02f863d305345f0e3be647c3c26e84d))
* pass instance_id ([#9](https://github.com/paypal/paypal-messages-ios/issues/9)) ([6d0668b](https://github.com/paypal/paypal-messages-ios/commit/6d0668bccea0ecd5b3fd9fcc0a6b022f6da5fa2f))
* pass message view model dependencies from message view ([#20](https://github.com/paypal/paypal-messages-ios/issues/20)) ([9a98326](https://github.com/paypal/paypal-messages-ios/commit/9a98326d336f53e75b2894f472c97ec643b7b0cc))
* placement to pageType and textAlignment to textAlign ([#26](https://github.com/paypal/paypal-messages-ios/issues/26)) ([d2ffdd4](https://github.com/paypal/paypal-messages-ios/commit/d2ffdd4999ca2673be4705b8c034d29c3f4b7009))
* remove currency references ([#14](https://github.com/paypal/paypal-messages-ios/issues/14)) ([751c903](https://github.com/paypal/paypal-messages-ios/commit/751c9039c9172cc6abb4820f5619365b26867c6b))
* rename stage environment value to develop ([#27](https://github.com/paypal/paypal-messages-ios/issues/27)) ([83557df](https://github.com/paypal/paypal-messages-ios/commit/83557df382c9347528b0d563bb34a40c859a1356))
* store merchant profile data by client ID and merchant ID ([#19](https://github.com/paypal/paypal-messages-ios/issues/19)) ([a502a4f](https://github.com/paypal/paypal-messages-ios/commit/a502a4f97387d8b39f7126f0560610336a630d7e))


### Tests

* expand unit tests  ([#8](https://github.com/paypal/paypal-messages-ios/issues/8)) ([48e6f0f](https://github.com/paypal/paypal-messages-ios/commit/48e6f0f9c06c3111dc3af0ad4a0e54747b8718c5))
* expose view model flush method for consistent tests ([#24](https://github.com/paypal/paypal-messages-ios/issues/24)) ([9c1406f](https://github.com/paypal/paypal-messages-ios/commit/9c1406f85ddde167a3d3ca4e38ae9201f606141f))


### Continuous Integration

* codesign xcframework build ([90599d0](https://github.com/paypal/paypal-messages-ios/commit/90599d010b29686fd0b2bc7f4d8ff883dbc8904f))
* fix linting and test coverage ([#17](https://github.com/paypal/paypal-messages-ios/issues/17)) ([3eeebea](https://github.com/paypal/paypal-messages-ios/commit/3eeebea050de1fff07df42df87168b77dbd6611d))
* initial GitHub Actions setup and test ([#1](https://github.com/paypal/paypal-messages-ios/issues/1)) ([43d9ff0](https://github.com/paypal/paypal-messages-ios/commit/43d9ff03e70e72d0676759cf88b761f4366715f8))
* initial prerelease fixes ([#16](https://github.com/paypal/paypal-messages-ios/issues/16)) ([43cffed](https://github.com/paypal/paypal-messages-ios/commit/43cffedf83d0454c32dc7cf8a0d613c5bbe53d18))
* prerelease prep ([#6](https://github.com/paypal/paypal-messages-ios/issues/6)) ([12cb440](https://github.com/paypal/paypal-messages-ios/commit/12cb4400675bfd0deb62bd8f8747abbfa8219063))

## [1.0.0-prerelease.6](https://github.com/paypal/paypal-messages-ios/compare/1.0.0-prerelease.5...1.0.0-prerelease.6) (2023-12-14)


### Bug Fixes

* undo excluded archs from the project file ([367a390](https://github.com/paypal/paypal-messages-ios/commit/367a3904a64a22e9ace233db43619389bcd22666))

## [1.0.0-prerelease.5](https://github.com/paypal/paypal-messages-ios/compare/1.0.0-prerelease.4...1.0.0-prerelease.5) (2023-12-13)


### Bug Fixes

* use xcframework in Package.swift ([7ab6e37](https://github.com/paypal/paypal-messages-ios/commit/7ab6e372017b1cd870b913ba41754afc2ad5fb51))

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
