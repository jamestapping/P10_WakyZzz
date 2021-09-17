//
//  AlarmsViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit
import UserNotifications

class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmCellDelegate, AlarmViewControllerDelegate {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var tableView: UITableView!
    
    // Local User Notifications
    let notificationCenter = UNUserNotificationCenter.current()
    
    // Notification center
    let nc = NotificationCenter.default
    
    var notificationScheduler = NotificationScheduler()
    var dataManager = DataManager()
    
    var alarms = [Alarm]()
    var managedAlarms = [ManagedAlarm]()
    var editingIndexPath: IndexPath?
    
    @IBAction func addButtonPress(_ sender: Any) {
        presentAlarmViewController(alarm: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //notificationScheduler.showPending()
        
        config()
        
    }
    
    func config() {
        
        nc.addObserver(self, selector:#selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        nc.addObserver(self, selector: #selector(didTapSnooze), name: Notification.Name("didTapSnooze"), object: nil)
        nc.addObserver(self, selector: #selector(didTapRemindMeLaterAction), name: Notification.Name("didTapRemindMeLaterAction"), object: nil)
        nc.addObserver(self, selector: #selector(didTapCompletedOrStop), name: Notification.Name("didTapCompletedOrStop"), object: nil)
        nc.addObserver(self, selector: #selector(didTapSnooze), name: Notification.Name("didTapNotification"), object: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchAllAlarms()
        
    }
    
    @objc func appMovedToForeground() {
        
        // reactivate the animation on the snooze image when we moe to foreground
        
        fetchAllAlarms()
        
    }
    
    @objc func didTapCompletedOrStop(_ notification: Notification) {
    
        // only need to remove the snooze symbol by resetting the snooze Count
        
        if let identifier = notification.userInfo?["identifier"] as? String {

            let uuid = UUID(uuidString: identifier)
            
            // get the alarm object for identifier
            
            if let index = alarms.firstIndex(where: { $0.uuid == uuid }) {
                
                let alarm = alarms[index]
                
                dataManager.resetSnoozeCount(for: alarm)
                
                fetchAllAlarms()
            }
            
        }
        
    }

    @objc func didTapSnooze(_ notification: Notification) {
        
        // Get the latest alarm objects
        
        fetchAllAlarms()
        
        // Get the identifier of the notification and use it for the snooze notification
        
        if let identifier = notification.userInfo?["identifier"] as? String {

            let uuid = UUID(uuidString: identifier)
            
            // get the alarm object for identifier
            
            if let index = alarms.firstIndex(where: { $0.uuid == uuid }) {
                
                notificationScheduler.manageSnooze(alarm: alarms[index])
                dataManager.updateSnoozeCount(for: alarms[index])
                
                fetchAllAlarms()
            }
            
        }

        
    }
    
    @objc func didTapRemindMeLaterAction(_ notification: Notification) {
        
        // Get the latest alarm objects
        
        fetchAllAlarms()
        
        // Get the identifier of the notification and use it for the snooze notification
        
        if let identifier = notification.userInfo?["identifier"] as? String {
            
            let uuid = UUID(uuidString: identifier)
            
            // get the alarm object for identifier
            
            if let index = alarms.firstIndex(where: { $0.uuid == uuid }) {
                
                notificationScheduler.createReminder(alarm: alarms[index])
            }
        
        }
        
    }
    
    func populateAlarms() {
        
        var alarm: Alarm
        
        // Weekdays 5am
        alarm = Alarm()
        alarm.time = 5 * 3600
        for i in 1 ... 5 {
            alarm.repeatDays[i] = true
        }
        alarms.append(alarm)
        
        // Weekend 9am
        alarm = Alarm()
        alarm.time = 9 * 3600
        alarm.enabled = false
        alarm.repeatDays[0] = true
        alarm.repeatDays[6] = true
        alarms.append(alarm)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return alarms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmTableViewCell
        cell.delegate = self
        
        if let alarm = alarm(at: indexPath) {
            
            let snoozeCount = alarm.snoozeCount
            
            cell.populate(caption: alarm.caption, subcaption: alarm.repeating, enabled: alarm.enabled, snoozeCount: snoozeCount)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [self] (action, view, completion) in
            
            deleteAlarm(at: indexPath)
            
            completion(true)
            
        }
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { [self] (action, view, completion) in
            
            editAlarm(at: indexPath)
            
            completion(true)
            
        }
            
            let config = UISwipeActionsConfiguration(actions: [delete, edit])
         
            return config
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 100
    }
    
    
    func alarm(at indexPath: IndexPath) -> Alarm? {
        return indexPath.row < alarms.count ? alarms[indexPath.row] : nil
    }
    
    func deleteAlarm(at indexPath: IndexPath) {
        tableView.beginUpdates()
        
        // Remove managedAlarm
        
        let alarm = alarms[indexPath.row]

        dataManager.deleteAlarm(alarm: alarm)

        notificationScheduler.disableAlarm(alarm: alarm)
        
        // Remove from alarms array
        
        alarms.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
    }
    
    func editAlarm(at indexPath: IndexPath) {
        editingIndexPath = indexPath
        presentAlarmViewController(alarm: alarm(at: indexPath))
    }
    
    func addAlarm(_ alarm: Alarm, at indexPath: IndexPath) {
        
        // Added to alarm array here
        
        alarms.insert(alarm, at: indexPath.row)
        
        fetchAllAlarms()
        
    }
    
    // Not used ...
    
    func moveAlarm(from originalIndextPath: IndexPath, to targetIndexPath: IndexPath) {
        let alarm = alarms.remove(at: originalIndextPath.row)
        alarms.insert(alarm, at: targetIndexPath.row)
        tableView.reloadData()
    }
    
    func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool) {
        
        if let indexPath = tableView.indexPath(for: cell) {
            if let alarm = self.alarm(at: indexPath) {
                
                alarm.enabled = enabled
                dataManager.updateAlarm(alarm: alarm)
                fetchAllAlarms()
                
            }
        }
    }
    
    func presentAlarmViewController(alarm: Alarm?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let popupViewController = storyboard.instantiateViewController(withIdentifier: "DetailNavigationController") as! UINavigationController
        let alarmViewController = popupViewController.viewControllers[0] as! AlarmViewController
        alarmViewController.alarm = alarm
        alarmViewController.delegate = self
        present(popupViewController, animated: true, completion: nil)
    }
    
    func alarmViewControllerDone(alarm: Alarm) {
        
        // Are we editing an alarm?
        
        if editingIndexPath != nil {
            
            dataManager.updateAlarm(alarm: alarm)
        
            
        } else {
            
            // Or adding a new alarm?
            
            let uuid = dataManager.addAlarm(alarm: alarm)
            
            // Schedule the alarm
            
            alarm.enabled ? notificationScheduler.enableAlarm(alarm: alarm, uuid: uuid ) : notificationScheduler.disableAlarm(alarm: alarm)
            
        }
        
        fetchAllAlarms()
        editingIndexPath = nil
        
        }
    
    
    func fetchAllAlarms() {
        
        managedAlarms = dataManager.returnAllAlarms()
        
        alarms = [Alarm]()
        
        // Build an array of alarms
        
        for managedAlarm in managedAlarms {
            
            let convertedAlarm = dataManager.convertAlarm(managedAlarm: managedAlarm)
            alarms.append(convertedAlarm)
            
        }
        
         let sortedAlarms = alarms.sorted {
            $0.time < $1.time
         }
        
        alarms = sortedAlarms
        
        DispatchQueue.main.async { [self] in
            
            tableView.reloadData()
            
        }
        
    }
    
    // To be removed

    func alarmViewControllerCancel() {
        
    //
        
  }
    
}

