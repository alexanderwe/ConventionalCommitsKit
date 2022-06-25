# ConventionalCommitsKit

<p align="center">
    <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift 5.0">
   </a>
   <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="SPM">
   </a>

   <a href="https://github.com/alexanderwe/ConventionalCommitsKit">
      <img src="https://github.com/alexanderwe/ConventionalCommitsKit/workflows/Main%20Branch%20CI/badge.svg" alt="CI">
   </a>
</p>

<p align="center">
   ConventionalCommitsKit is a small library to create and parse <a href="https://www.conventionalcommits.org/en/v1.0.0/">Conventional Commit</a> conforming representations.
</p>

## Installation

### Swift Package Manager

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/alexanderwe/ConventionalCommitsKit.git", from: "1.0.0")
]
```

Alternatively navigate to your Xcode project, select `Swift Packages` and click the `+` icon to search for `ConventionalCommitsKit`.

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate `ConventionalCommitsKit` into your project manually. Simply drag the `Sources` Folder into your Xcode project.

## Usage

At first import `ConventionalCommitsKit`

```swift
import ConventionalCommitsKit
```

Define a `ConventionalCommit` based on a commit message. Be aware that the parsing can fail and throw an appropriate error.

```swift
let commitMessage = """
fix: correct minor typos in code

see the issue for details

on typos fixed.

Reviewed-by #Z
Refs #133
"""

let commit = try ConventionalCommit(input: commitMessage)
```

## Contributing

Contributions are very welcome 🙌
