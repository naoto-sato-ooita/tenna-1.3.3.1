//
//  CountManager.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/07/15.
//
import SwiftUI
import Combine

final class CountManager: ObservableObject {
    
    static let shared = CountManager()
    private(set) var remainingCount: Int = 10
    
    func ResetHandler(limit: Int) {
        let currentDate = Date()
        //let lastLoginDate = UserDefaults.standard.object(forKey: "lastLoginDate") as? Date //過去の日付呼び出し
        if !self.isDifferentLoginDay() { //前回ログインデータあり,前回データと現在日時が同じ
            remainingCount = UserDefaults.standard.integer(forKey: "remainingCount")
        } else { //前回ログインデータなし,前回データと現在日時が違う
            remainingCount = limit //リミットを装填、残数にセット
            UserDefaults.standard.set(limit, forKey: "remainingCount")
        }
        UserDefaults.standard.set(currentDate, forKey: "lastLoginDate") //現在の日付を、LastDayにセット
    }
    
    
    func isDifferentLoginDay() -> Bool {
        let currentDate = Date()
        
        // 前回のログイン日時を取得
        if let lastLoginDate = UserDefaults.standard.object(forKey: "lastLoginDate") as? Date {
            
            // 前回のログイン日時と今回のログイン日時が同じ日かどうかを比較
            let calendar = Calendar.current
            let lastLoginDay = calendar.component(.day, from: lastLoginDate)
            let lastLoginMonth = calendar.component(.month, from: lastLoginDate)
            let lastLoginYear = calendar.component(.year, from: lastLoginDate)
            
            let currentDay = calendar.component(.day, from: currentDate)
            let currentMonth = calendar.component(.month, from: currentDate)
            let currentYear = calendar.component(.year, from: currentDate)
            
            // 日、月、年のいずれかが異なる場合はTrueを返す
            if lastLoginDay != currentDay || lastLoginMonth != currentMonth || lastLoginYear != currentYear {
                return true
            } else {
                return false
            }
            
        } else {
            // 前回のログイン日時が保存されていない場合は、異なる日とみなす
            return true
        }
    }
    
    // 機能使用時にカウントを減らす
    func useFeature() -> Bool {
        remainingCount = UserDefaults.standard.integer(forKey: "remainingCount")
        guard remainingCount > 0 else {
            return false
        }
        remainingCount -= 1
        UserDefaults.standard.set(remainingCount, forKey: "remainingCount")
        return true
    }
}

