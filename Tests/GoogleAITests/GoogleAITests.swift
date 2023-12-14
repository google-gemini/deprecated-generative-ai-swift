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

import GoogleGenerativeAI
import XCTest
#if canImport(AppKit)
  import AppKit // For NSImage extensions.
#elseif canImport(UIKit)
  import UIKit // For UIImage extensions.
#endif

final class GoogleGenerativeAITests: XCTestCase {
  func codeSamples() async throws {
    let config = GenerationConfig(temperature: 0.2,
                                  topP: 0.1,
                                  topK: 16,
                                  candidateCount: 4,
                                  maxOutputTokens: 256,
                                  stopSequences: ["..."])
    let filters = [SafetySetting(harmCategory: .dangerousContent, threshold: .blockOnlyHigh)]

    // Permutations without optional arguments.
    let _ = GenerativeModel(name: "gemini-pro@001", apiKey: "API_KEY")
    let _ = GenerativeModel(name: "gemini-pro@001", apiKey: "API_KEY", safetySettings: filters)
    let _ = GenerativeModel(name: "gemini-pro@001", apiKey: "API_KEY", generationConfig: config)

    // All arguments passed.
    let genAI = GenerativeModel(name: "gemini-pro@001",
                                apiKey: "API_KEY",
                                generationConfig: config, // Optional
                                safetySettings: filters // Optional
    )
    // Full Typed Usage
    let pngData = Data() // ....
    let contents = [ModelContent(role: "user",
                                 parts: [
                                   .text("Is it a cat?"),
                                   .png(pngData),
                                 ])]

    do {
      let response = try await genAI.generateContent(contents)
      print(response.text ?? "Couldn't get text... check status")
    } catch {
      print("Error generating content: \(error)")
    }

    // Content input combinations.
    let _ = try await genAI.generateContent("Constant String")
    let str = "String Variable"
    let _ = try await genAI.generateContent(str)
    let _ = try await genAI.generateContent([str])
    let _ = try await genAI.generateContent(str, "abc", "def")
    #if canImport(UIKit)
      _ = try await genAI.generateContent(UIImage())
      _ = try await genAI.generateContent([UIImage()])
      _ = try await genAI
        .generateContent([str, UIImage(), ModelContent.Part.text(str)])
      _ = try await genAI.generateContent(str, UIImage(), "def", UIImage())
      _ = try await genAI.generateContent([str, UIImage(), "def", UIImage()])
      _ = try await genAI.generateContent([ModelContent("def", UIImage()),
                                           ModelContent("def", UIImage())])
    #elseif canImport(AppKit)
      _ = try await genAI.generateContent(NSImage())
      _ = try await genAI.generateContent([NSImage()])
      _ = try await genAI.generateContent(str, NSImage(), "def", NSImage())
      _ = try await genAI.generateContent([str, NSImage(), "def", NSImage()])
    #endif

    // PartsRepresentable combinations.
    let _ = ModelContent(parts: [.text(str)])
    let _ = ModelContent(role: "model", parts: [.text(str)])
    let _ = ModelContent(parts: "Constant String")
    let _ = ModelContent(parts: str)
    let _ = ModelContent(parts: [str])
    // Note: without `as [any PartsRepresentable]` this will fail to compile with "Cannot convert
    // value of type `[Any]` to expected type `[any PartsRepresentable]`. Not sure if there's a
    // way we can get it to work.
    let _ = ModelContent(parts: [str, ModelContent.Part.data(
      mimetype: "foo",
      Data()
    )] as [any PartsRepresentable])
    #if canImport(UIKit)
      _ = ModelContent(role: "user", parts: UIImage())
      _ = ModelContent(role: "user", parts: [UIImage()])
      // Note: without `as [any PartsRepresentable]` this will fail to compile with "Cannot convert
      // value of type `[Any]` to expected type `[any PartsRepresentable]`. Not sure if there's a
      // way we can get it to work.
      _ = ModelContent(parts: [str, UIImage()] as [any PartsRepresentable])
      // Alternatively, you can explicitly declare the type in a variable and pass it in.
      let representable2: [any PartsRepresentable] = [str, UIImage()]
      _ = ModelContent(parts: representable2)
      _ = ModelContent(parts: [str, UIImage(),
                               ModelContent.Part.text(str)] as [any PartsRepresentable])
    #elseif canImport(AppKit)
      _ = ModelContent(role: "user", parts: NSImage())
      _ = ModelContent(role: "user", parts: [NSImage()])
      // Note: without `as [any PartsRepresentable]` this will fail to compile with "Cannot convert
      // value of type `[Any]` to expected type `[any PartsRepresentable]`. Not sure if there's a
      // way we can get it to work.
      _ = ModelContent(parts: [str, NSImage()] as [any PartsRepresentable])
      // Alternatively, you can explicitly declare the type in a variable and pass it in.
      let representable2: [any PartsRepresentable] = [str, NSImage()]
      _ = ModelContent(parts: representable2)
      _ =
        ModelContent(parts: [str, NSImage(),
                             ModelContent.Part.text(str)] as [any PartsRepresentable])
    #endif

    // countTokens API
    let _: CountTokensResponse = try await genAI.countTokens("What color is the Sky?")
    #if canImport(UIKit)
      let _: CountTokensResponse = try await genAI.countTokens("What color is the Sky?",
                                                               UIImage())
      let _: CountTokensResponse = try await genAI.countTokens([
        ModelContent("What color is the Sky?", UIImage()),
        ModelContent(UIImage(), "What color is the Sky?", UIImage()),
      ])
    #endif

    // Chat
    _ = genAI.startChat()
    _ = genAI.startChat(history: [ModelContent(parts: "abc")])
  }

  // Result builder alternative

  /*
   let pngData = Data() // ....
   let contents = [GenAIContent(role: "user",
                                parts: [
                                 .text("Is it a cat?"),
                                 .png(pngData)
                                ])]

   // Turns into...

   let contents = GenAIContent {
     Role("user") {
       Text("Is this a cat?")
       Image(png: pngData)
     }
   }

   GenAIContent {
     ForEach(myInput) { input in
       Role(input.role) {
         input.contents
       }
     }
   }

   // Thoughts: this looks great from a code demo, but since I assume most content will be
   // user generated, the result builder may not be the best API.
   */
}
