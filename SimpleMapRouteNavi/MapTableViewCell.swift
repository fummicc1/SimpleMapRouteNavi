//
//  MapTableViewCell.swift
//  SimpleMapRouteNavi
//
//  Created by FumiyaTanaka on 2019/12/21.
//  Copyright © 2019 FumiyaTanaka. All rights reserved.
//

import UIKit
import MapKit

class MapTableViewCell: UITableViewCell {
    
    @IBOutlet private var placeTitleLabel: UILabel!
    
    public func configure(_ placemark: MKPlacemark) {
        if let title = placemark.title {
            placeTitleLabel.text = title            
        } else {
            placeTitleLabel.text = "\(placemark.coordinate)"
        }
    }
    
}
