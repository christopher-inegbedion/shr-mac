//
//  CardCollectionView.swift
//  Shr
//
//  Created by Christopher Inegbedion on 18/02/2023.
//

import Cocoa

class CardCollectionView: NSBox {
    var delegate: CardCollectionViewDelegate?
    
    private var titleView: NSView!
    private var removeCardButton: NSButton!
    private var visibleCardIndex: Int?
    
    private let inactiveCard1TopMargin = 20.0
    private let inactiveCard2TopMargin = 30.0
    
    private let inactiveCard1WidthDifference = 20.0
    private let inactiveCard2WidthDifference = 40.0
    
    private let cardHeight = 300.0
    
    var cardsInserted: [Int] = []
    fileprivate var cards: [Int:ViewConstraints] = [:]

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        initialise()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialise()
    }
    
    func showCard(type: CardType, data: Any?) {
        displayNewCardView(cardType: type, data: data)
    }
    
    /// Setup the view
    private func initialise() {
        // Add the remove 'X' button
        removeCardButton = NSButton(image: NSImage(systemSymbolName: "xmark", accessibilityDescription: nil)!, target: self, action: #selector(removeButtonAction))
        removeCardButton.isBordered = false
        addSubview(removeCardButton)
        
        removeCardButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            removeCardButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 2),
            removeCardButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 2)
        ])
        
        // Add the no card label
        let noCardLabel = NSTextField(labelWithString: "People, Files, Folders, etc., are displayed here")
        noCardLabel.font = NSFont(name: "BasisGrotesqueMonoPro-Regular", size: 12)
        noCardLabel.textColor = .gray
        
        addSubview(noCardLabel)
        noCardLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noCardLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            noCardLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
    
    /// Create the base card view that holds the other specialised views (File, All Files, etc)
    private func createBaseCard(cardColor: NSColor) -> NSView {
        let mainView = NSView()
        mainView.wantsLayer = true
        mainView.layer?.backgroundColor = cardColor.cgColor
        mainView.layer?.borderWidth = 1
        mainView.layer?.borderColor = NSColor(rgb: 0xE8E8E8).cgColor
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        return mainView
    }
    
    private func addNewCardView(view: NSView, type: CardType) {
        view.alphaValue = 0
        addSubview(view)
        
        let topConstraint = view.topAnchor.constraint(equalTo: removeCardButton.bottomAnchor, constant: inactiveCard2TopMargin)
        let bottomConstraint = view.bottomAnchor.constraint(equalTo: removeCardButton.bottomAnchor)
        let widthConstraint = view.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -inactiveCard2WidthDifference)
        let heightConstraint = view.heightAnchor.constraint(equalToConstant: cardHeight)
        let centerXConstraint = view.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        
        topConstraint.isActive = true
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        centerXConstraint.isActive = true
        
        cards[cards.count] = ViewConstraints(view: view, type: type, topConstraint: topConstraint, bottomConstraint: bottomConstraint, widthConstraint: widthConstraint, heightConstraint: heightConstraint, centerXConstraint: centerXConstraint)
        cardsInserted.append(cardsInserted.count)
        
        self.visibleCardIndex = self.cardsInserted.count-1
    }
    
    private func setCardAsFileType(baseView: NSView, block: Block) {
        let fileView = FileCardView()
        fileView.setBlock(block: block)
        baseView.addSubview(fileView)
        
        fileView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fileView.widthAnchor.constraint(equalTo: baseView.widthAnchor),
            fileView.heightAnchor.constraint(equalTo: baseView.heightAnchor)
        ])
    }
    
    private func setCardAsAllFilesType(baseView: NSView) {
        let allFilesView = ViewAllCardsView()
        allFilesView.setParentView(parentView: self)
        baseView.addSubview(allFilesView)
        
        allFilesView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            allFilesView.widthAnchor.constraint(equalTo: baseView.widthAnchor),
            allFilesView.heightAnchor.constraint(equalTo: baseView.heightAnchor)
        ])
    }
    
    @objc private func removeButtonAction() {
        guard visibleCardIndex != nil else { return }
        guard visibleCardIndex! != -1 else { return }
        
        animateCardRemoval(index: visibleCardIndex!)
    }
    
    private func displayNewCardView(cardType: CardType, data: Any?) {
        let baseCardView = createBaseCard(cardColor: .white)
        addNewCardView(view: baseCardView, type: cardType)
        
        switch cardType {
            case .file:
                let block = data as! Block
                showCardTitle(type: .file)
                setCardAsFileType(baseView: baseCardView, block: block)
            case .allFilesFolders:
                removeTitleView()
                setCardAsAllFilesType(baseView: baseCardView)
                
        }
        
        delegate?.cardAdded(count: cardsInserted.count)
        animateCardMovement(index: cardsInserted.count-1)
    }
    
    private func showCardTitle(type: CardType) {
        removeTitleView()
        
        if type == .file {
            titleView = NSView()
            let title = NSTextField(labelWithString: "Uploaded by You")
            title.font = NSFont(name: "BasisGrotesqueMonoPro-Regular", size: 10)
            title.textColor = .gray
            let dot = NSImageView(image: NSImage(systemSymbolName: "circle.fill", accessibilityDescription: nil)!)
            dot.contentTintColor = .black
            
            titleView.translatesAutoresizingMaskIntoConstraints = false
            title.translatesAutoresizingMaskIntoConstraints = false
            dot.translatesAutoresizingMaskIntoConstraints = false
            
            titleView.addSubview(title)
            titleView.addSubview(dot)
            titleView.wantsLayer = true
            
            NSLayoutConstraint.activate([
                titleView.heightAnchor.constraint(equalTo: title.heightAnchor),
                titleView.widthAnchor.constraint(equalToConstant: title.frame.width+5+dot.frame.width),
                dot.heightAnchor.constraint(equalToConstant: 4),
                dot.widthAnchor.constraint(equalToConstant: 4),
                dot.centerYAnchor.constraint(equalTo: title.centerYAnchor),
                dot.leadingAnchor.constraint(equalTo: title.trailingAnchor, constant: 5)
            ])
            addSubview(titleView)
            
            titleView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                titleView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                titleView.centerYAnchor.constraint(equalTo: removeCardButton.centerYAnchor)
            ])
            
        }
    }
    
    /// Animates a new view being inserted into view
    private func animateCardMovement(index: Int) {
        let a = cards[index]

        let topConstraint = a?.topConstraint
        let widthConstraint = a?.widthConstraint
        
        let i = getWidthAndTopMargin(index: index)
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            a!.view.animator().alphaValue = 1
            
            topConstraint!.animator().constant = i.1
            
            if i.0 == 0 {
                widthConstraint!.animator().constant = i.0
            } else {
                widthConstraint!.animator().constant = -i.0
            }
        })
        
        if index == visibleCardIndex {
            for j in cardsInserted {
                let i = visibleCardIndex!-j
                if (i <= 2 && j != visibleCardIndex) {
                    animateCardMovement(index: j)
                    
                    // prevent accidental touches of the all files card
                    let card = cards[j]
                    
                    if card!.type == .allFilesFolders {
                        let cardView = card!.view
                        (cardView.subviews[0] as! ViewAllCardsView).isInteractionEnabled(false)
                    }
                } else if (i > 2) {
                    cards[j]!.view.isHidden = true
                }
            }
            
        }
    }
    
    /// Animates a card being removed from view
    private func animateCardRemoval(index: Int) {
        let a = cards[index]
        let view = a?.view
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            view?.animator().alphaValue = 0
        }, completionHandler: { [self] in
            view?.removeFromSuperview()
            cards.removeValue(forKey: index)
            
            if cardsInserted.count > 0 {
                cardsInserted.removeLast()
            }
            visibleCardIndex = index-1
            delegate?.cardRemoved(count: cardsInserted.count)
            
            if cardsInserted.count == 0 {
                removeTitleView()
            }
            
            for j in cardsInserted {
                let i = visibleCardIndex!-j
                if (i <= 2) {
                    let card = cards[j]!
                    let cardView = card.view
                    if (cardView.isHidden) {
                        cardView.isHidden = false
                    }
                    
                    if card.type == .allFilesFolders {
                        let cardView = card.view
                        (cardView.subviews[0] as! ViewAllCardsView).isInteractionEnabled(true)
                        removeTitleView()
                    } else {
                        showCardTitle(type: .file)
                    }
                    
                    animateCardMovement(index: j)
                } else if (i > 2) {
                    cards[j]!.view.isHidden = true
                }
            }
        })
    }
    
    /// Returns the width and top margin given the index of the card relative to the other cards
    private func getWidthAndTopMargin(index: Int) -> (CGFloat, CGFloat) {
        guard self.visibleCardIndex != nil else { return (0, 0) }
        
        if (index == visibleCardIndex!) {
            return (0, 10)
        } else if (index == visibleCardIndex!-1) {
            return (inactiveCard1WidthDifference, inactiveCard1TopMargin)
        } else if (index == visibleCardIndex!-2) {
            return (inactiveCard2WidthDifference, inactiveCard2TopMargin)
        }
        
        return (0, 0)
    }
    
    private func removeTitleView() {
        if titleView != nil {
            titleView.removeFromSuperview()
        }
    }
}

fileprivate class ViewConstraints {
    var view: NSView
    var type: CardType
    var topConstraint, bottomConstraint, widthConstraint, heightConstraint, centerXConstraint: NSLayoutConstraint
    
    init(view: NSView, type: CardType, topConstraint: NSLayoutConstraint, bottomConstraint: NSLayoutConstraint, widthConstraint: NSLayoutConstraint, heightConstraint: NSLayoutConstraint, centerXConstraint: NSLayoutConstraint) {
        self.view = view
        self.type = type
        self.topConstraint = topConstraint
        self.bottomConstraint = bottomConstraint
        self.widthConstraint = widthConstraint
        self.heightConstraint = heightConstraint
        self.centerXConstraint = centerXConstraint
    }
}

enum CardType {
    case file
//    case folder
    case allFilesFolders
}

protocol CardCollectionViewDelegate {
    func cardRemoved(count: Int);
    func cardAdded(count: Int)
}
