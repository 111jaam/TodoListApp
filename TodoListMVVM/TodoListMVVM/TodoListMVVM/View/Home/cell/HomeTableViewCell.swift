//
//  HomeTableViewCell.swift
//  TodoListMVVM

import UIKit

protocol TodoItemCellDelegate: AnyObject {
    func didTapCompleteButton(inCell cell: HomeTableViewCell)
}

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var checkTaskButton: UIButton!
    @IBOutlet private weak var taskDescription: UILabel!
    @IBOutlet private weak var labelLeadingConstraint: NSLayoutConstraint!
    weak var delegate: TodoItemCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configCell(titleLeadingLevel: Int, title: String, buttonImage: UIImage) {
        let baseIndent: CGFloat = Constant.baseIndent
        labelLeadingConstraint.constant = baseIndent * CGFloat(titleLeadingLevel)
        taskDescription.text = title
        checkTaskButton.setImage(buttonImage, for: .normal)
    }
    
    func configCellWithData(data: CellData) {
        
        labelLeadingConstraint.constant = Constant.baseIndent * CGFloat(data.level)
        taskDescription.text = data.title
        checkTaskButton.setImage(UIImage(systemName: data.checkImage), for: .normal)
    }
    
    @IBAction func checkTaskTapped(_ sender: Any) {
        delegate?.didTapCompleteButton(inCell: self)
    }
}
