#!/bin/sh
#echo $INFOPLIST_PATH
#echo $WRAPPER_NAME
#echo $WRAPPER_SUFFIX
#echo $WRAPPER_EXTENSION
#exit 1;
ROOT_PLIST_PATH=${TARGET_BUILD_DIR}/$WRAPPER_NAME/Settings.bundle/Root.plist
VER=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"`
REV="Version $VER (`svnversion -n`)"
/usr/libexec/PlistBuddy -c "Set :PreferenceSpecifiers:4:Title $REV" "$ROOT_PLIST_PATH"
