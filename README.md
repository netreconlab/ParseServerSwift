# ParseServerSwift

[![Documentation](http://img.shields.io/badge/read-docs-2196f3.svg)](https://swiftpackageindex.com/netreconlab/parse-server-swift/documentation)
[![Tuturiol](http://img.shields.io/badge/read-tuturials-2196f3.svg)](https://netreconlab.github.io/parse-server-swift/release/tutorials/parseserverswift/)
[![Build Status CI](https://github.com/netreconlab/parse-server-swift/workflows/ci/badge.svg?branch=main)](https://github.com/netreconlab/parse-server-swift/actions?query=workflow%3Aci+branch%3Amain)
[![release](https://github.com/netreconlab/parse-server-swift/actions/workflows/release.yml/badge.svg)](https://github.com/netreconlab/parse-server-swift/actions/workflows/release.yml)
[![codecov](https://codecov.io/gh/netreconlab/parse-server-swift/branch/main/graph/badge.svg?token=RC3FLU6BGW)](https://codecov.io/gh/netreconlab/parse-server-swift)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://github.com/netreconlab/parse-server-swift/blob/main/LICENSE)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnetreconlab%2Fparse-server-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/netreconlab/parse-server-swift)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnetreconlab%2Fparse-server-swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/netreconlab/parse-server-swift)

---

Write Parse Cloud Code in Swift!

What is Cloud Code? For complex apps, sometimes you just need logic that isn’t running on a mobile device. Cloud Code makes this possible.
Cloud Code in `ParseServerSwift` is easy to use because it’s built using [Parse-Swift<sup>OG</sup>](https://github.com/netreconlab/Parse-Swift) 
and [Vapor](https://github.com/vapor/vapor). `ParseServerSwift` provides many additional benefits over the traditional [JS based Cloud Code](https://docs.parseplatform.org/cloudcode/guide/) that runs on the [Node.js parse-server](https://github.com/parse-community/parse-server):

* Write code with the [Parse-Swift<sup>OG</sup> SDK](https://github.com/netreconlab/Parse-Swift) vs the [Parse JS SDK](https://github.com/parse-community/Parse-SDK-JS) allowing you to take advantage of a modern SDK which is strongly typed
* Runs on a dedicated server/container, allowing the [Node.js parse-server](https://github.com/parse-community/parse-server) to focus on request reducing the burden by offloading intensive tasks and providing a true [microservice](https://microservices.io)
* All Cloud Code is in one place, but automatically connects supports the [Node.js parse-server](https://github.com/parse-community/parse-server) at scale. This circumvents the issues faced when using [JS based Cloud Code](https://docs.parseplatform.org/cloudcode/guide/) with [PM2](https://pm2.keymetrics.io)
* Leverage the capabilities of [server-side-swift](https://www.swift.org/server/) with [Vapor](https://github.com/vapor/vapor)

Technically, complete apps can be written with `ParseServerSwift`, the only difference is that this code runs in your `ParseServerSwift` rather than running on the user’s mobile device. When you update your Cloud Code, it becomes available to all mobile environments instantly. You don’t have to wait for a new release of your application. This lets you change app behavior on the fly and add new features faster.

## Creating Your Cloud Code App with ParseServerSwift
Setup a Vapor project by following the [directions](https://www.kodeco.com/11555468-getting-started-with-server-side-swift-with-vapor-4) for installing and setting up your project on macOS or linux.

Then add `ParseServerSwift` to `dependencies` in your `Package.swift` file:

```swift
// swift-tools-version:5.5.2
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/netreconlab/ParseServerSwift", .upToNextMajor(from: "0.1.2")),
    ]
)
```

Adding `ParseServerSwift` will allow you to quickly add routes for Parse Cloud Hook Functions and Triggers.

## Configure ParseServerSwift to Connect to Your Parse Servers
### Environment Variables
The following enviroment variables are available and can be configured directly or through `.env`, `.env.production`, etc. See the [Vapor Docs for more details](https://docs.vapor.codes/basics/environment/).

```
PARSE_SERVER_SWIFT_HOST_NAME: cloud-code # The name of your host. If you are running in Docker it should be same name as the docker service
PARSE_SERVER_SWIFT_PORT: # This is the default port on the docker image
PARSE_SERVER_SWIFT_DEFAULT_MAX_BODY_SIZE: 500kb # Set the default size for bodies that are collected into memory before calling your handlers (See Vapor docs for more details)
PARSE_SERVER_SWIFT_URLS: http://parse:1337/parse # (Required) Specify one of your Parse Servers to connect to. Can connect to multiple by seperating URLs with commas
PARSE_SERVER_SWIFT_APPLICATION_ID: appId # (Required) The application id of your Parse Server
PARSE_SERVER_SWIFT_PRIMARY_KEY: primaryKey # (Required) The master key of your Parse Server 
PARSE_SERVER_SWIFT_WEBHOOK_KEY: webookKey # The webhookKey of your Parse Server
```

### WebhookKey
The `webhookKey` should match the [webhookKey on the Parse Server](https://github.com/parse-community/parse-server/blob/42c954318926823446326c95188b844e19954711/src/Options/Definitions.js#L491-L494).

### Parse-Swift<sup>OG</sup> SDK
The aforementioned environment variables automatically configure [Parse-Swift<sup>OG</sup> SDK](https://github.com/netreconlab/Parse-Swift). If you need a more custom configuration, see the [documentation](https://netreconlab.github.io/Parse-Swift/release/documentation/parseswift/).

### Initializing ParseSwiftServer
To levergage the aforementioned environment variables, you should modify `configure.swift` in your project to look similar to below:

```swift
public func configure(_ app: Application) throws {
    // Initialize ParseServerSwift
    let configuration = try ParseServerConfiguration(app: app)
    try ParseServerSwift.initialize(configuration, app: app)
    
    // register routes
    try routes(app)
}
```

If you want to pass the configuration parameters programitically, your `configure` method should look similar to below:

```swift
public func configure(_ app: Application) throws {
    // Initialize ParseServerSwift
    let configuration = try ParseServerConfiguration(app: app,
                                                     hostName: "hostName",
                                                     port: 8081,
                                                     applicationId: "applicationId",
                                                     primaryKey: "primaryKey",
                                                     webhookKey: hookKey,
                                                     parseServerURLString: "primaryKey")
    try ParseServerSwift.initialize(configuration, app: app)
    
    // register routes
    try routes(app)
}
```

## Starting the Server
`ParseServerSwift` is optimized to run in Docker containers. A sample [docker-compose.yml] demonstrates how to quickly spin up one (1) `ParseServerSwift` server with one (1) [parse-hipaa](https://github.com/netreconlab/parse-hipaa) servers and (1) [hipaa-postgres](https://github.com/netreconlab/hipaa-postgres) database.

### In Docker
1. Fork this repo
2. In your terminal, change directories into `ParseServerSwift` folder
3. Type `docker-compose up`
4. Accessing your containers:
  - The first parse-hipaa server can be accessed at: http://localhost:1337/parse with the respective dashboard at: http://localhost:1337/dashboard/apps/Parse%20HIPAA/webhooks
  - The default login for the dashboard is username: `parse` with password: `1234`
  - To view all of your Cloud Code Functions and Hooks: click the `Parse-Hipaa` app, click `Webhooks` to the left and you will see all of the example Cloud Code registered as webooks:
  <img width="1311" alt="image" src="https://user-images.githubusercontent.com/8621344/214114654-a374dc04-f696-4a18-921b-612f19b07ede.png">

### On macOS
To start your server type, `swift run` in the terminal of the project root directory.

## Writing Cloud Code
### Creating `ParseObject`'s
It is recommended to add all of your `ParseObject`'s in a folder called `Models` similar to [ParseServerSwift/Sources/ParseServerSwift/Models](https://github.com/netreconlab/ParseServerSwift/blob/main/Sources/ParseServerSwift/Models). 

#### The `ParseUser` Model
Be mindful that the `ParseUser` in `ParseServerSwift` should conform to [ParseCloudUser](https://swiftpackageindex.com/netreconlab/parse-swift/4.16.2/documentation/parseswift/parseclouduser). This is because the `ParseCloudUser` contains some additional properties on the server-side. On the client, you should always use `ParseUser` instead of `ParseCloudUser`. In addition, make sure to add all of the additional properties you have in your `_User` class to the `User` model. An example `User` model is below:

```swift
/**
 An example `ParseUser`. You will want to add custom
 properties to reflect the `ParseUser` on your Parse Server.
 */
struct User: ParseCloudUser {

    var authData: [String: [String: String]?]?
    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    var sessionToken: String?
    var _failed_login_count: Int?
    var _account_lockout_expires_at: Date?
}
```

#### An example `ParseObject` Model
The `GameScore` model is below:

```swift
import Foundation
import ParseSwift

/**
 An example `ParseObject`. This is for testing. You can
 remove when creating your application.
 */
struct GameScore: ParseObject {
    // These are required by ParseObject.
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // Your own properties.
    var points: Int?

    // Implement your own version of merge.
    func merge(with object: Self) throws -> Self {
        var updated = try mergeParse(with: object)
        if updated.shouldRestoreKey(\.points,
                                     original: object) {
            updated.points = object.points
        }
        return updated
    }
}
```

### Creating New Cloud Code Routes 
Adding routes for `ParseHooks` are as simple as adding [routes in Vapor](https://docs.vapor.codes/basics/routing/). `ParseServerSwift` provides some additional methods to routes to easily create and register [Hook Functions](https://parseplatform.org/Parse-Swift/release/documentation/parseswift/parsehookfunctionable) and [Hook Triggers](https://parseplatform.org/Parse-Swift/release/documentation/parseswift/parsehooktriggerable/). All routes should be added to the `routes.swift` file in your project. Example `ParseServerSwift` routes can be found in [ParseServerSwift/Sources/ParseServerSwift/routes.swift](https://github.com/netreconlab/ParseServerSwift/blob/main/Sources/ParseServerSwift/routes.swift).

**Be sure to add `import ParseSwift` and `import ParseServerSwift` to the top of routes.swift**

### Sending Errors From Cloud Code Routes
There will be times you will need to respond by sending an error to the Node.js Parse Server to propagate to the client. Sending errors can be accomplished by sending a `ParseHookResponse`. Below are two examples of sending an error:

```swift
// Note: `T` is the type to be returned if there is no error thrown.

// Standard Parse error with your own unique message
let standardError = ParseError(code: .missingObjectId, message: "This object requires an objectId")
return ParseHookResponse<T>(error: standardError) // Be sure to "return" the ParseHookResponse in your route, DO NOT "throw" the error.

// Custom error with your own unique code and message
let customError = ParseError(otherCode: 1001, message: "My custom error")
return ParseHookResponse<T>(error: customError) // Be sure to "return" ParseHookResponse in your route, DO NOT "throw" the error.
```

### Cloud Code Functions
Cloud Code Functions can also take parameters. It's recommended to place all paramters in 
[ParseServerSwift/Sources/ParseServerSwift/Models/Parameters](https://github.com/netreconlab/ParseServerSwift/blob/main/Sources/ParseServerSwift/Models/Parameters)

```swift
// A Parse Hook Function route.
app.post("hello",
         name: "hello") { req async throws -> ParseHookResponse<String> in
    // Note that `ParseHookResponse<String>` means a "successfull"
    // response will return a "String" type.
    if let error: ParseHookResponse<String> = checkHeaders(req) {
        return error
    }
    var parseRequest = try req.content
        .decode(ParseHookFunctionRequest<User, FooParameters>.self)
    
    // If a User called the request, fetch the complete user.
    if parseRequest.user != nil {
        parseRequest = try await parseRequest.hydrateUser(request: req)
    }
    
    // To query using the User's credentials who called this function,
    // use the options() method from the parseRequest
    let options = try parseRequest.options(req)
    let scores = try await GameScore.query.findAll(options: options)
    req.logger.info("Scores this user can access: \(scores)")
    return ParseHookResponse(success: "Hello world!")
}
```

### Cloud Code Triggers
```swift
// A Parse Hook Trigger route.
app.post("score", "save", "before",
         className: GameScore.className,
         triggerName: .beforeSave) { req async throws -> ParseHookResponse<GameScore> in
    // Note that `ParseHookResponse<GameScore>` means a "successfull"
    // response will return a "GameScore" type.
    if let error: ParseHookResponse<GameScore> = checkHeaders(req) {
        return error
    }
    var parseRequest = try req.content
        .decode(ParseHookTriggerObjectRequest<User, GameScore>.self)

    // If a User called the request, fetch the complete user.
    if parseRequest.user != nil {
        parseRequest = try await parseRequest.hydrateUser(request: req)
    }

    guard let object = parseRequest.object else {
        return ParseHookResponse(error: .init(code: .missingObjectId,
                                              message: "Object not sent in request."))
    }
    // To query using the primaryKey pass the `usePrimaryKey` option
    // to ther query.
    let scores = try await GameScore.query.findAll(options: [.usePrimaryKey])
    req.logger.info("Before save is being made. Showing all scores before saving new ones: \(scores)")
    return ParseHookResponse(success: object)
}

// Another Parse Hook Trigger route.
app.post("score", "find", "before",
         className: GameScore.className,
         triggerName: .beforeFind) { req async throws -> ParseHookResponse<[GameScore]> in
    // Note that `ParseHookResponse<[GameScore]>` means a "successfull"
    // response will return a "[GameScore]" type.
    if let error: ParseHookResponse<[GameScore]> = checkHeaders(req) {
        return error
    }
    let parseRequest = try req.content
        .decode(ParseHookTriggerObjectRequest<User, GameScore>.self)
    req.logger.info("A query is being made: \(parseRequest)")

    // Return two custom scores instead.
    let score1 = GameScore(objectId: "yolo",
                           createdAt: Date(),
                           points: 50)
    let score2 = GameScore(objectId: "nolo",
                           createdAt: Date(),
                           points: 60)
    req.logger.info("""
        Returning custom objects to the user from Cloud Code instead of querying:
        \(score1); \(score2)
    """)
    return ParseHookResponse(success: [score1, score2])
}

// Another Parse Hook Trigger route.
app.post("user", "login", "after",
         className: User.className,
         triggerName: .afterLogin) { req async throws -> ParseHookResponse<Bool> in
    // Note that `ParseHookResponse<Bool>` means a "successfull"
    // response will return a "Bool" type. Bool is the standard response with
    // a "true" response meaning everything is okay or continue.
    if let error: ParseHookResponse<Bool> = checkHeaders(req) {
        return error
    }
    let parseRequest = try req.content
        .decode(ParseHookTriggerObjectRequest<User, GameScore>.self)

    req.logger.info("A user has logged in: \(parseRequest)")
    return ParseHookResponse(success: true)
}

// A Parse Hook Trigger route for `ParseFile`.
app.on("file", "save", "before",
       triggerName: .beforeSave) { req async throws -> ParseHookResponse<Bool> in
    // Note that `ParseHookResponse<Bool>` means a "successfull"
    // response will return a "Bool" type. Bool is the standard response with
    // a "true" response meaning everything is okay or continue. Sending "false"
    // in this case will reject saving the file.
    if let error: ParseHookResponse<Bool> = checkHeaders(req) {
        return error
    }
    let parseRequest = try req.content
        .decode(ParseHookTriggerRequest<User>.self)

    req.logger.info("A ParseFile is being saved: \(parseRequest)")
    return ParseHookResponse(success: true)
}

// Another Parse Hook Trigger route for `ParseFile`.
app.post("file", "delete", "before",
         triggerName: .beforeDelete) { req async throws -> ParseHookResponse<Bool> in
    // Note that `ParseHookResponse<Bool>` means a "successfull"
    // response will return a "Bool" type. Bool is the standard response with
    // a "true" response meaning everything is okay or continue.
    if let error: ParseHookResponse<Bool> = checkHeaders(req) {
        return error
    }
    let parseRequest = try req.content
        .decode(ParseHookTriggerRequest<User>.self)

    req.logger.info("A ParseFile is being deleted: \(parseRequest)")
    return ParseHookResponse(success: true)
}

// A Parse Hook Trigger route for `ParseLiveQuery`.
app.post("connect", "before",
         triggerName: .beforeConnect) { req async throws -> ParseHookResponse<Bool> in
    // Note that `ParseHookResponse<Bool>` means a "successfull"
    // response will return a "Bool" type. Bool is the standard response with
    // a "true" response meaning everything is okay or continue.
    if let error: ParseHookResponse<Bool> = checkHeaders(req) {
        return error
    }
    let parseRequest = try req.content
        .decode(ParseHookTriggerRequest<User>.self)

    req.logger.info("A LiveQuery connection is being made: \(parseRequest)")
    return ParseHookResponse(success: true)
}

// Another Parse Hook Trigger route for `ParseLiveQuery`.
app.post("score", "subscribe", "before",
         className: GameScore.className,
         triggerName: .beforeSubscribe) { req async throws -> ParseHookResponse<Bool> in
    // Note that `ParseHookResponse<Bool>` means a "successfull"
    // response will return a "Bool" type. Bool is the standard response with
    // a "true" response meaning everything is okay or continue.
    if let error: ParseHookResponse<Bool> = checkHeaders(req) {
        return error
    }
    let parseRequest = try req.content
        .decode(ParseHookTriggerObjectRequest<User, GameScore>.self)

    req.logger.info("A LiveQuery subscription is being made: \(parseRequest)")
    return ParseHookResponse(success: true)
}

// Another Parse Hook Trigger route for `ParseLiveQuery`.
app.post("score", "event", "after",
         className: GameScore.className,
         triggerName: .afterEvent) { req async throws -> ParseHookResponse<Bool> in
    // Note that `ParseHookResponse<Bool>` means a "successfull"
    // response will return a "Bool" type. Bool is the standard response with
    // a "true" response meaning everything is okay or continue.
    if let error: ParseHookResponse<Bool> = checkHeaders(req) {
        return error
    }
    let parseRequest = try req.content
        .decode(ParseHookTriggerObjectRequest<User, GameScore>.self)

    req.logger.info("A LiveQuery event occured: \(parseRequest)")
    return ParseHookResponse(success: true)
}
```
