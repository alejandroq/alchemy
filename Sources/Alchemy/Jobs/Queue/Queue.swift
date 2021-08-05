import Foundation
import NIO

public let kDefaultQueueChannel = "default"

public protocol Queue {
    /// Add a job to the end of the Queue.
    func enqueue(_ job: JobData) -> EventLoopFuture<Void>
    /// Dequeue the next job from the given channel.
    func dequeue(from channel: String) -> EventLoopFuture<JobData?>
    /// Handle an in progress job that has been completed with the
    /// given outcome.
    func complete(_ job: JobData, outcome: JobOutcome) -> EventLoopFuture<Void>
}

/// An outcome of when a job is run. It should either be flagged as
/// successful, failed, or be retried.
public enum JobOutcome {
    /// The job succeeded.
    case success
    /// The job failed.
    case failed
    /// The job should be requeued.
    case retry
}

// Default arguments
extension Queue {
    public func dequeue(from channel: String = kDefaultQueueChannel) -> EventLoopFuture<JobData?> {
        self.dequeue(from: [channel])
    }
    
    /// Dequeue the next job from a given set of channels, ordered by
    /// priority.
    ///
    /// - Parameter channels: The channels to dequeue from.
    /// - Returns: A future containing a dequeued `Job`, if there is
    ///   one.
    public func dequeue(from channels: [String]) -> EventLoopFuture<JobData?> {
        guard let channel = channels.first else {
            return .new(nil)
        }
        
        return dequeue(from: channel)
            .flatMap { result in
                guard let result = result else {
                    return self.dequeue(from: Array(channels.dropFirst()))
                }
                
                return .new(result)
            }
    }
}

extension Job {
    /// Dispatch this Job on a queue.
    ///
    /// - Parameters:
    ///   - queue: The queue to dispatch on.
    ///   - channel: The name of the channel to dispatch on.
    /// - Returns: A future that completes when this job has been
    ///  dispatched to the queue.
    public func dispatch(on queue: Queue = Services.queue, channel: String = kDefaultQueueChannel) -> EventLoopFuture<Void> {
        catchError { queue.enqueue(try JobData(self, channel: channel)) }
    }
}
