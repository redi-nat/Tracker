import UIKit

final class StatisticsViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    // MARK: - Properties
    
    private var completedCount: Int = 0 {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .noData))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completedStatView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеров завершено"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor(resource: .ypBackground)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if completedStatView.isHidden == false {
            if completedStatView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) == nil {
                 setupGradientBorder()
            }
        }
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)
        view.addSubview(completedStatView)
        
        setupCompletedStatView()
        setupConstraints()
    }
    
    private func setupCompletedStatView() {
        completedStatView.addSubview(countLabel)
        completedStatView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: completedStatView.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: completedStatView.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: completedStatView.trailingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: completedStatView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: completedStatView.trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: completedStatView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
            completedStatView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            completedStatView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            completedStatView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            completedStatView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    // MARK: - Logic
    
    private func loadStatistics() {
        completedCount = StatisticsService.shared.completedTrackersCount
    }
    
    private func updateUI() {
        let hasStats = completedCount > 0
        
        emptyStateImageView.isHidden = hasStats
        emptyStateLabel.isHidden = hasStats
        completedStatView.isHidden = !hasStats
        
        if hasStats {
            countLabel.text = "\(completedCount)"
        }
    }
    
    // MARK: - Gradient Border Setup

    private func setupGradientBorder() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = completedStatView.bounds
        
        let color1 = UIColor(red: 0.0, green: 0.47, blue: 1.0, alpha: 1.0).cgColor
        let color2 = UIColor(red: 0.0, green: 0.8, blue: 0.6, alpha: 1.0).cgColor
        let color3 = UIColor(red: 1.0, green: 0.4, blue: 0.3, alpha: 1.0).cgColor
        
        gradientLayer.colors = [color1, color2, color3]
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        gradientLayer.cornerRadius = 16
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: completedStatView.bounds, cornerRadius: 16).cgPath
        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = shapeLayer
        
        completedStatView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
