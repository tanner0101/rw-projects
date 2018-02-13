import Service
import Vapor

var config = Config.default()
var env = try Environment.detect()
var services = Services.default()

try configure(&config, &env, &services)

let app = try Application(
    config: config,
    environment: env,
    services: services
)

try boot(app)

try app.run()
