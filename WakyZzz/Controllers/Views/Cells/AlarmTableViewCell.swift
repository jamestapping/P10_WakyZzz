//
//  AlarmTableViewCell.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit

protocol AlarmCellDelegate {
    
    func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool)
}

class AlarmTableViewCell: UITableViewCell {
    
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var subcaptionLabel: UILabel!
    @IBOutlet weak var enabledSwitch: UISwitch!
    @IBOutlet weak var snoozing: UIImageView!
    
    var delegate: AlarmCellDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        configure()
    }
    
    func configure() {
        
    }
    
    func populate(caption: String, subcaption: String, enabled: Bool, snoozeCount: Int) {
        
        captionLabel.text = caption
        subcaptionLabel.text = subcaption
        enabledSwitch.isOn = enabled
        snoozing.isHidden = !(snoozeCount != 0)
        snoozing.blink()
    }
    
    
    @IBAction func enabledSwitchChanged(_ sender: UISwitch) {
        
        delegate?.alarmCell(self, enabledChanged: enabledSwitch.isOn)
        
    }

}
