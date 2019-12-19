# Highlight

[![CI Status](https://github.com/nkristek/Highlight/workflows/CI/badge.svg)](https://github.com/nkristek/Highlight/actions)

This library provides a syntax highlighter which currently supports highlighting JSON data. It is fully written in Swift and there are no additional dependencies. 
It uses a compatibility layer for colors and fonts for `UIKit` and `AppKit` and the default theme supports dark mode on both platforms.

## Features

This library provides a `JsonSyntaxHighlightProvider` which can either be instanciated or accessed through a static instance `JsonSyntaxHighlightProvider.shared`.

It parses the given `String` and highlights the given `NSMutableAttributedString` by setting the color and font on specific areas.

## Installation

Currently supported methods of importing it:
- SwiftPM: https://github.com/nkristek/Highlight.git
- Manually copying all files in the [Sources](https://github.com/nkristek/Highlight/tree/master/Sources) folder

## Contribution

If you find a bug feel free to open an issue. Contributions are also appreciated.
