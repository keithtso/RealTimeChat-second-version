//
//  ChatMessageCell.swift
//  RealTimeChat
//
//  Created by Keith Cao on 19/07/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    static let textBubbleColor = UIColor.init(r: 8, g: 137, b: 249)
    
    var message: Message?
    
    var charlogController: ChatLogController?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
        
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        return imageView
        
        
    }()
    
    @objc func handleZoomTap(gesture: UITapGestureRecognizer) {
        
        if message?.videoUrl != nil {
            return
        }
        
        guard let imageView = gesture.view as? UIImageView else { return }
        
        self.charlogController?.performZoomInForImage(startingImageView: imageView)
        
        
    }
    
    lazy var playButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "play") , for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
        
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    @objc func handlePlay() {
        
        guard let videoUrl = message?.videoUrl , let url = URL(string: videoUrl) else { return }
        
        player = AVPlayer(url: url)
        
        playerLayer = AVPlayerLayer(player: player)
        
        //set the player layer frame so that the video is visible on the bubbleview
        playerLayer?.frame = bubbleView.bounds
        bubbleView.layer.addSublayer(playerLayer!)
        
        player?.play()
        playButton.isHidden = true
        activityIndicatorView.startAnimating()
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "hello"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.textColor = .white
        tv.isScrollEnabled = false
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = textBubbleColor
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
        bubbleView.addSubview(playButton)
        bubbleView.addSubview(activityIndicatorView)
        
        profileImageView.layoutAnchor(top: nil, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 0, left: safeAreaLayoutGuide.leftAnchor, paddingLeft: 8, right: nil, paddingRight: 0, height: 32, width: 32)
        
        
        
        bubbleView.layoutAnchor(top: topAnchor, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 0, left: nil, paddingLeft: 0, right: nil, paddingRight: 0, height: 0, width: 0)
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -8)
        bubbleRightAnchor?.isActive = true
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        textView.layoutAnchor(top: topAnchor, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 0, left: bubbleView.leftAnchor, paddingLeft: 8, right: bubbleView.rightAnchor, paddingRight: 0, height: 0, width: 0)
        
        messageImageView.layoutAnchor(top: bubbleView.topAnchor, paddingTop: 0, bottom: bubbleView.bottomAnchor, paddingBottom: 0, left: bubbleView.leftAnchor, paddingLeft: 0, right: bubbleView.rightAnchor, paddingRight: 0, height: 0, width: 0)
        
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
