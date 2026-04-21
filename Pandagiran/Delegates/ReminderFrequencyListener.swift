

import Foundation

protocol ReminderFrequencyListener {
    func onFrequencySelected (repeatInterval: String, repeatTitle: String, day: Int)
}
