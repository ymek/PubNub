if xcodebuild build -project cocoa/PubNubMacOSTestApplication/PubNubMacOSTestApplication.xcodeproj clean install > ./coverage/macFail.txt; then echo "success"; mv ./coverage/macFail.txt ./coverage/macSuccess.txt; else echo "fail"; fail=1; fi

if xcodebuild build -project cocoa/HOWTO/ClientSidePresence/ClientSidePresence.xcodeproj clean install > ./coverage/macClientSidePresenceFail.txt; then echo "success"; mv ./coverage/macClientSidePresenceFail.txt ./coverage/macClientSidePresenceSuccess.txt; else echo "fail"; fail=1; fi

if xcodebuild build -project cocoa/HOWTO/SimpleSubscribe/PubNubMacOSTestApplication.xcodeproj clean install > ./coverage/macPubNubMacOSTestApplicationFail.txt; then echo "success"; mv ./coverage/macPubNubMacOSTestApplicationFail.txt ./coverage/macPubNubMacOSTestApplicationSuccess.txt; else echo "fail"; fail=1; fi

if xcodebuild test -project cocoa/tests/iOSUnitTests/PubNubMacOSTestApplication.xcodeproj/ -scheme travis-ci clean install > ./coverage/macTestFail.txt; then echo "success"; mv ./coverage/macTestFail.txt ./coverage/macTestSuccess.txt; else echo "fail"; fail=1; fi



if xcodebuild build -project iOS/iPadDemoApp/pubnub.xcodeproj -sdk iphonesimulator ARCHS=i386 ONLY_ACTIVE_ARCH=YES VALID_ARCHS=i386 clean install > ./coverage/log_iOSFail.txt; then echo "success"; mv ./coverage/log_iOSFail.txt ./coverage/log_iOSSuccess.txt; else echo "fail"; fail=1; fi

if xcodebuild build -project ./iOS/HOWTO/APNSVideo/demo9/demo9.xcodeproj -sdk iphonesimulator ARCHS=i386 ONLY_ACTIVE_ARCH=YES VALID_ARCHS=i386 clean install > ./coverage/iOSDemoFail.txt; then echo "success"; mv ./coverage/iOSDemoFail.txt ./coverage/iOSDemoSuccess.txt; else echo "fail"; fail=1; fi

if xcodebuild build -project ./iOS/HOWTO/CallsWithoutBlocks/CallsWithoutBlocks.xcodeproj -sdk iphonesimulator ARCHS=i386 ONLY_ACTIVE_ARCH=YES VALID_ARCHS=i386 clean install > ./coverage/iOSCallsWithoutBlocksFail.txt; then echo "success"; mv ./coverage/iOSCallsWithoutBlocksFail.txt ./coverage/iOSCallsWithoutBlocksSuccess.txt; else echo "fail"; fail=1; fi

if xcodebuild build -project ./iOS/HOWTO/ClientSidePresence/ClientSidePresence.xcodeproj -sdk iphonesimulator ARCHS=i386 ONLY_ACTIVE_ARCH=YES VALID_ARCHS=i386 clean install > ./coverage/iOSClientSidePresenceFail.txt; then echo "success"; mv ./coverage/iOSClientSidePresenceFail.txt ./coverage/iOSClientSidePresenceSuccess.txt; else echo "fail"; fail=1; fi

if xcodebuild build -project ./iOS/HOWTO/HelloWorld/pubnubDemoExample.xcodeproj -sdk iphonesimulator ARCHS=i386 ONLY_ACTIVE_ARCH=YES VALID_ARCHS=i386 clean install > ./coverage/iOSpubnubDemoExampleFail.txt; then echo "success"; mv ./coverage/iOSpubnubDemoExampleFail.txt ./coverage/iOSpubnubDemoExampleSuccess.txt; else echo "fail"; fail=1; fi

if xcodebuild build -project ./iOS/HOWTO/SimpleSubscribe/PubNubDemo.xcodeproj -sdk iphonesimulator ARCHS=i386 ONLY_ACTIVE_ARCH=YES VALID_ARCHS=i386 clean install > ./coverage/iOSSimpleSubscribeFail.txt; then echo "success"; mv ./coverage/iOSSimpleSubscribeFail.txt ./coverage/iOSSimpleSubscribeSuccess.txt; else echo "fail"; fail=1; fi

if xcodebuild build -project ./iOS/HOWTO/ULSMethods/ULSMethods.xcodeproj -sdk iphonesimulator ARCHS=i386 ONLY_ACTIVE_ARCH=YES VALID_ARCHS=i386 clean install > ./coverage/iOSULSMethodsFail.txt; then echo "success"; mv ./coverage/iOSULSMethodsFail.txt ./coverage/iOSULSMethodsSuccess.txt; else echo "fail"; fail=1; fi

