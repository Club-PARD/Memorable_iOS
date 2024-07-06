//
//  StreakView.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/1/24.
//

// StreakView.swift

import SnapKit
import UIKit

class StreakView: UIView {
    private let collectionView: UICollectionView
    private var dates: [Date] = []
    var attendanceRecord: [Bool] = [true, true, true, false, false, true, true, true, false, false, false, false, false, false]
    private let koreanDays = ["일", "월", "화", "수", "목", "금", "토"]
    var score: Int = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient layers frame in layoutSubviews
        if let streakLeftGradientView = layer.sublayers?.first(where: { $0 is CAGradientLayer && ($0 as! CAGradientLayer).startPoint.x == 0 }) {
            streakLeftGradientView.frame = CGRect(x: 0, y: 0, width: bounds.width / 2, height: bounds.height)
        }
        
        if let streakRightGradientView = layer.sublayers?.first(where: { $0 is CAGradientLayer && ($0 as! CAGradientLayer).startPoint.x == 0.5 }) {
            streakRightGradientView.frame = CGRect(x: bounds.width / 2, y: 0, width: bounds.width / 2, height: bounds.height)
        }
    }
    
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)
        
        setupCollectionView()
        calculateDates()
        calculateWeekScore()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAttendanceRecord(_ record: [Bool]) {
        attendanceRecord = record
        calculateWeekScore()
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.register(DayCell.self, forCellWithReuseIdentifier: "DayCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
    }
    
    private func calculateDates() {
        let calendar = Calendar.current
        let today = Date()
        
        for i in -7...7 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(date)
            }
        }
    }
    
    private func calculateWeekScore() {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = weekday == 1 ? 6 : weekday - 2
        
        let startIndex = 7 - daysFromMonday
        let endIndex = startIndex + 6
        
        score = attendanceRecord[startIndex...endIndex].filter { $0 }.count
//        print("This week's attendance score: \(score)")
    }
}

extension StreakView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9 // 3일 전부터 3일 후까지
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! DayCell
        
        let dateIndex = indexPath.item + 3 // 7일 전부터 시작하므로 4를 더해 3일 전부터 시작
        let date = dates[dateIndex]
        let calendar = Calendar.current
        let dayIndex = calendar.component(.weekday, from: date) - 1
        let dayString = koreanDays[dayIndex]
        let isToday = calendar.isDateInToday(date)
        let attended = attendanceRecord[dateIndex]
        let isFuture = date > Date()
        
        cell.configure(day: dayString, date: date, isToday: isToday, attended: attended, isFuture: isFuture)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 28
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 28
    }
}
