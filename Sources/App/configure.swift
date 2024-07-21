import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) async throws {
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: "localhost",
        username: "postgres",
        password: "",
        database: "crash",
        tls: .disable)
    ), as: .psql)
    
    try await (app.db as? SQLDatabase)?.raw("SELECT NOW()").run() // any db query

    let eventLoop = app.eventLoopGroup.any()
    let service = TestService(eventLoop: eventLoop)
    app.lifecycle.use(service)
}

struct TestService: LifecycleHandler {
    let promise: EventLoopPromise<Void>
    
    init(eventLoop: EventLoop) {
        self.promise = eventLoop.makePromise()
        self.promise.succeed()
    }
    
    func shutdownAsync(_ application: Application) async {
        try! await promise.futureResult.get()
        print("Test service shutdown finished")
    }
}
