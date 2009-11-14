#!/bin/sh
REV=`svnversion -n`
echo TARGET_BUILD_DIR=${TARGET_BUILD_DIR}
ROOT_PLIST_PATH=${TARGET_BUILD_DIR}/BeerCrush.app/Settings.bundle/Root.plist
echo ROOT_PLIST_PATH=$ROOT_PLIST_PATH
/usr/libexec/PlistBuddy -c "Set :PreferenceSpecifiers:5:DefaultValue $REV" $ROOT_PLIST_PATH
