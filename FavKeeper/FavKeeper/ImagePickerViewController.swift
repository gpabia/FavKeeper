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

    private var assets: PHFetchResult?
    var assetCollection = PHAssetCollection()
    private var sideSize: CGFloat!
    private var arrayToDelete: NSArray = NSArray()
    private var indexArray: [NSIndexPath] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
        self.activity.alpha = 0
        self.activity.stopAnimating()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        reloadAssets()
    }

    @IBAction func deleteSelection(sender: AnyObject) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges( {
            PHAssetChangeRequest.deleteAssets(self.arrayToDelete)}, completionHandler: {
                success, error in

                if error == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let endVC = self.storyboard?.instantiateViewControllerWithIdentifier("EndViewController") {
                            self.navigationController?.pushViewController(endVC, animated: true)
                        }
                    })
                    NSLog("Finished deleting asset")
                }
        })
    }

    @IBAction func backButton(sender: AnyObject) {
        _ = self.navigationController?.popToRootViewControllerAnimated(true)
    }

    private func reloadAssets() {
        assets = nil
        collectionView.reloadData()
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "isFavorite == 0")
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        assets = PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions)
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
            self.arrayToDelete = self.arrayToDelete.arrayByAddingObject(asset)
            }
        } else {
            NSLog("error")
            let label = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 200, height: 200)))
            label.text = "You don't have any picture which isn't favorite"
            label.numberOfLines = 0
            label.textAlignment = .Center
            self.collectionView.backgroundView = label
        }
        collectionView.reloadData()
    }


}

extension ImagePickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func setCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell
        cell.imageView.backgroundColor = UIColor.redColor()
        guard let assets = assets else {
            NSLog("no assets error")
            return cell
        }
        let asset = assets[indexPath.row]
        PHImageManager.defaultManager().requestImageForAsset(asset as! PHAsset, targetSize: CGSize(width: 100,height: 100), contentMode: .AspectFit, options: nil) { (image, _: [NSObject : AnyObject]?) in
            cell.imageView.image = image
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAt indexPath: NSIndexPath) {
        addToDeleteAssets(indexPath.row)
        NSLog("indexpath: \(indexPath)")
        guard let _ = collectionView.cellForItemAtIndexPath(indexPath) as? ImageCollectionViewCell else {
            NSLog("error cell selected nil")
            return
        }
    }


    func addToDeleteAssets(index: Int){
        let thisAsset = assets?.objectAtIndex(index)
        let path = NSIndexPath(forRow: index, inSection: 0)
        guard let cell = self.collectionView.cellForItemAtIndexPath(path) else {
            NSLog("error")
            return
        }
        cell.layer.borderWidth = 4.0
        cell.layer.borderColor = UIColor.orangeColor().CGColor
        indexArray.append(path)
        self.arrayToDelete = arrayToDelete.arrayByAddingObject(thisAsset!)
    }
    
}
