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
    let notificationUserInfoKeyCell: String = "cell"

    
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
                setImageWithImageURL(imageUrl: ro)
            }
        }
    }
    
    // MARK: - UI Components
    
    //  ImageView for Cell image
    let cellImageView:UIImageView = {
        
        let imgageView = UIImageView()
        // image will never be strecthed vertially or horizontally
        imgageView.contentMode = .scaleToFill
        imgageView.backgroundColor = .clear
        // enable autolayout
        imgageView.translatesAutoresizingMaskIntoConstraints = false
        imgageView.clipsToBounds = true
        return imgageView
    }()
    
    //  Label for Cell title
    let titleLabel: VerticalTopAlignLabel = {
        
        let label = VerticalTopAlignLabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor =  .black
        //  Setting number of lines to zero to support dynamic content.
        label.numberOfLines = 0
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //  Label for Cell Description
    let descriptionLabel: VerticalTopAlignLabel = {
        
        let label = VerticalTopAlignLabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor =  .gray
        //  Setting number of lines to zero to support dynamic content.
        label.numberOfLines = 0
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    //  containerView for Labels
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true // this will make sure its children do not go out of the boundary
        view.backgroundColor = .clear
        return view
    }()
    
    
    // MARK: - Initialising and UI layout Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutConstraints()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layoutConstraints()
        layoutIfNeeded()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        contentView.addSubview(containerView)
        contentView.addSubview(cellImageView)
        layoutConstraints()
        
    }
    
    // Method for Adding Constraints for SubViews
    func layoutConstraints() {
        
        
        //Adding Constraints
        let marginGuide = contentView.layoutMarginsGuide
        
        //configure ContainerView
        
        containerView.leadingAnchor.constraint(equalTo:marginGuide.leadingAnchor, constant:0).isActive = true
        containerView.topAnchor.constraint(equalTo:marginGuide.topAnchor, constant:0).isActive = true
        containerView.bottomAnchor.constraint(equalTo:marginGuide.bottomAnchor, constant:10).isActive = true
        let horizontalSpaceBetweenContainerAndImage = NSLayoutConstraint(item: cellImageView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1, constant: 5)
        contentView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 85))
        
        // configure titleLabel
        titleLabel.topAnchor.constraint(equalTo:self.containerView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo:self.containerView.trailingAnchor).isActive = true
    
        //Configure SubtitleLabel
        
        descriptionLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo:self.containerView.bottomAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo:self.containerView.trailingAnchor).isActive = true
        let verticalSpaceBetweenTitleAndDescription = NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 5)

        
        // configure ImageView
        cellImageView.topAnchor.constraint(equalTo:titleLabel.topAnchor, constant:0).isActive = true
        cellImageView.widthAnchor.constraint(equalToConstant:80).isActive = true
        cellImageView.heightAnchor.constraint(equalToConstant:80).isActive = true
        cellImageView.trailingAnchor.constraint(equalTo:marginGuide.trailingAnchor, constant:0).isActive = true
        NSLayoutConstraint.activate([horizontalSpaceBetweenContainerAndImage, verticalSpaceBetweenTitleAndDescription])
    
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
        
        cellImageView.sd_setImage(with: url, placeholderImage: UIImage(named: placeHolderImageName), options: .refreshCached, progress: nil, completed: {[weak self] (image, error, nil, url) in
            
            DispatchQueue.main.async {
                if let weekSelf = self {
                    if let _ = error {
                        weekSelf.cellImageView.image = UIImage(named: (weekSelf.placeHolderImageName))
                        weekSelf.cellImageView.setNeedsLayout()
                        
                    } else {
                    }
                }
            }
        })
    }
}

// Class for creating labels having vertical top alignment for texts in labels.
class VerticalTopAlignLabel: UILabel {
    
    override func drawText(in rect:CGRect) {
        guard let labelText = text else {  return super.drawText(in: rect) }
        
        let attributedText = NSAttributedString(string: labelText, attributes: [NSAttributedStringKey.font: font])
        var newRect = rect
        newRect.size.height = attributedText.boundingRect(with: rect.size, options: .usesLineFragmentOrigin, context: nil).size.height
        
        if numberOfLines != 0 {
            newRect.size.height = min(newRect.size.height, CGFloat(numberOfLines) * font.lineHeight)
        }
        
        super.drawText(in: newRect)
    }
}
