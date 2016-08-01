//
//  ViewController.swift
//  FavKeeper
//
//  Created by Guillaume Pabia on 30/07/2016.
//  Copyright © 2016 gpabia. All rights reserved.
//

import Photos
import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }




    @IBAction func pickImageButton(_ sender: AnyObject) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            if let imagePickerVC = self.storyboard?.instantiateViewController(withIdentifier: "ImagePickerViewController") as? ImagePickerViewController {
                self.navigationController?.pushViewController(imagePickerVC, animated: true)
            }
        } else {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                if status == .authorized {
                    if let imagePickerVC = self.storyboard?.instantiateViewController(withIdentifier: "ImagePickerViewController") as? ImagePickerViewController {
                        self.navigationController?.pushViewController(imagePickerVC, animated: true)
                    }
                }
            })
        }
        
    }
    
}

