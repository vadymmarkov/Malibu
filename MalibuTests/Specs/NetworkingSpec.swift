@testable import Malibu
import Quick
import Nimble

// MARK: - Mocks


class ChallengeSender: NSObject, URLAuthenticationChallengeSender {

  func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {}
  func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {}
  func cancel(_ challenge: URLAuthenticationChallenge) {}
}

// MARK: - Specs

class NetworkingSpec: QuickSpec {

  override func spec() {
    describe("Networking") {
      describe("#init") {
        it("sets default configuration to the session") {
          let networking = Networking<TestService>()
          expect(networking.session.configuration).to(equal(SessionConfiguration.default.value))
        }
      }

      describe("#request") {
        context("when request has a mock") {
          it("returns a mock data") {
            let mockProvider = MockProvider<TestService> { _ in
              return Mock(json: ["title": "Test"])
            }

            let networking = Networking(mockProvider: mockProvider)
            let expectation = self.expectation(description: "Request")

            networking.request(.showPost(id: 1)).toJsonDictionary().done({ json in
              expect(json["title"] as? String).to(equal("Test"))
              expectation.fulfill()
            })

            self.waitForExpectations(timeout: 1.0, handler: nil)
          }
        }
      }

      describe("#urlSession:didReceiveChallenge:completionHandler:") {
        let session = URLSession(configuration: URLSessionConfiguration.default)

        context("with NSURLAuthenticationMethodServerTrust") {
          let protectionSpace = self.createProtectionSpace(
            authenticationMethod: NSURLAuthenticationMethodServerTrust
          )
          let challenge = self.createAuthenticationChallenge(
            protectionSpace: protectionSpace,
            previousFailureCount: 0
          )

          context("with baseUrl and no serverTrust") {
            it("passess valid parameters to completion") {
              let networking = Networking<TestService>()
              networking.urlSession(session, didReceive: challenge) { disposition, credential in
                expect(disposition == .performDefaultHandling).to(beTrue())
                expect(credential).to(beNil())
              }
            }
          }

          context("without baseUrl") {
            it("passess valid parameters to completion") {
              let networking = Networking<AnyEndpoint>()
              networking.urlSession(session, didReceive: challenge) { disposition, credential in
                expect(disposition == .performDefaultHandling).to(beTrue())
                expect(credential).to(beNil())
              }
            }
          }
        }

        context("with other authentication methods") {
          let protectionSpace = self.createProtectionSpace(
            authenticationMethod: NSURLAuthenticationMethodClientCertificate
          )

          context("with one previous failure") {
            it("passess valid parameters to completion") {
              let networking = Networking<TestService>()
              let challenge = self.createAuthenticationChallenge(
                protectionSpace: protectionSpace,
                previousFailureCount: 1
              )

              networking.urlSession(session, didReceive: challenge) { disposition, credential in
                expect(disposition == .rejectProtectionSpace).to(beTrue())
                expect(credential).to(beNil())
              }
            }
          }

          context("with no previous failures and no defaultCredential") {
            it("passess valid parameters to completion") {
              let networking = Networking<AnyEndpoint>()
              let challenge = self.createAuthenticationChallenge(
                protectionSpace: protectionSpace,
                previousFailureCount: 0
              )
              
              networking.urlSession(session, didReceive: challenge) { disposition, credential in
                expect(disposition == .performDefaultHandling).to(beTrue())
                expect(credential).to(beNil())
              }
            }
          }
        }
      }
    }
  }

  private func createAuthenticationChallenge(protectionSpace: URLProtectionSpace,
                                             previousFailureCount: Int) -> URLAuthenticationChallenge {
    let sender = ChallengeSender()

    return URLAuthenticationChallenge(
      protectionSpace: protectionSpace,
      proposedCredential: nil,
      previousFailureCount: previousFailureCount,
      failureResponse: nil,
      error: nil,
      sender: sender
    )
  }

  private func createProtectionSpace(authenticationMethod: String,
                                     host: String = "http://api.loc") -> URLProtectionSpace {
    return URLProtectionSpace (
      host: host,
      port: 0880,
      protocol: nil,
      realm: nil,
      authenticationMethod: authenticationMethod
    )
  }
}
