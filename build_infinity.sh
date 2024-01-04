#!sh

#set -ex
set -e


### Env Vars
reddit_user='do-it-x' #@param {type:"string"}
api_token='' #@param {type:"string"}
user_agent="android:myreddit:v1.0.0 (by /u/$reddit_user)"
redirect_uri='http://127.0.0.1'

work_dir=`pwd`


### Setup Build Env

## Install Env Setup Related Tools
apt-get update -y
apt-get install -y wget git unzip

## Update the VM, install JDK 11, Android SDK and setup sdkmanager
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata
# DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-11-jdk-headless
DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-11-jdk

## Install Android Command Line Tools
# [Android Command Line Tools](https://developer.android.com/studio#command-tools)
android_cmdline_tools_url=https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip
# android_cmdline_tools_url=https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
rm -rf android-sdk.zip android-sdk/
wget --quiet --output-document=android-sdk.zip "$android_cmdline_tools_url"
unzip -o -q android-sdk.zip -d android-sdk

export ANDROID_SDK_ROOT="$work_dir/android-sdk" # `ANDROID_SDK_ROOT` is deprecated, prefer to `ANDROID_HOME`
export ANDROID_HOME="$work_dir/android-sdk"
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
export PATH="$PATH:$work_dir/android-sdk/tools/bin:$work_dir/android-sdk/platform-tools"

## setup sdkmanager
yes | $work_dir/android-sdk/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "platforms;android-30" "build-tools;30.0.3"


### Download the Infinity source code
cd "$work_dir"
git clone "https://github.com/Docile-Alligator/Infinity-For-Reddit"


### Patch Infinity

## Patch Infinity with user supplied API token, user agent and Redirect URI, and add keystore
pushd `pwd`
cd "$work_dir/Infinity-For-Reddit/"
sh "$work_dir/patch_infinity.sh" "$api_token" "$user_agent"
popd



### Compile/Build/Sign Infinity
pushd `pwd`
cd "$work_dir/Infinity-For-Reddit/"
./gradlew assembleRelease
popd

