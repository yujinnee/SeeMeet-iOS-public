//
//  PutInvitationListService.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/08/10.
//

import Alamofire
import Foundation

struct PutInvitationListService {
    static let shared = PutInvitationListService()
    
    func putInvitationListCancel(invitationId: String, completion : @escaping (NetworkResult<Any>) -> Void) {
        // completion 클로저를 @escaping closure로 정의합니다.
        let URL = Constants.URL.plansListURL + "/" + "\(invitationId)"

        let header : HTTPHeaders = TokenUtils.shared.getAuthorizationHeader() ?? ["Content-Type": "application/json"]

        let dataRequest = AF.request(URL,
                                     method: .put,
                                     encoding: JSONEncoding.default,
                                     headers: header)

        dataRequest.responseData { dataResponse in
            switch dataResponse.result {
            case .success:
                guard let statusCode = dataResponse.response?.statusCode else {return}
                guard let value = dataResponse.value else {return}
                let networkResult = self.judgeStatus(by: statusCode, value)
                completion(networkResult)

            case .failure: completion(.pathErr)
                print("실패 사유")
            }
        }
    }
    
    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        switch statusCode {
        case 200: return isValidData(data: data)
        case 400: return .pathErr
        case 500: return .serverErr
        default: return .networkFail
        }
    }
    
    private func isValidData(data : Data) -> NetworkResult<Any> {
        
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(InvitationListCancelDataModel.self, from: data)
        else { return .pathErr }
        
        return .success(decodedData)
    }
}
