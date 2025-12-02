import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TrackerCell"
    
    // MARK: - UI Elements
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    internal var cardViewForPreview: UIView {
        return cardView
    }
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapPlus), for: .touchUpInside)
        
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.backgroundColor = .systemBlue
        
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let image = UIImage(systemName: "plus", withConfiguration: config)?
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        
        return button
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Callbacks
    
    var onToggle: (() -> Void)?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .clear
        
        setupCardView()
        setupQuantityView()
    }
    
    private func setupCardView() {
        contentView.addSubview(cardView)
        
        let emojiBackgroundView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor(resource: .ypEmojiBackground)
            view.layer.cornerRadius = 12
            view.layer.masksToBounds = true
            return view
        }()
        
        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupQuantityView() {
        let quantityView = UIView()
        quantityView.backgroundColor = UIColor(resource: .ypMainBackground)
        quantityView.layer.cornerRadius = 12
        quantityView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        quantityView.translatesAutoresizingMaskIntoConstraints = false
        
        quantityView.addSubview(countLabel)
        quantityView.addSubview(plusButton)
        contentView.addSubview(quantityView)
        
        NSLayoutConstraint.activate([
            quantityView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            quantityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            quantityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quantityView.heightAnchor.constraint(equalToConstant: 58),
            quantityView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            countLabel.centerYAnchor.constraint(equalTo: quantityView.centerYAnchor),
            countLabel.leadingAnchor.constraint(equalTo: quantityView.leadingAnchor, constant: 12),
            
            plusButton.centerYAnchor.constraint(equalTo: quantityView.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: quantityView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
            
        ])
    }
    
    // MARK: - Actions
    
    @objc private func didTapPlus() {
        onToggle?()
    }
    
    // MARK: - Configuration
    
    func configure(with tracker: Tracker, count: Int, isCompleted: Bool, isFuture: Bool = false) {
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        countLabel.text = "\(count) \(pluralizeDays(count))"
        
        cardView.backgroundColor = tracker.color
        plusButton.backgroundColor = tracker.color
        
        let symbolName = isCompleted ? "checkmark" : "plus"
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let image = UIImage(systemName: symbolName, withConfiguration: config)?
            .withRenderingMode(.alwaysTemplate)
        plusButton.setImage(image, for: .normal)
        plusButton.tintColor = .white
        
        plusButton.isEnabled = !isFuture
        plusButton.alpha = isFuture ? 0.5 : 1.0
    }
    
    private func pluralizeDays(_ count: Int) -> String {
        let remainder10 = count % 10
        
        if remainder10 == 1 {
            return NSLocalizedString("count.one.title", comment: "Один день")
        }
        
        if remainder10 >= 2 && remainder10 <= 4 {
            return NSLocalizedString("count.few.title", comment: "Два-четыре дня")
        }
        
        return NSLocalizedString("count.many.title", comment: "Много дней")
    }
}

