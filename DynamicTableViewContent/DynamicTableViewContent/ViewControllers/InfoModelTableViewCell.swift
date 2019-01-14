//
//  InfoModelTableViewCell.swift
//  DynamicTableViewContent
//
//  Created by Jitesh Sharma on 14/01/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

import UIKit
import SDWebImage

class InfoModelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewa: UIImageView!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var title: UILabel!
    
    var row: Row? {
        didSet{
            guard let row = row else {
                return
            }
            if let titleString = row.title {
                title.text = titleString
            }
            if let description = row.description {
                subTitle.text = description
            }
            if let ro = row.imageHref {
                downloadImgae(imgUrl: ro)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension InfoModelTableViewCell{
    func downloadImgae(imgUrl:String?){

            if let mediaUrl = imgUrl {
                imageViewa.sd_setShowActivityIndicatorView(true)
                imageViewa.sd_setIndicatorStyle(.gray)
                imageViewa.sd_setImage(with: URL(string: mediaUrl), completed: { [weak self] (image, error, cacheType, imageURL) in
                    if let error = error {
                         print(error)
                    }
                   
                    self?.imageViewa.image = image
                    self?.layoutIfNeeded()
                    self?.setNeedsLayout()
                })
            }
        }
    }
