/*
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

/// The manifest contents for a release.
/// Version should be updated every release.
/// The version and releasing fields of the non-Firebase pods should be reviewed every release.
public let shared = Manifest(
  version: "7.0.0",
  pods: [
    Pod("GoogleUtilities", isFirebase: false, podVersion: "7.0.0", releasing: false),
    Pod("GoogleDataTransport", isFirebase: false, podVersion: "8.0.0", releasing: true),

    Pod("FirebaseCoreDiagnostics"),
    Pod("FirebaseCore"),
    Pod("FirebaseInstallations"),
    Pod("FirebaseInstanceID"),
    Pod("GoogleAppMeasurement", isClosedSource: true),
    Pod("FirebaseAnalytics", isClosedSource: true, zip: true),
    Pod("FirebaseABTesting", zip: true),
    Pod("FirebaseAppDistribution", isBeta: true, zip: true),
    Pod("FirebaseAuth", zip: true),
    Pod("FirebaseCrashlytics", zip: true),
    Pod("FirebaseDatabase", zip: true),
    Pod("FirebaseDynamicLinks", zip: true),
    Pod("FirebaseFirestore", allowWarnings: true, zip: true),
    Pod("FirebaseFirestoreSwift", isBeta: true),
    Pod("FirebaseFunctions", zip: true),
    Pod("FirebaseInAppMessaging", isBeta: true, zip: true),
    Pod("FirebaseMessaging", zip: true),
    Pod("FirebasePerformance", isClosedSource: true, zip: true),
    Pod("FirebaseRemoteConfig", zip: true),
    Pod("FirebaseStorage", zip: true),
    Pod("FirebaseStorageSwift", isBeta: true),
    Pod("FirebaseMLCommon", isClosedSource: true, isBeta: true),
    Pod("FirebaseMLModelInterpreter", isClosedSource: true, isBeta: true, zip: true),
    Pod("FirebaseMLVision", isClosedSource: true, isBeta: true, zip: true),
    Pod("Firebase", allowWarnings: true, zip: true),
  ]
)

/// Manifest describing the contents of a Firebase release.
public struct Manifest {
  public let version: String
  public let pods: [Pod]

  public func versionString(_ pod: Pod) -> String {
    return pod.podVersion ?? (pod.isBeta ? version + "-beta" : version)
  }
}
