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

    private var assets: PHFetchResult<PHAsset>?
    var assetCollection = PHAssetCollection()
    private var sideSize: CGFloat!


    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            reloadAssets()
        } else {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                if status == .authorized {
                    self.reloadAssets()
                }
            })
        }
    }

    private func reloadAssets() {
        assets = nil
        collectionView.reloadData()
        let options = PHFetchOptions()
        options.includeAssetSourceTypes = .typeUserLibrary
        options.predicate = Predicate(format: "isFavorite == 0")
        assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
        collectionView.reloadData()
        NSLog("assets: \(assets)")


        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)

        if let first_Obj:AnyObject = collection.firstObject{
            //found the album
            assetCollection = first_Obj as! PHAssetCollection
        }

        NSLog("asset collectollection : \(assetCollection)")

    }

}

extension ImagePickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func setCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets!.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        cell.imageView.backgroundColor = UIColor.red()
        guard let assets = assets else {
            NSLog("no assets error")
            return cell
        }
        //        NSLog("count: \(assets.count)")
        let asset = assets[indexPath.row]






        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 100,height: 40), contentMode: .aspectFill, options: nil) { (image: UIImage?, info: [NSObject : AnyObject]?) -> Void in
            cell.imageView.image = image
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var vari: [PHAsset] = []
        let ass = assets![indexPath.row]
        vari.append(ass)
        deleteAss()

        PHPhotoLibrary.shared().performChanges({
            // Create a change request from the asset to be modified.
            let request = PHAssetCollectionChangeRequest(for: self.assetCollection)
            // Set a property of the request to change the asset itself.

            request?.removeAssets(vari)

            }, completionHandler: { success, error in
                NSLog("Finished updating asset")
        })

        PHPhotoLibrary.shared().performChanges({
//            PHAssetChangeRequest.deleteAssets(ass)
            }, completionHandler: nil)
        NSLog("finish")
    }


    func deleteAss(){
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.predicate = Predicate(format: "isFavorite == 0")
        fetchOptions.sortDescriptors = [SortDescriptor(key: "creationDate", ascending: true)]

        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)

        if (fetchResult.lastObject != nil) {
            let lastAsset: PHAsset = fetchResult.lastObject! as PHAsset
            let first = fetchResult.firstObject! as PHAsset

//            let arr: [PHAsset] = [first,lastAsset]

            var arrayToDelete = NSArray(object: first)
            arrayToDelete = arrayToDelete.adding(lastAsset)
            PHPhotoLibrary.shared().performChanges( {
                PHAssetChangeRequest.deleteAssets(arrayToDelete)}, completionHandler: {
                    success, error in
                    NSLog("Finished deleting asset. %@")
            })
            
            
            
        }
    }
    
}
