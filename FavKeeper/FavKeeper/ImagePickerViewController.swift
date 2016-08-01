//
//  ImagePickerViewController.swift
//  FavKeeper
//
//  Created by Guillaume Pabia on 30/07/2016.
//  Copyright © 2016 gpabia. All rights reserved.
//

import UIKit
import Photos

class ImagePickerViewController: UIViewController {

    let reuseIdentifier = "imageCell"

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activity: UIActivityIndicatorView!

    private var assets: PHFetchResult<PHAsset>?
    var assetCollection = PHAssetCollection()
    private var sideSize: CGFloat!
    private var arrayToDelete: NSArray = NSArray()
    private var indexArray: [IndexPath] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
        self.activity.alpha = 0
        self.activity.stopAnimating()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        reloadAssets()
    }

    @IBAction func deleteSelection(_ sender: AnyObject) {
        PHPhotoLibrary.shared().performChanges( {
            PHAssetChangeRequest.deleteAssets(self.arrayToDelete)}, completionHandler: {
                success, error in

                if error == nil {
                    DispatchQueue.main.async {
                        if let endVC = self.storyboard?.instantiateViewController(withIdentifier: "EndViewController") {
                            self.navigationController?.pushViewController(endVC, animated: true)
                        }
                    }
                    self.activity.stopAnimating()
                    NSLog("Finished deleting asset. %@")
                }
        })
    }

    @IBAction func backButton(_ sender: AnyObject) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    private func reloadAssets() {
        assets = nil
        collectionView.reloadData()
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.predicate = Predicate(format: "isFavorite == 0")
        fetchOptions.sortDescriptors = [SortDescriptor(key: "creationDate", ascending: true)]
        assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        guard let count = assets?.count else {
            NSLog("error count")
            return
        }

        if count-1 > 0 {
        for i in 0...count-1 {
            guard let asset = assets?[i] else {
                NSLog("no asset")
                return
            }
            self.arrayToDelete = self.arrayToDelete.adding(asset)
            }
        } else {
            NSLog("error")
            let label = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 200, height: 200)))
            label.text = "You don't have any picture which isn't favorite"
            label.numberOfLines = 0
            label.textAlignment = .center
            self.collectionView.backgroundView = label
        }
        collectionView.reloadData()
    }



//    @IBAction func selectAllAction(_ sender: AnyObject) {
//        for index in 0...self.collectionView.numberOfItems(inSection: 0)-1 {
//            self.addToDeleteAssets(index: index)
//        }
//
//        self.collectionView.reloadData()
//    }

}

extension ImagePickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func setCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        cell.imageView.backgroundColor = UIColor.red()
        guard let assets = assets else {
            NSLog("no assets error")
            return cell
        }
        let asset = assets[indexPath.row]
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 100,height: 100), contentMode: .aspectFill, options: nil) { (image: UIImage?, info: [NSObject : AnyObject]?) -> Void in
            cell.imageView.image = image
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        addToDeleteAssets(index: indexPath.row)
        NSLog("indexpath: \(indexPath)")
        guard let _ = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else {
            NSLog("error cell selected nil")
            return
        }
    }


    func addToDeleteAssets(index: Int){
        let thisAsset = assets?.object(at: index)
        let path = IndexPath(row: index, section: 0)
        guard let cell = self.collectionView.cellForItem(at: path) else {
            NSLog("error")
            return
        }
        cell.layer.borderWidth = 4.0
        cell.layer.borderColor = UIColor.orange().cgColor
        indexArray.append(path)
        self.arrayToDelete = arrayToDelete.adding(thisAsset!)
    }
    
}
