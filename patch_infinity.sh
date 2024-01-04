
# Patch Infinity with user supplied API token, user agent and Redirect URI, and add keystore
patch_with_user_data()
{
    if [ $# != 2 ]; then
        echo "Error: usage: patch_with_user_data <api_token> <user_agent>"
        return -1
    fi

    local api_token="$1"
    local user_agent="$2"
    
    local redirect_uri='http://127.0.0.1'

    local apiutils_file="app/src/main/java/ml/docilealligator/infinityforreddit/utils/APIUtils.java"
    #apiutils_code = open(apiutils_file, "r", encoding="utf-8-sig").read()

    if [ ! -e $apiutils_file ]; then
        echo "Error: Can't find APIUtils.java under @`pwd`!"
        return -1
    fi

    echo "Patching Infinity..."
    echo -e "\tapi_token: $api_token"
    echo -e "\tuser_agent: $user_agent"
    echo -e "\tredirect_uri: $redirect_uri"

    # replace API Key/Token (i.e., `CLIENT_ID`) in `APIUtils.java`
    # apiutils_code = apiutils_code.replace("NOe2iKrPPzwscA", api_token)
    sed -i "s/\bCLIENT_ID\b *= *\"\(.*\)\"/CLIENT_ID = \"$api_token\"/" $apiutils_file

    # replace Redirect URL (i.e., `REDIRECT_URI`) in `APIUtils.java`
    # apiutils_code = apiutils_code.replace("infinity://localhost", redirect_uri)
    sed -i "s|\bREDIRECT_URI\b *= *\"\(.*\)\"|REDIRECT_URI = \"$redirect_uri\"|" $apiutils_file

    # replace User-Agent (i.e., `USER_AGENT`) in `APIUtils.java`
    # apiutils_code = re.sub(r'public static final String USER_AGENT = ".*?";', f'public static final String USER_AGENT = "{user_agent}";', apiutils_code)
    sed -i "s|\bUSER_AGENT\b *= *\"\(.*\)\"|USER_AGENT = \"$user_agent\"|" $apiutils_file
}


# Add Keystore
patch_gradle_signing_config()
{
    wget -P . "https://github.com/TanukiAI/Infinity-keystore/raw/main/Infinity.jks"

    build_gradle_file="app/build.gradle"
    #build_gradle_code=open(build_gradle_file, "r", encoding="utf-8-sig").read()

    #build_gradle_code=build_gradle_code.replace(r"""    buildTypes {""", r"""    signingConfigs {
    #        release {
    #            storeFile file("/content/Infinity.jks")
    #            storePassword "Infinity"
    #            keyAlias "Infinity"
    #            keyPassword "Infinity"
    #        }
    #    }
    #    buildTypes {""")
    #build_gradle_code = build_gradle_code.replace(r"""    buildTypes {
    #        release {""", r"""    buildTypes {
    #        release {
    #            signingConfig signingConfigs.release""")

    sed -i -e '/buildTypes {/,$ {
        /buildTypes {/ i \
    signingConfigs {\
        release {\
            storeFile file("../Infinity.jks")\
            storePassword "Infinity"\
            keyAlias "Infinity"\
            keyPassword "Infinity"\
        }\
    }
        /release {/ a \
            signingConfig signingConfigs.release
    }' $build_gradle_file
}



patch_with_user_data "$@"

patch_gradle_signing_config
