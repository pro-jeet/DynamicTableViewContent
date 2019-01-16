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
    
    // MARK: - Constants
    let placeHolderImageName: String = "placeholder"
    let notificationIdendifier: String = "reloadCell"
    let notificationUserInfoKeyURL: String = "invalidURL"
    let notificationUserInfoKeyCell: String = "cell"

    // MARK: - Variables
    var validURL = true
    
    // MARK: - Setting Mapping model Data with UI components
    
    var row: Row? {
        
        didSet {
            guard let row = row else {
                return
            }
            if let titleString = row.title {
                titleLabel.isHidden = false
                titleLabel.text = titleString
            } else {
                titleLabel.isHidden = true
            }
            if let description = row.description {
                descriptionLabel.isHidden = false
                descriptionLabel.text = description
            } else {
                descriptionLabel.isHidden = true
            }
            if let ro = row.imageHref {
                if validURL {
                    setImageWithImageURL(imageUrl: ro)
                    cellImageView.isHidden = false
                } else {
                    cellImageView.isHidden = true
                }
            }
        }
    }
   
    // MARK: - UI Components
    
    //  ImageView for Cell image
    let cellImageView:UIImageView = {
        
        let imgageView = UIImageView()
        // image will never be strecthed vertially or horizontally
        imgageView.contentMode = .scaleAspectFit
        // enable autolayout
        imgageView.translatesAutoresizingMaskIntoConstraints = false
        return imgageView
    }()
    
    //  Label for Cell title
    let titleLabel:UILabel = {
        
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor =  .red
        //  Setting number of lines to zero to support dynamic content.
        label.numberOfLines = 0
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //  Label for Cell Description
    let descriptionLabel:UILabel = {
        
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor =  .blue
        //  Setting number of lines to zero to support dynamic content.
        label.numberOfLines = 0
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialising and UI layout Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.preferredMaxLayoutWidth = titleLabel.bounds.size.width
        descriptionLabel.preferredMaxLayoutWidth = descriptionLabel.bounds.size.width
        layoutConstraints()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layoutConstraints()
        layoutIfNeeded()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(cellImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        layoutConstraints()
        
    }

    // Method for Adding Constraints for SubViews
    func layoutConstraints() {
        
        //Adding Constraints
        let marginGuide = contentView.layoutMarginsGuide
        
        // configure ImageView
        cellImageView.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        cellImageView.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        cellImageView.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        
        // configure titleLabel
        titleLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        let verticalSpace1 = NSLayoutConstraint(item: cellImageView, attribute: .bottom, relatedBy: .equal, toItem: titleLabel, attribute: .top, multiplier: 1, constant: 0)

        // configure SubtitleLabel
        descriptionLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        let verticalSpace = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: descriptionLabel, attribute: .top, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([verticalSpace,verticalSpace1])
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        layoutIfNeeded()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension InfoModelTableViewCell {
    
    func setImageWithImageURL(imageUrl: String){
        
        let url = URL(string: imageUrl)
        cellImageView.sd_setShowActivityIndicatorView(true)
        cellImageView.sd_setIndicatorStyle(.gray)
        cellImageView.sd_setImage(with: url, placeholderImage: UIImage(named: placeHolderImageName), options: .scaleDownLargeImages, progress: nil, completed: {[weak self] (image, error, nil, url) in
            
            DispatchQueue.main.async {
                if let weekSelf = self {
                    if let _ = error {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: weekSelf.notificationIdendifier), object: nil, userInfo: [weekSelf.notificationUserInfoKeyURL : imageUrl, weekSelf.notificationUserInfoKeyCell: weekSelf])
                        weekSelf.cellImageView.isHidden = true
                        weekSelf.validURL = false
                    } else {
                        weekSelf.cellImageView.isHidden = false
                    }
                }
            }
        })
    }
}
