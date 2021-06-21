//
//  GetPhoto.swift
//  snap
//
//  Created by Olivier Wittop Koning on 16/06/2021.
//

import MSAL

extension MsAuthManger {
    func GetPhoto() {
        let url = URL(string: "https://graph.microsoft.com/v1.0/me/photo/$value")
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                self.ErrorMsg = NSLocalizedString("Couldn't get graph photo: \(error)", comment: "bij /photo")
                return
            }
            
            if let d = data {
                var image = UIImage(data: d)
                if let img = image {
                    
                    let targetSize = CGSize(width: 100, height: 100)
                    
                    // Compute the scaling ratio for the width and height separately
                    let widthScaleRatio = targetSize.width / (img.size.width)
                    let heightScaleRatio = targetSize.height / (img.size.height)
                    
                    // To keep the aspect ratio, scale by the smaller scaling ratio
                    let scaleFactor = min(widthScaleRatio, heightScaleRatio)
                    
                    // Multiply the original image’s dimensions by the scale factor
                    // to determine the scaled image size that preserves aspect ratio
                    let scaledImageSize = CGSize(
                        width: (img.size.width) * scaleFactor,
                        height: (img.size.height) * scaleFactor
                    )
                    let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
                    image = renderer.image { _ in
                        img.draw(in: CGRect(origin: .zero, size: scaledImageSize))
                    }
                } else {
                    image = UIImage(systemName: "person.fill")!
                }
                
                
                DispatchQueue.main.async {
                    self.ProfilePicture = image!
                }
            } else {
                print("No data with profile picture")
            }
        }.resume()
    }
}
