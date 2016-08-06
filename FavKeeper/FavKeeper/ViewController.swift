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
    @IBOutlet weak var pickButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.pickButton.layer.borderWidth = 2
        self.pickButton.layer.cornerRadius = 15
        self.pickButton.tintColor = UIColor.whiteColor()
        // Do any additional setup after loading the view, typically from a nib.

        if PHPhotoLibrary.authorizationStatus() == .Authorized {
            if let imagePickerVC = self.storyboard?.instantiateViewControllerWithIdentifier("ImagePickerViewController") as? ImagePickerViewController {
                self.navigationController?.pushViewController(imagePickerVC, animated: true)
            }
        } else {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                if status == .Authorized {
                    if let imagePickerVC = self.storyboard?.instantiateViewControllerWithIdentifier("ImagePickerViewController") as? ImagePickerViewController {
                        self.navigationController?.pushViewController(imagePickerVC, animated: true)
                    }
                }
            })
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }




    @IBAction func pickImageButton(sender: AnyObject) {
        if let imagePickerVC = self.storyboard?.instantiateViewControllerWithIdentifier("ImagePickerViewController") as? ImagePickerViewController {
            self.navigationController?.pushViewController(imagePickerVC, animated: true)
        }

    }

}

