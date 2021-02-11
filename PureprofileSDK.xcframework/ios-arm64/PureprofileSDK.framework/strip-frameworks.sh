# Signs a framework with the provided identity
code_sign() {
  # Use the current code_sign_identitiy
  echo "Code Signing $1 with Identity ${EXPANDED_CODE_SIGN_IDENTITY_NAME}"
  echo "/usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} --preserve-metadata=identifier,entitlements $1"
  /usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} --preserve-metadata=identifier,entitlements "$1"
}

# Set working directory to product’s embedded frameworks 
cd "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

echo "Action: $ACTION"
if [ "$ACTION" = "install" ]; then
  echo "Copy .bcsymbolmap files to .xcarchive"
  find . -name '*.bcsymbolmap' -type f -exec mv {} "${CONFIGURATION_BUILD_DIR}" \;
else
  # Delete *.bcsymbolmap files from framework bundle unless archiving
  echo "Delete *.bcsymbolmap files from framework bundle unless archiving"
  find . -name '*.bcsymbolmap' -type f -exec rm -rf "{}" +\;
fi

echo "Stripping frameworks"

framework_folder="PureprofileSDK.framework"

if ! [ -d "$framework_folder" ]; then
	echo "Did not find Pureprofile framework!"
    exit 1
fi

framework_binary="$framework_folder/PureprofileSDK"

# Get architectures for current file
archs="$(lipo -info "${framework_binary}" | rev | cut -d ':' -f1 | rev)"
stripped=""

for arch in $archs; do
  if ! [[ "${VALID_ARCHS}" == *"$arch"* ]]; then
    # Strip non-valid architectures in-place
    lipo -remove "$arch" -output "$framework_binary" "$framework_binary" || exit 1
    stripped="$stripped $arch"
  fi
done

if [[ "$stripped" != "" ]]; then
  echo "Stripped $framework_binary of architectures:$stripped"
  if [ "${CODE_SIGNING_REQUIRED}" == "YES" ]; then
	echo "Code signing ${framework_binary}"  
    code_sign "${framework_binary}"
  fi
fi
