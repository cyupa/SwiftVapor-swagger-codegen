import Vapor
// FormDataApiDelegate.swift
//
// Generated by SwiftVapor3 swagger-codegen
// https://github.com/swagger-api/swagger-codegen
// Template Input: /APIs.FormData


public enum formRequestResponse: ResponseEncodable {
  case http200(SimpleObject)

  public func encode(for request: Request) throws -> EventLoopFuture<Response> {
    let response = request.response()
    switch self {
    case .http200(let content):
      response.http.status = HTTPStatus(statusCode: 200)
      try response.content.encode(content)
    }
    return Future.map(on: request) { response }
  }
}

public protocol FormDataApiDelegate {
  /**
	POST /form/request
    Test ability to parse form data */
    
    func formRequest(with req: Request, simpleString: SimpleString, simpleNumber: SimpleNumber, simpleInteger: SimpleInteger, simpleDate: SimpleDate, simpleEnumString: SimpleEnumString, simpleBoolean: SimpleBoolean, simpleArray: [SimpleString]) throws -> Future<formRequestResponse>
}