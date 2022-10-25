//
//  ViewModel.swift
//  ClassToday
//
//  Created by 박태현 on 2022/10/25.
//

import Foundation

protocol ViewModel {
    
}

protocol FetchingViewModel: ViewModel {
    func fetchData()
}
