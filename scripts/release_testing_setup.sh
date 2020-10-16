# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -xe

TESTINGMODE=${1-}

if [ -f "${HOME}/.cocoapods/repos" ]; then
  find "${HOME}/.cocoapods/repos" -type d -maxdepth 1 -exec sh -c 'pod repo remove $(basename {})' \;
fi

mkdir -p "${local_sdk_repo_dir}"
echo "git clone ${podspec_repo_branch} from github.com/firebase/firebase-ios-sdk.git to ${local_sdk_repo_dir}"
set +x
git clone -q https://"${BOT_TOKEN}"@github.com/firebase/firebase-ios-sdk.git "${local_sdk_repo_dir}"
set -x

cd  "${local_sdk_repo_dir}"
# This is to search Cocoapods-X.Y.Z tags from all branches of the sdk repo and test_version is X.Y.Z
test_version=$(git tag -l --sort=-version:refname CocoaPods-*[0-9] | head -n 1 | sed -n 's/CocoaPods-//p')
# Check if release-X.Y.Z branch exists in the remote repo.
release_branch=$(git branch -r -l "origin/release-${test_version}")
if [ -z $release_branch ];then
  echo "release-${test_version} branch does not exist in the sdk repo."
  # Get substring before the last ".", e.g. "release-7.0.0" -> "release-7.0"
  test_version=${test_version%.*}
  echo "search for release-${test_version} branch."
  release_branch=$(git branch -r -l "origin/release-${test_version}")
  if [ -z $release_branch ];then
    echo "release-${test_version} branch does not exist in the sdk repo."
    exit 1
  fi
fi

# Get release branch, release-X.Y.Z.
podspec_repo_branch=$(echo $release_branch | sed -n 's/\s*origin\///p')

git config --global user.email "google-oss-bot@example.com"
git config --global user.name "google-oss-bot"
if [ "$TESTINGMODE" = "nightly_testing" ]; then
  tag_version="nightly-test-${test_version}"
  echo "A new tag, ${tag_version},for nightly release testing will be created."
fi
if [ "$TESTINGMODE" = "RC_testing" ]; then
  tag_version="CocoaPods-${test_version}.nightly"
  echo "A new tag, ${tag_version},for prerelease testing will be created."
fi
# Update a tag.
if [ -n "$tag_version" ]; then
  git checkout "${podspec_repo_branch}"
  set +e
  # If tag_version is new to the remote, remote cannot delete a non-existent
  # tag, so error is allowed here.
  git push origin --delete "${tag_version}"
  set -e
  git tag -f -a "${tag_version}" -m "release testing"
  git push origin "${tag_version}"
  # Update source and tag, e.g.  ":tag => 'CocoaPods-' + s.version.to_s" to
  # ":tag => test"
  sed  -i "" "s/\s*:tag.*/:tag => '${tag_version}'/" *.podspec
fi

if [ -n "$sdk_version_config" ]; then
  cd "${GITHUB_WORKSPACE}/ZipBuilder"
  swift build
  # Update Pod versions.
  ./.build/debug/firebase-pod-updater --git-root "${local_sdk_repo_dir}" --releasing-pods "${sdk_version_config}"
  echo "sdk versions are updated based on ${sdk_version_config}."
fi
