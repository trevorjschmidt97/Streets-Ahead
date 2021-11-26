//
//  BrochureViewController.swift
//  SchtreetSchmarts
//
//  Created by Trevor Schmidt on 4/30/21.
//

import UIKit

class BrochureViewController: UIViewController {
    
    var collectionView: UICollectionView?
    
    var currentImage = 0
    var imgArr = [
        UIImage(named: "original"),
        UIImage(named: "brush"),
        UIImage(named: "tape"),
        UIImage(named: "stencils"),
        UIImage(named: "final")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        collectionView?.isPagingEnabled = true
        collectionView?.dataSource = self
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.register(ImageCollectionViewCell.self,
                                 forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        
        view.addSubview(collectionView!)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView?.frame = view.safeAreaLayoutGuide.layoutFrame
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.selectItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, animated: true, scrollPosition: .left)
    }
}

extension BrochureViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as! ImageCollectionViewCell
        
        let image = imgArr[indexPath.row]
        cell.configure(image: image!)
        
        return cell
    }
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ImageCollectionViewCell"
    
    
    // Subviews
    var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(image: UIImage) {
        imageView = UIImageView(frame: contentView.safeAreaLayoutGuide.layoutFrame)
        imageView?.contentMode = .scaleAspectFit
        imageView?.image = image
        contentView.addSubview(imageView!)
    }
}
