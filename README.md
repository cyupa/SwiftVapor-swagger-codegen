# Swagger Codegen for the SwiftVapor3 framework

## Overview
Generates a package from a swagger spec file that can be imported by a [Vapor 3](https://vapor.codes) project. The package will contain a routes.swift, protocols to implement the APIs and data models.

This package was originally generated by the [Swagger Codegen](https://github.com/swagger-api/swagger-codegen) tool.

This project was designed so that you start your API from a swagger spec. Then using this tool generate the Vapor Server interface as a package. Your Vapor project will depend on the new interface package and us the auto-generated `routes.swift`, API Interfaces and data models. See instructions below on how to consume the package's interfaces.

I hope that you find this project to be useful. I would like to see server side swift adopted more commonly as I love the swift language for its performance and other conveniences. Vapor is a low memory, low cpu web server and hope to see it become well established in the future. Now if you get an API swagger definition file, you can get starte fairly quickly using this project. And if you don't have a swagger spec file to start from, I would recommend starting to write an API by defining the swagger spec file first. This project should reduce the overhead of going from API design to compiling working code as you make changes to your APIs.

Let me know if you run into issues with this project or its documentation. Help is welcome!

## How do I build this project?

As of now, you must generate your own jar file. Check out or download the complete source.


```
git clone https://github.com/thecheatah/SwiftVapor-swagger-codegen
cd SwiftVapor-swagger-codegen
mvn package
```

The `mvn package` command will run test that include a swift project. This project was created on MacOS with Swift 5 installed. To ignore tests run `mvn -Dmaven.test.skip=true package`. The project also contains `SwiftVapor3Codegen/src/test/resources/swift/VaporTestServer/run_linux_test` to run the tests in a docker container.

## How do I run this project?

Once the package has been created, you will find `SwiftVapor3-swagger-codegen-1.0.0.jar` in the `target` directory.

You can now generate the Vapor Server Interface Package from a swagger file.

```
java -cp SwiftVapor3-swagger-codegen-1.0.0.jar:swagger-codegen-cli-3.0.7.jar io.swagger.codegen.v3.cli.SwaggerCodegen generate -l SwiftVapor3 -i ./codegen_test.yml -o ./output/MyApiVaporInterface --additional-properties projectName=MyApiVaporInterface
```

The `swagger-codegen-cli-3.0.7.jar` can be built from the [swagger-codegen](https://github.com/swagger-api/swagger-codegen) package. Personally, I use the one from maven `.m2/repository/io/swagger/codegen/v3/swagger-codegen-cli/3.0.7/swagger-codegen-cli-3.0.7.jar` This project depends on it and will be pulled in to your maven cache.

## How do I use the auto-generated package?

The auto-generated package will contain 3 key directories:

```
|- Sources
|-- {Package Name}
|--- routes.swift
|--- APIs
|---- {Swagger Tag 1}ApiDelegates.swift
|---- {Swagger Tag 2}ApiDelegates.swift
|--- Models
|---- {Swagger Model 1}.swift
|---- {Swagger Model 2}.swift
```

`routes.swift` will contain a public function where the `Router` and controllers implementing the protocols defined in the APIs directory need to be passed in. The protocols defined in the APIs directory provide the key interface that your code needs to interact with. The interface provided is designed to exchange simple data types or models created from the swagger. The `Models` directory contains all of the models generated from the swagger spec.
### 1. Define dependency
In order to use the auto-generated package, your Vapor project needs to define a dependency on the package. The swift project included to run test cases has an example `Package.swift` that defines such a dependency.

```swift
// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "VaporTestServer",
    products: [
        .library(name: "VaporTestServer", targets: ["App"]),
        ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        
        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        .package(path: "../VaporTestInterface/")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "VaporTestInterface"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
```
In the example above the generated package is `VaporTestInterface` and is located next to the `VaporTestServer` vapor project.

### 2. Implement API by creating Controllers

Next, you will need to create controller classes for each of the APIs defined within the swagger. Each controller class will need to implement the specific API's interface as defined within the generated package.

```swift
import Vapor
import VaporTestInterface

class DataModelController: DataModelApiDelegate {
  func referencedObject(request: Request, body: SimpleObject) throws -> Future<referencedObjectResponse> {
    return request.future(.http200(body))
  }
}
```

In the example above the `DataModelController` class is in a file within your project. `DataModelApiDelegate` is from the auto-generated package `VaporTestInterface`.

### 3. Configure the router

The generated package will contain a `routes.swift`. This file will contain a public function `public func routes(_ router: Router, ...`. You can call this function from the `routes.swift` from your vapor project and pass in the `Router` as well as the controllers implementing the API interfaces.

Once this step is done, you can now run the vapor server (`vapor run`) from your project and try out the APIs.

## Your Code SuX, How do I make changes to it?

When I work on this project, I work on a Mac and use xcode. I have included linux build script using docker that runs the swift test cases in a docker image. If you want to do development on Linux or Windows, there is nothing theoretically stopping you.

To get into the grove of making changes, running tests, adding new functionality and adding test cases, you should configure the project locally as follows:

### 1. Get the project to build

At a minimum, you need to install Maven, and I would recommend a java IDE like Eclipse. Once you have maven installed you can run `mvn package` to build, run tests and produce a jar. If the tests fail for some reason and you still want a jar, you can run `mvn -Dmaven.test.skip=true package`

### 2. Setup for swift development

Once you can see that the java project works, you should configure the swift project as well for development

In the root of the project run the following commands:

```shell
cd test/resources/swift
ln -s ../../../../target/test-classes/swift/VaporTestInterface ./
cd ../../..
```
The java tests build `VaporTestInterface` under `target/test-classes/swift/`. If you link it like this, you can run the xcode tests right from the xcode test project.

### 3. Setup for running tests in swift

Again in the root of the project folder:
```shell
cd src/test/resources/swift/VaporTestServer
vapor xcode
```

The `vapor xcode` command will ask if you want to open the xcode project. Hit yes and it will launch xcode. You can hit run and see the test project build. I mainly use it to run the tests. So go to the tests section in xcode and run all of them from there.

If you don't want to use xcode you can simply run `swift test` in the `src/test/resources/swift/VaporTestServer` directory.

### 4. Edit, build, test cycle

Now you are ready for the edit, build, test cycle.

1. You can edit the java code as well as the mustache templates in the java project
2. Run `mvn -Dmaven.test.skip=true package` to build the java package
3. Run codegen `src/test/resources/run_codegen.sh`
3. Run the tests in swift using xcode or the commandline

I mostly edited the mustache templates in this project. `run_codegen.sh` pipes the output by default to a file in the same directory called `codegen.out`. It's configured to dump the json payloads that are fed into the mustache template engine. Each generated swift file has a "Template Input" line like this: `Template Input: /APIs.FormData`. In the example template input line you can search for `/APIs.FormData` in the `codegen.out` file and find the json payload. I usually copy that subset of the json payload into Chrome/Safari/Firefox's developer console. For example I will do `var json = command+v` and then press up and type in `json` and hit enter. The browser's developer console will let you browse the json tree easily.

### Original Swagger Codegen Instructions

The instructions below were generated automatically by the swagger-codegen build script. I have kept them here to assist users new to the swagger-codegen tool. (It's Awesome!)

At this point, you've likely generated a client setup.  It will include something along these lines:

```
.
|- README.md    // this file
|- pom.xml      // build script
|-- src
|--- main
|---- java
|----- com.chckt.swagger.swift.vapor3.Swiftvapor3Generator.java // generator file
|---- resources
|----- SwiftVapor3 // template files
|----- META-INF
|------ services
|------- io.swagger.codegen.CodegenConfig
```

You _will_ need to make changes in at least the following:

`Swiftvapor3Generator.java`

Templates in this folder:

`src/main/resources/SwiftVapor3`

Once modified, you can run this:

```
mvn package
```

In your generator project.  A single jar file will be produced in `target`.  You can now use that with codegen:

```
java -cp /path/to/swagger-codegen-cli.jar:/path/to/your.jar io.swagger.codegen.Codegen -l SwiftVapor3 -i /path/to/swagger.yaml -o ./test
```

Now your templates are available to the client generator and you can write output values

## But how do I modify this?
The `Swiftvapor3Generator.java` has comments in it--lots of comments.  There is no good substitute
for reading the code more, though.  See how the `Swiftvapor3Generator` implements `CodegenConfig`.
That class has the signature of all values that can be overridden.

For the templates themselves, you have a number of values available to you for generation.
You can execute the `java` command from above while passing different debug flags to show
the object you have available during client generation:

```
# The following additional debug options are available for all codegen targets:
# -DdebugSwagger prints the OpenAPI Specification as interpreted by the codegen
# -DdebugModels prints models passed to the template engine
# -DdebugOperations prints operations passed to the template engine
# -DdebugSupportingFiles prints additional data passed to the template engine

java -DdebugOperations -cp /path/to/swagger-codegen-cli.jar:/path/to/your.jar io.swagger.codegen.Codegen -l SwiftVapor3 -i /path/to/swagger.yaml -o ./test
```

Will, for example, output the debug info for operations.  You can use this info
in the `api.mustache` file.