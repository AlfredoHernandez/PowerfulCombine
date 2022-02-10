!["Powerful Combine"](./logo.png)

[![Swift](https://github.com/AlfredoHernandez/PowerfulCombine/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/AlfredoHernandez/PowerfulCombine/actions/workflows/swift.yml)

A package with powerful combine extensions. 🤟

## Motivation

The Combine framework provides a declarative Swift API for processing values over time. These values can represent many kinds of asynchronous events. Combine declares publishers to expose values that can change over time, and subscribers to receive those values from the publishers.

This library provides new schedulers that allow you to turn any asynchronous publisher into a synchronous one for ease of testing. Also you'll find a lot of helpers that can be used in your day by day.

## Installation

You can add `PowerfulCombine` to an Xcode project by adding it as a package dependency.

  1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
  2. Enter "https://github.com/AlfredoHernandez/PowerfulCombine.git" into the package repository URL text field
  3. Depending on how your project is structured:
      - If you have a single application target that needs access to the library, then add **PowerfulCombine** directly to your application.
      - If you want to use this library from multiple targets you must create a shared framework that depends on **PowerfulCombine**, and then depend on that framework from your other targets.

## Documentation
Currently there is not documentation (I hope to work on this soon) for this package, feel free to create a PR to add a new one. 🤟 

### License
This library is released under the MIT license. See [LICENSE](./LICENSE) for details.
