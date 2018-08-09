//
//  PhotoCollectionCell.swift
//  Flickr
//
//  Created by Alexey Bukhtin on 24/05/2018.
//  Copyright © 2018 F3 Software. All rights reserved.
//

import UIKit
import Reusable
import RxSwift

final class PhotoCollectionCell: UICollectionViewCell, NibReusable {
    
    private(set) var disposeBag = DisposeBag()
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resetCell()
    }
    
    override func prepareForReuse() {
        resetCell()
    }
    
    private func resetCell() {
        disposeBag = DisposeBag()
        imageView.image = nil
    }
}
