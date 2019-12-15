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
    
    func testReplaceErrorHandling() {
        var cancellable = Set<AnyCancellable>()
        var result: String?
        
        Result<String, Error>.Publisher(.failure(NSError(domain: "Internal", code: 0, userInfo: nil)))
            .replaceEmpty(Result.Publisher("5"))
            .replaceError(Just("4"))
            .sink(receiveValue: { result = $0 })
            .store(in: &cancellable)
        
        XCTAssertEqual(result, "4")
    }
    
    func testReplaceErrorNotHandling() {
        
        var cancellable = Set<AnyCancellable>()
        var result: String?
        
        Result<String, Error>.Publisher(.success("3"))
            .replaceError(Just("4"))
            .sink(receiveValue: { result = $0 })
            .store(in: &cancellable)
        
        XCTAssertEqual(result, "3")
    }
    
    func testReplaceErrorChain() {
        
        var cancellable = Set<AnyCancellable>()
        var result: String?
        
        Result<String, Error>.Publisher(.failure(NSError(domain: "Internal", code: 0, userInfo: nil)))
            .replaceError(Result.Publisher(.failure(NSError(domain: "Another", code: 0, userInfo: nil))))
            .replaceError(Just("4"))
            .sink(receiveValue: { result = $0 })
            .store(in: &cancellable)
        
        XCTAssertEqual(result, "4")
    }
    
    static var allTests = [
        ("testReplaceEmptyHandling", testReplaceEmptyHandling),
    ]
}
