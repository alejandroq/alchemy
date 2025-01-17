extension Queue {
    /// Start a worker that dequeues and runs jobs from this queue.
    ///
    /// - Parameters:
    ///   - channels: The channels this worker should monitor for
    ///     work. Defaults to `Queue.defaultChannel`.
    ///   - pollRate: The rate at which this worker should poll the
    ///     queue for new work. Defaults to `Queue.defaultPollRate`.
    ///   - eventLoop: The loop this worker will run on. Defaults to
    ///     your apps next available loop.
    public func startWorker(for channels: [String] = [Queue.defaultChannel], pollRate: TimeAmount = Queue.defaultPollRate, untilEmpty: Bool = true, on eventLoop: EventLoop = Loop.group.next()) {
        let worker = eventLoop.queueId
        Log.info("[Queue] starting worker \(worker)")
        workers.append(worker)
        _startWorker(for: channels, pollRate: pollRate, untilEmpty: untilEmpty, on: eventLoop)
    }
    
    private func _startWorker(for channels: [String] = [Queue.defaultChannel], pollRate: TimeAmount = Queue.defaultPollRate, untilEmpty: Bool, on eventLoop: EventLoop = Loop.group.next()) {
        eventLoop.asyncSubmit { try await self.runNext(from: channels, untilEmpty: untilEmpty) }
            .whenComplete { _ in
                // Run check again in the `pollRate`.
                eventLoop.scheduleTask(in: pollRate) {
                    self._startWorker(for: channels, pollRate: pollRate, untilEmpty: untilEmpty, on: eventLoop)
                }
            }
    }
    
    func runNext(from channels: [String], untilEmpty: Bool) async throws {
        do {
            guard let jobData = try await dequeue(from: channels) else {
                return
            }
            
            Log.info("[Queue] dequeued job \(jobData.jobName) from queue \(jobData.channel)")
            try await execute(jobData)
            
            if untilEmpty {
                try await runNext(from: channels, untilEmpty: untilEmpty)
            }
        } catch {
            Log.error("[Queue] error running job \(name(of: Self.self)) from `\(channels)`. \(error)")
            throw error
        }
    }
    
    /// Dequeue the next job from a given set of channels, ordered by
    /// priority.
    ///
    /// - Parameter channels: The channels to dequeue from.
    /// - Returns: A dequeued `Job`, if there is one.
    func dequeue(from channels: [String]) async throws -> JobData? {
        guard let channel = channels.first else {
            return nil
        }
        
        if let job = try await provider.dequeue(from: channel) {
            return job
        } else {
            return try await dequeue(from: Array(channels.dropFirst()))
        }
    }
    
    private func execute(_ jobData: JobData) async throws {
        var jobData = jobData
        jobData.attempts += 1
        
        func retry(ignoreAttempt: Bool = false) async throws {
            if ignoreAttempt { jobData.attempts -= 1 }
            jobData.backoffUntil = jobData.nextRetryDate()
            try await provider.complete(jobData, outcome: .retry)
        }
        
        var job: Job?
        do {
            job = try JobDecoding.decode(jobData)
            try await job?.run()
            try await provider.complete(jobData, outcome: .success)
            job?.finished(result: .success(()))
        } catch where jobData.canRetry {
            try await retry()
            job?.failed(error: error)
        } catch where (error as? JobError) == JobError.unknownType {
            // So that an old worker won't fail new, unrecognized jobs.
            try await retry(ignoreAttempt: true)
            job?.failed(error: error)
            throw error
        } catch {
            try await provider.complete(jobData, outcome: .failed)
            job?.finished(result: .failure(error))
            job?.failed(error: error)
        }
    }
}

extension EventLoop {
    var queueId: String {
        String(ObjectIdentifier(self).debugDescription.dropLast().suffix(6))
    }
}
