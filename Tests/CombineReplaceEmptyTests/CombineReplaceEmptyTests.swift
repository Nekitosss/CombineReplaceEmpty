import XCTest
import Combine
@testable import CombineReplaceWithPublisher

final class CombineReplaceWithPublisherTests: XCTestCase {
    
    func testReplaceEmpty() {
        var cancellable = Set<AnyCancellable>()
        var result: String?
        
        Just(Optional<String>.none)
            .compactMap({ $0 })
            .replaceEmpty(Just("5"))
            .sink(receiveValue: { result = $0 })
            .store(in: &cancellable)
        
        XCTAssertEqual(result, "5")
    }
    
    func testReplaceFailure() {
        var cancellable = Set<AnyCancellable>()
        var result: String?
        
        Result<String, Error>.Publisher(.failure(NSError()))
            .replaceEmpty(Result.Publisher("5"))
            .replaceError(Just("4"))
            .sink(receiveCompletion: { _ in }, receiveValue: { result = $0 })
            .store(in: &cancellable)
        
        XCTAssertEqual(result, "4")
    }
    
    static var allTests = [
        ("testReplaceEmpty", testReplaceEmpty),
    ]
}
