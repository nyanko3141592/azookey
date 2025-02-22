//
//  EmailAddressConversionTests.swift
//  azooKeyTests
//
//  Created by ensan on 2022/12/26.
//  Copyright © 2022 ensan. All rights reserved.
//

@testable import KanaKanjiConverterModule
import XCTest

final class EmailAddressConversionTests: XCTestCase {
    func makeDirectInput(direct input: String) -> ComposingText {
        ComposingText(
            convertTargetCursorPosition: input.count,
            input: input.map {.init(character: $0, inputStyle: .direct)},
            convertTarget: input
        )
    }

    func testtoEmailAddressCandidates() throws {
        do {
            let converter = KanaKanjiConverter()
            let input = makeDirectInput(direct: "azooKey@")
            let result = converter.toEmailAddressCandidates(input)
            XCTAssertFalse(result.isEmpty)
            XCTAssertTrue(result.contains(where: {$0.text == "azooKey@gmail.com"}))
            XCTAssertTrue(result.contains(where: {$0.text == "azooKey@icloud.com"}))
            XCTAssertTrue(result.contains(where: {$0.text == "azooKey@yahoo.co.jp"}))
            XCTAssertTrue(result.contains(where: {$0.text == "azooKey@i.softbank.jp"}))
        }

        do {
            let converter = KanaKanjiConverter()
            let input = makeDirectInput(direct: "my.dev_az@")
            let result = converter.toEmailAddressCandidates(input)
            XCTAssertFalse(result.isEmpty)
            XCTAssertTrue(result.contains(where: {$0.text == "my.dev_az@gmail.com"}))
            XCTAssertTrue(result.contains(where: {$0.text == "my.dev_az@icloud.com"}))
            XCTAssertTrue(result.contains(where: {$0.text == "my.dev_az@yahoo.co.jp"}))
            XCTAssertTrue(result.contains(where: {$0.text == "my.dev_az@i.softbank.jp"}))
        }

        do {
            let converter = KanaKanjiConverter()
            let input = makeDirectInput(direct: "@")
            let result = converter.toEmailAddressCandidates(input)
            XCTAssertFalse(result.isEmpty)
            XCTAssertTrue(result.contains(where: {$0.text == "@gmail.com"}))
            XCTAssertTrue(result.contains(where: {$0.text == "@icloud.com"}))
            XCTAssertTrue(result.contains(where: {$0.text == "@yahoo.co.jp"}))
            XCTAssertTrue(result.contains(where: {$0.text == "@i.softbank.jp"}))
        }

    }

}
