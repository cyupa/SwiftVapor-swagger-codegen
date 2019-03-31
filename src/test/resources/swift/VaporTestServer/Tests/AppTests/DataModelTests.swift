import Vapor
import App
import XCTest
import VaporTestInterface

//https://medium.com/swift2go/vapor-3-series-iii-testing-b192be079c9e

final class DataModelTests: XCTestCase {
  
  var app: Application!
  
  override func setUp() {
    super.setUp()
    app = try! Application.testable()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testQueryOptionalParameters() throws {
    let input = SimpleObject(simpleString: "Simple String", simpleNumber: 44.4, simpleInteger: 33, simpleDate: Date(), simpleEnumString: ._2)
    let response = try app.sendRequest(to: "/schema/referenced/object", method: .POST, body: input) as Response
    XCTAssertEqual(response.http.status, HTTPStatus.ok, "/schema/referenced/object did not return a 200")
    XCTAssertNotNil(response.http.body.data, "/schema/referenced/object should not be nil")
    let output = try! response.content.decode(SimpleObject.self).wait()
    XCTAssertEqual(input.simpleString, output.simpleString, "/schema/referenced/object simpleString did not match")
    XCTAssertEqual(input.simpleNumber, output.simpleNumber, "/schema/referenced/object simpleNumber did not match")
    XCTAssertEqual(input.simpleInteger, output.simpleInteger, "/schema/referenced/object simpleInteger did not match")
    //Data does not encode milliseconds so the date we sent in loses that information and cannot be compared
    let dateDifference = abs(input.simpleDate.timeIntervalSince(output.simpleDate))
    XCTAssert(dateDifference < 1.0, "/schema/referenced/object simpleDate difference was more then 1 second")
    XCTAssertEqual(input.simpleEnumString, output.simpleEnumString, "/schema/referenced/object simpleEnumString did not match")
  }
  
  static let allTests = [
    ("testQueryOptionalParameters", testQueryOptionalParameters),
  ]
}