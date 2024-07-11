//
//  LoadingViewController.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/11/24.
//

import UIKit
import SnapKit

class LoadingViewController: UIViewController {
    
    let loadingView = UIView()
    
    let loadingIndicatorView = LoadingIndicatorView()
    
    let loadingText = UILabel()
    
    var loadingMessage: String?
    
    init(loadingMessage: String?) {
        self.loadingMessage = loadingMessage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MemorableColor.Black?.withAlphaComponent(0.5)
        
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(31)
            make.centerX.equalToSuperview()
        }
        
        loadingView.addSubview(loadingIndicatorView)
        loadingIndicatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(93.75) // 적절한 크기로 설정
            make.height.equalTo(55.8)
        }
        
        loadingView.addSubview(loadingText)
        loadingText.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(loadingIndicatorView.snp.bottom).offset(28.2)
        }
        
        loadingText.text = loadingMessage
        loadingText.numberOfLines = 0
        loadingText.textAlignment = .center
        loadingText.textColor = MemorableColor.White
        loadingText.font = MemorableFont.BodyCaption()
    }
}
