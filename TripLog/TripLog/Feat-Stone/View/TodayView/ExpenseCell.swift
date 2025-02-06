import UIKit
import SnapKit
import Then

class ExpenseCell: UITableViewCell {
    static let identifier = "ExpenseCell"

    private let containerView = UIView().then {
        $0.layer.masksToBounds = false
        $0.applyBoxStyle()
    }

    private let dateLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .caption, weight: .regular)
    }

    private let titleLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
    }

    private let categoryLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .caption, weight: .regular)
        $0.textColor = UIColor(named: "textPlaceholder")
    }

    private let amountLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .display, weight: .medium)
        $0.textAlignment = .right
    }

    private let exchangeRateLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .body, weight: .bold)
        $0.textColor = UIColor.Personal.normal
        $0.textAlignment = .right
    }

    private let firstRowStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }

    private let secondRowStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }

    // 삭제 버튼을 감싸는 UIView
    private let deleteButtonView = UIView().then {
        $0.backgroundColor = .red
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }

    private let deleteButton = UIButton().then {
        $0.setTitle("삭제", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.backgroundColor = .clear
    }

    var onDeleteTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.isUserInteractionEnabled = true // ✅ 터치 이벤트가 정상 전달되도록 설정
        selectionStyle = .none

        contentView.addSubview(deleteButtonView)
        deleteButtonView.addSubview(deleteButton)
        contentView.addSubview(containerView)

        [dateLabel, titleLabel, categoryLabel, amountLabel, exchangeRateLabel].forEach {
            containerView.addSubview($0)
        }

        [titleLabel, amountLabel].forEach {
            firstRowStackView.addArrangedSubview($0)
        }
        containerView.addSubview(firstRowStackView)

        [categoryLabel, exchangeRateLabel].forEach {
            secondRowStackView.addArrangedSubview($0)
        }
        containerView.addSubview(secondRowStackView)

        setupLayout()
        applyBackgroundColor()

        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }


    private func setupLayout() {
        deleteButtonView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(80) // 기본적으로 숨겨진 상태
            $0.centerY.equalToSuperview()
            $0.width.equalTo(80)
            $0.height.equalToSuperview().inset(8)
        }

        deleteButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }

        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(16)
        }

        firstRowStackView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        secondRowStackView.snp.makeConstraints {
            $0.top.equalTo(firstRowStackView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(date: String, title: String, category: String, amount: String, exchangeRate: String) {
        dateLabel.text = date
        titleLabel.text = title
        categoryLabel.text = category
        amountLabel.text = amount
        exchangeRateLabel.text = exchangeRate
    }

    // 삭제 버튼 표시
    func showDeleteButton(animated: Bool = true) {
        deleteButtonView.snp.updateConstraints {
            $0.trailing.equalToSuperview()
        }
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }

    // 삭제 버튼 숨기기
    func hideDeleteButton(animated: Bool = true) {
        deleteButtonView.snp.updateConstraints {
            $0.trailing.equalToSuperview().offset(80)
        }
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }

    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }
}
