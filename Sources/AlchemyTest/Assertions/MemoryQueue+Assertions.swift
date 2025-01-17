@testable import Alchemy
import XCTest

extension MemoryQueue {
    public func assertNothingPushed() {
        XCTAssertTrue(jobs.isEmpty)
    }
    
    public func assertNotPushed<J: Job>(_ type: J.Type, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertFalse(jobs.values.contains { $0.jobName == J.name }, file: file, line: line)
    }
    
    public func assertPushed<J: Job>(
        on channel: String? = nil,
        _ type: J.Type,
        _ count: Int = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let matches = jobs.values.filter { $0.jobName == J.name && $0.channel == channel ?? $0.channel }
        XCTAssertEqual(matches.count, count, file: file, line: line)
    }
    
    public func assertPushed<J: Job>(
        on channel: String? = nil,
        _ type: J.Type,
        assertion: (J) -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(try {
            let matches = try jobs.values.filter {
                guard $0.jobName == J.name, $0.channel == channel ?? $0.channel else {
                    return false
                }
                
                let job = try (JobDecoding.decode($0) as? J).unwrap(or: JobError.unknownType)
                return assertion(job)
            }
            
            XCTAssertFalse(matches.isEmpty, file: file, line: line)
        }(), file: file, line: line)
    }
    
    public func assertPushed<J: Job & Equatable>(
        on channel: String? = nil,
        _ instance: J,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(try {
            let matches = try jobs.values.filter {
                guard $0.jobName == J.name, $0.channel == channel ?? $0.channel else {
                    return false
                }
                
                let job = try (JobDecoding.decode($0) as? J).unwrap(or: JobError.unknownType)
                return job == instance
            }
            
            XCTAssertFalse(matches.isEmpty, file: file, line: line)
        }(), file: file, line: line)
    }
}
