import Vapor
// MultipleResponseCodesApiDelegate.swift
//
// Generated by SwiftVapor3 swagger-codegen
// https://github.com/swagger-api/swagger-codegen
// Template Input: /APIs.MultipleResponseCodes


public enum multipleResponseCodesResponse: ResponseEncodable {
  case http200
  case http201(SimpleObject)
  case http401
  case http500

  public func encode(for request: Request) throws -> EventLoopFuture<Response> {
    let response = request.response()
    switch self {
    case .http200:
      response.http.status = HTTPStatus(statusCode: 200)
    case .http201(let content):
      response.http.status = HTTPStatus(statusCode: 201)
      try response.content.encode(content)
    case .http401:
      response.http.status = HTTPStatus(statusCode: 401)
    case .http500:
      response.http.status = HTTPStatus(statusCode: 500)
    }
    return Future.map(on: request) { response }
  }
}

public protocol MultipleResponseCodesApiDelegate {
  /**
	POST /multiple/response/codes
    Test ability to support multiple response codes in a single call */
    
    func multipleResponseCodes(with req: Request, body: MultipleResponseCodeRequest) throws -> Future<multipleResponseCodesResponse>
}
