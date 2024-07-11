//
//  LoadingViewController.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/11/24.
//

import UIKit
import SnapKit

class LoadingViewController: UIViewController {
    
    let loadingIndicatorView = LoadingIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        
        view.addSubview(loadingIndicatorView)
        loadingIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(93.75) // 적절한 크기로 설정
            make.height.equalTo(55.8)
        }
    }
}
