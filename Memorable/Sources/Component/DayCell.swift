//
//  DayCell.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/1/24.
//

import UIKit
import SnapKit

class DayCell: UICollectionViewCell {
    private let dayLabel = UILabel()
    private let dateLabel = UILabel()
    private let circleView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [circleView, dayLabel, dateLabel].forEach {
            contentView.addSubview($0)
        }
        
        circleView.layer.cornerRadius = 15
        
        circleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-28)
            make.width.height.equalTo(30)
        }
        
        dayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { make in
            make.center.equalTo(circleView)
        }
    }
    
    func configure(day: String, date: Date, isToday: Bool, attended: Bool, isFuture: Bool) {
        dayLabel.text = day
        dayLabel.font = MemorableFont.Body1()
        dayLabel.textColor = MemorableColor.Gray1
        dateLabel.text = String(Calendar.current.component(.day, from: date))
        dateLabel.font = MemorableFont.Body1()
        
        if isFuture {
            circleView.backgroundColor = .clear
            dateLabel.textColor = MemorableColor.Black
        } else {
            setAttended(attended)
        }
    }
    
    func setAttended(_ attended: Bool) {
        circleView.backgroundColor = attended ? MemorableColor.Blue2 : MemorableColor.Gray1
        dateLabel.textColor = MemorableColor.White
    }
}
