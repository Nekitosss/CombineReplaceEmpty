import XCTest
import Combine
@testable import CombineReplaceWithPublisher

final class CombineReplaceWithPublisherTests: XCTestCase {
    
    func testReplaceEmptyHandling() {
        var cancellable = Set<AnyCancellable>()
        var result: String?
        
        Just(Optional<String>.none)
            .compactMap({ $0 })
            .replaceEmpty(Just("5"))
            .sink(receiveValue: { result = $0 })
            .store(in: &cancellable)
        
        XCTAssertEqual(result, "5")
    }
    
    func testReplaceEmptyNotHandling() {
        var cancellable = Set<AnyCancellable>()
        var result: String?
        
        Just(Optional<String>.some("4"))
            .compactMap({ $0 })
            .replaceEmpty(Just("5"))
            .sink(receiveValue: { result = $0 })
            .store(in: &cancellable)
        
        XCTAssertEqual(result, "4")
    }
    
    func testReplaceEmptyChain() {
        var cancellable = Set<AnyCancellable>()
        var result: String?
        
        Just(Optional<String>.none)
            .compactMap({ $0 })
            .replaceEmpty(Just(Optional<String>.none).compactMap({ $0 }))
            .replaceEmpty(Just("5"))
            .sink(receiveValue: { result = $0 })
            .store(in: &cancellable)
        
        XCTAssertEqual(result, "5")
    }
    
    static var allTests = [
        ("testReplaceEmptyHandling", testReplaceEmptyHandling),
    ]
}
