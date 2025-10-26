import Foundation
import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TrackerCell"
    
    private let cardView = UIView()
    private let emojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let plusButton = UIButton(type: .system)
    private let countLabel = UILabel()
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var onToggle: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .clear

        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let emojiBackgroundView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor(named: "ypEmojiBackground")
            view.layer.cornerRadius = 12
            view.layer.masksToBounds = true
            return view
        }()
        
        emojiLabel.font = .systemFont(ofSize: 16)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.textAlignment = .center
        nameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),

            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
        
        NSLayoutConstraint.activate([
            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor)
        ])

        let quantityView = UIView()
        quantityView.backgroundColor = .white
        quantityView.layer.cornerRadius = 12
        quantityView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        quantityView.translatesAutoresizingMaskIntoConstraints = false

        countLabel.font = .systemFont(ofSize: 12, weight: .medium)
        countLabel.textColor = UIColor(named: "ypBlack")
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        plusButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.addTarget(self, action: #selector(didTapPlus), for: .touchUpInside)

        quantityView.addSubview(countLabel)
        quantityView.addSubview(plusButton)

        NSLayoutConstraint.activate([
            countLabel.centerYAnchor.constraint(equalTo: quantityView.centerYAnchor),
            countLabel.leadingAnchor.constraint(equalTo: quantityView.leadingAnchor, constant: 12),
            plusButton.centerYAnchor.constraint(equalTo: quantityView.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: quantityView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])

        contentView.addSubview(cardView)
        contentView.addSubview(quantityView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            quantityView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            quantityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            quantityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quantityView.heightAnchor.constraint(equalToConstant: 58),
            quantityView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    @objc private func didTapPlus() {
        onToggle?()
    }
    
    func configure(with tracker: Tracker, count: Int, isCompleted: Bool, isFuture: Bool = false) {
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        countLabel.text = "\(count) Дней"
        cardView.backgroundColor = tracker.color
        plusButton.tintColor = tracker.color
        

        let buttonImage = UIImage(systemName: isCompleted ? "checkmark.circle.fill" : "plus.circle.fill")
        plusButton.setImage(buttonImage, for: .normal)
        
        plusButton.isEnabled = !isFuture
            plusButton.alpha = isFuture ? 0.5 : 1.0
    }
}
