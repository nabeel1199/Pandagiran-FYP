

import Foundation
struct BaseResponse<ResponseData: Codable> : Codable {
  let status: Int
  let message: String
  let data: ResponseData?
}
