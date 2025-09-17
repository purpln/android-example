@preconcurrency
import Android
import AndroidLog

private typealias Pipe = (read: CInt, write: CInt)

private func _pipe() throws -> Pipe {
    var tunnel: (CInt, CInt) = (-1, -1)
    let result = withUnsafeMutablePointer(to: &tunnel) { pointer in
        pointer.withMemoryRebound(to: CInt.self, capacity: 2) { tunnel in
            pipe(tunnel)
        }
    }
    guard result != -1 else {
        throw LogRedirectorError.pipe
    }
    return tunnel
}

private func _close(_ descriptor: CInt) throws {
    guard close(descriptor) != -1 else {
        throw LogRedirectorError.close
    }
}

private func _duplicate(_ current: CInt, _ target: CInt) throws {
    guard dup2(current, target) != -1 else {
        throw LogRedirectorError.duplicate
    }
}

private func _buffer(_ stream: OpaquePointer, _ type: CInt, _ size: size_t = 0) throws {
    guard setvbuf(stream, nil, type, size) != -1 else {
        throw LogRedirectorError.buffer
    }
}

public class LogRedirector {
    private let pipe: Pipe
    private var task: Task<Void, any Error>?
    
    public init() throws {
        pipe = try _pipe()
    }
    
    deinit {
        cancel()
    }
    
    public func redirect(_ stream: OpaquePointer, as tag: String, priority: AndroidLogPriority = .info) throws {
        try _buffer(stream, _IOLBF)
        
        try _duplicate(pipe.write, fileno(stream))
        
        let descriptor = pipe.read
        
        task = Task.detached {
            let capacity = 8
            var buffer = [UInt8](repeating: 0, count: capacity)
            
            let terminator: UInt8 = 0x0a
            var logs: [UInt8] = []
            
            while !Task.isCancelled {
                let length = read(descriptor, &buffer, capacity)
                
                guard length >= 0 else {
                    if errno != EAGAIN && errno != EWOULDBLOCK {
                        break
                    }
                    continue
                }
                
                guard length > 0 else { continue }
                
                let chunk = buffer[0..<length]
                
                var lines = (logs + chunk).split(separator: terminator, omittingEmptySubsequences: true)
                
                if chunk.last == terminator {
                    logs = []
                } else {
                    logs = Array(lines.removeLast())
                }
                
                for line in lines {
                    let line = String(decoding: line, as: UTF8.self)
                    
                    android_log(priority: priority, tag: tag, message: line)
                }
            }
        }
    }
    
    public func cancel() {
        task?.cancel()
        try? _close(pipe.read)
        try? _close(pipe.write)
    }
}

extension LogRedirector {
    func redirectPrint() throws {
        try redirect(stdout, as: "swift")
    }
    
    func redirectError() throws {
        try redirect(stderr, as: "swift", priority: .error)
    }
    
    nonisolated(unsafe)
    static var shared = try! LogRedirector()
}

enum LogRedirectorError: Error {
    case pipe
    case close
    case buffer
    case duplicate
}
