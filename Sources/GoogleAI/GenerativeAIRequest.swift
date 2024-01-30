// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

protocol GenerativeAIRequest: Encodable {
  associatedtype Response: Decodable

  var url: URL { get }

  var options: RequestOptions? { get }
}

/// Configuration parameters for sending requests to the backend.
public struct RequestOptions {
  /// The request’s timeout interval in seconds; if not specified uses the default value for a
  /// `URLRequest`.
  let timeout: TimeInterval?

  /// Initializes a request options object.
  ///
  /// - Parameter timeout The request’s timeout interval in seconds; if not specified uses the
  /// default value for a `URLRequest`.
  public init(timeout: TimeInterval? = nil) {
    self.timeout = timeout
  }
}
