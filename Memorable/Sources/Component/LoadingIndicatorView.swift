//
//  LoadingIndicator.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/11/24.
//

import UIKit
import SnapKit

class LoadingIndicatorView: UIView {
    
    private let grayTopLeftView: UIView = {
        let view = UIView()
        view.backgroundColor = MemorableColor.Gray4
        view.layer.cornerRadius = 13.39
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner] // 왼쪽만 radius
        return view
    }()
    
    private let blueTopRightView: UIView = {
        let view = UIView()
        view.backgroundColor = MemorableColor.Blue2
        view.layer.cornerRadius = 13.39 // 원
        return view
    }()
    
    private let yellowBottomLeftView: UIView = {
        let view = UIView()
        view.backgroundColor = MemorableColor.Yellow1
        view.layer.cornerRadius = 13.39
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner] // 오른쪽만 radius
        return view
    }()
    
    private let grayBottomRightView: UIView = {
        let view = UIView()
        view.backgroundColor = MemorableColor.Gray4
        view.layer.cornerRadius = 13.39 // 모두 radius
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        [grayTopLeftView, blueTopRightView, yellowBottomLeftView, grayBottomRightView].forEach {
            addSubview($0)
            $0.alpha = 0
        }
        
        grayBottomRightView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 63.61, height: 26.78))
            make.top.equalToSuperview().offset(55.8 - 26.7) // 아래쪽 기준
            make.leading.equalToSuperview().offset(93.75)
        }
        
        yellowBottomLeftView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 24.55, height: 26.78))
            make.top.equalToSuperview().offset(55.8 - 26.7 - 26.7) // 아래쪽 기준
            make.leading.equalToSuperview().offset(0) // 초기 위치를 수정
        }
        
        grayTopLeftView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 63.61, height: 26.78))
            make.top.equalToSuperview().offset(0)
            make.leading.equalToSuperview().offset(-63.61)
        }
        
        blueTopRightView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 26.78, height: 26.78))
            make.top.equalToSuperview().offset(-26.78)
            make.leading.equalToSuperview().offset(93.75 - 26.78) // 오른쪽 상단 기준
        }
        
        animateIn()
    }
    
    private func animateIn() {
        UIView.animate(withDuration: 0.5, animations: {
            self.grayBottomRightView.alpha = 1.0
            self.grayBottomRightView.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(93.75 - 63.61)
            }
            self.layoutIfNeeded()
        }) { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.yellowBottomLeftView.alpha = 1.0
                self.yellowBottomLeftView.snp.updateConstraints { make in
                    make.top.equalToSuperview().offset(55.8 - 26.7)
                }
                self.layoutIfNeeded()
            }) { _ in
                UIView.animate(withDuration: 0.5, animations: {
                    self.grayTopLeftView.alpha = 1.0
                    self.grayTopLeftView.snp.updateConstraints { make in
                        make.leading.equalToSuperview().offset(0)
                    }
                    self.layoutIfNeeded()
                }) { _ in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.blueTopRightView.alpha = 1.0
                        self.blueTopRightView.snp.updateConstraints { make in
                            make.top.equalToSuperview().offset(0)
                        }
                        self.layoutIfNeeded()
                    }) { _ in
                        self.animateOut()
                    }
                }
            }
        }
    }
    
    private func animateOut() {
        UIView.animate(withDuration: 0.5, animations: {
            self.grayBottomRightView.alpha = 0.0
            self.grayBottomRightView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(55.8)
            }
            self.layoutIfNeeded()
        }) { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.yellowBottomLeftView.alpha = 0.0
                self.yellowBottomLeftView.snp.updateConstraints { make in
                    make.leading.equalToSuperview().offset(-24.55)
                }
                self.layoutIfNeeded()
            }) { _ in
                UIView.animate(withDuration: 0.5, animations: {
                    self.grayTopLeftView.alpha = 0.0
                    self.grayTopLeftView.snp.updateConstraints { make in
                        make.top.equalToSuperview().offset(-26.78)
                    }
                    self.layoutIfNeeded()
                }) { _ in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.blueTopRightView.alpha = 0.0
                        self.blueTopRightView.snp.updateConstraints { make in
                            make.leading.equalToSuperview().offset(93.75)
                        }
                        self.layoutIfNeeded()
                    }) { _ in
                        self.resetPositions()
                        self.animateIn()
                    }
                }
            }
        }
    }
    
    private func resetPositions() {
            grayTopLeftView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(0)
                make.leading.equalToSuperview().offset(-63.61)
            }
            
            blueTopRightView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(-26.78)
                make.leading.equalToSuperview().offset(93.75 - 26.78)
            }
            
            yellowBottomLeftView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(55.8 - 26.78 - 26.78)
                make.leading.equalToSuperview().offset(0)
            }
            
            grayBottomRightView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(55.8 - 26.78)
                make.leading.equalToSuperview().offset(93.75)
            }
            
            grayTopLeftView.alpha = 0.0
            blueTopRightView.alpha = 0.0
            yellowBottomLeftView.alpha = 0.0
            grayBottomRightView.alpha = 0.0
            
            layoutIfNeeded()
        }
}
