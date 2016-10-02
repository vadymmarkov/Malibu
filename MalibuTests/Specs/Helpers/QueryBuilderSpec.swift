@testable import Malibu
import Quick
import Nimble

class QueryBuilderSpec: QuickSpec {

  override func spec() {
    describe("QueryBuilder") {
      var builder: QueryBuilder!

      beforeEach {
        builder = QueryBuilder()
      }

      describe("#escapingCharacters") {
        it("should hold reserved characters") {
          expect(builder.escapingCharacters).to(equal(":#[]@!$&'()*+,;="))
        }
      }

      describe("#buildQuery") {
        context("with empty dictionary") {
          it("builds encoded query string") {
            let parameters = [String: Any]()
            expect(builder.buildQuery(parameters)).to(equal(""))
          }
        }

        context("with one string parameter") {
          it("builds encoded query string") {
            let parameters = ["firstname": "Taylor"]
            let string = "firstname=Taylor"

            expect(builder.buildQuery(parameters)).to(equal(string))
          }
        }

        context("with multiple string parameters") {
          it("builds encoded query string") {
            let parameters = ["firstname": "Taylor", "lastname": "Hyperseed"]
            let string = "firstname=Taylor&lastname=Hyperseed"

            expect(builder.buildQuery(parameters)).to(equal(string))
          }
        }

        context("with integer parameter") {
          it("builds encoded query string") {
            let parameters = ["value": 11]
            let string = "value=11"

            expect(builder.buildQuery(parameters)).to(equal(string))
          }
        }

        context("with double parameter") {
          it("builds encoded query string") {
            let parameters = ["value": 11.1]
            let string = "value=11.1"

            expect(builder.buildQuery(parameters)).to(equal(string))
          }
        }

        context("with boolean parameter") {
          it("builds encoded query string") {
            let parameters = ["value": true]
            let string = "value=1"

            expect(builder.buildQuery(parameters)).to(equal(string))
          }
        }

        context("with array parameter") {
          it("builds encoded query string") {
            let parameters = ["array": ["string", 11, true]]
            let string = "array%5B%5D=string&array%5B%5D=11&array%5B%5D=1"

            expect(builder.buildQuery(parameters)).to(equal(string))
          }
        }

        context("with dictionary parameter") {
          it("builds encoded query string") {
            let parameters = ["dictionary": ["value": 12]]
            let string = "dictionary%5Bvalue%5D=12"

            expect(builder.buildQuery(parameters)).to(equal(string))
          }
        }

        context("with nested dictionary parameter") {
          it("builds encoded query string") {
            let parameters = ["dictionary": ["nested": ["value": 7.1]]]
            let string = "dictionary%5Bnested%5D%5Bvalue%5D=7.1"

            expect(builder.buildQuery(parameters)).to(equal(string))
          }
        }

        context("with nested dictionary and array") {
          it("builds encoded query string") {
            let parameters = ["dictionary": ["nested": ["key": ["value", 8, true]]]]
            let string = "dictionary%5Bnested%5D%5Bkey%5D%5B%5D=value&dictionary%5Bnested%5D%5Bkey%5D%5B%5D=8&dictionary%5Bnested%5D%5Bkey%5D%5B%5D=1"

            expect(builder.buildQuery(parameters)).to(equal(string))
          }
        }
      }

      describe("#buildComponents:parameters") {
        it("builds a query component based on key and value") {
          let parameters: [String: Any] = ["firstname": "Taylor"]
          let components = builder.buildComponents(parameters: parameters)

          expect(components[0].0).to(equal("firstname"))
          expect(components[0].1).to(equal("Taylor"))
        }
      }

      describe("#buildComponents:key:value") {
        it("builds a query component based on key and value") {
          let key = "firstname"
          let value = "Taylor"
          let components = builder.buildComponents(key: key, value: value)

          expect(components[0].0).to(equal("firstname"))
          expect(components[0].1).to(equal("Taylor"))
        }
      }

      describe("#escape") {
        it("percent-escapes all reserved characters according to RFC 3986") {
          let string = builder.escapingCharacters
          let result = "%3A%23%5B%5D%40%21%24%26%27%28%29%2A%2B%2C%3B%3D"

          expect(builder.escape(string)).to(equal(result))
        }

        it("percent-escapes illegal ASCII characters") {
          let string = " \"#%<>[]\\^`{}|"
          let result = "%20%22%23%25%3C%3E%5B%5D%5C%5E%60%7B%7D%7C"

          expect(builder.escape(string)).to(equal(result))
        }

        it("percent-escapes non-latin characters") {
          expect(builder.escape("Børk Børk Børk!!")).to(equal("B%C3%B8rk%20B%C3%B8rk%20B%C3%B8rk%21%21"))
          expect(builder.escape("українська мова")).to(equal("%D1%83%D0%BA%D1%80%D0%B0%D1%97%D0%BD%D1%81%D1%8C%D0%BA%D0%B0%20%D0%BC%D0%BE%D0%B2%D0%B0"))
          expect(builder.escape("català")).to(equal("catal%C3%A0"))
          expect(builder.escape("Tiếng Việt")).to(equal("Ti%E1%BA%BFng%20Vi%E1%BB%87t"))
          expect(builder.escape("日本の")).to(equal("%E6%97%A5%E6%9C%AC%E3%81%AE"))
          expect(builder.escape("العربية")).to(equal("%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9"))
          expect(builder.escape("或許谷歌翻譯會給一些隨機的翻譯，現在")).to(equal("%E6%88%96%E8%A8%B1%E8%B0%B7%E6%AD%8C%E7%BF%BB%E8%AD%AF%E6%9C%83%E7%B5%A6%E4%B8%80%E4%BA%9B%E9%9A%A8%E6%A9%9F%E7%9A%84%E7%BF%BB%E8%AD%AF%EF%BC%8C%E7%8F%BE%E5%9C%A8"))
          expect(builder.escape("😃")).to(equal("%F0%9F%98%83"))
        }

        it("does not percent-escape reserved characters ? and /") {
          let string = "?/"

          expect(builder.escape(string)).to(equal(string))
        }

        it("does not percent-escape unreserved characters") {
          let string = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

          expect(builder.escape(string)).to(equal(string))
        }
      }
    }
  }
}
