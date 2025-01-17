import Lifecycle
import NIO

/// Convenience class for easy access to the running `Application`'s
/// `EventLoopGroup` and current `EventLoop`.
public struct Loop {
    /// The event loop your code is currently running on.
    @Inject public static var current: EventLoop
    
    /// The main `EventLoopGroup` of the Application.
    @Inject public static var group: EventLoopGroup
    
    /// Configure the Applications `EventLoopGroup` and `EventLoop`.
    static func config() {
        Container.bind(to: EventLoop.self) { _ -> EventLoop in
            guard let current = MultiThreadedEventLoopGroup.currentEventLoop else {
                // With async/await there is no guarantee that you'll
                // be running on an event loop. When one is needed,
                // return a random one for now.
                return Loop.group.next()
            }
            
            return current
        }
        
        Container.main.bind(.singleton, to: EventLoopGroup.self) { _ in
            MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        }
        
        @Inject var lifecycle: ServiceLifecycle
        lifecycle.registerShutdown(label: name(of: EventLoopGroup.self), .sync(group.syncShutdownGracefully))
    }
    
    /// Register mocks of `EventLoop` and `EventLoop` to the
    /// application container.
    static func mock() {
        Container.bind(.singleton, to: EventLoopGroup.self) { _ in
            MultiThreadedEventLoopGroup(numberOfThreads: 1)
        }
        
        Container.bind(to: EventLoop.self) { _ in
            group.next()
        }
    }
}
