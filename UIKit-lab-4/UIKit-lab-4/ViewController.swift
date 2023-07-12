//
//  ViewController.swift
//  UIKit-lab-4
//
//  Created by Iliya Rahozin on 12.07.2023.
//

import UIKit

class TableCell: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    static func == (lhs: TableCell, rhs: TableCell) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    let title: String
    var isChecked: Bool
    
    init(title: String, isChecked: Bool = false) {
        self.title = title
        self.isChecked = isChecked
    }
}

class ViewController: UIViewController {
    
    enum Section: Hashable{
        case main
    }
    
    private var items: [TableCell] = []
    
    private lazy var dataSource: UITableViewDiffableDataSource<Section, TableCell> = {
        let dataSource = UITableViewDiffableDataSource<Section, TableCell>(tableView: tableView) { tableView, _, model in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
                return UITableViewCell()
            }
            cell.textLabel?.text = model.title
            if model.isChecked {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
        return dataSource
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "task 4"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "shuffle", style: .plain, target: self, action: #selector(shuffle))
        view.backgroundColor = .systemGray6
        
        view.addSubview(tableView)
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        createItems()
        configureSnapshot()
    }
    
    private func createItems() {
        for x in 1...40 {
            items.append(TableCell(title: String(x)))
        }
    }
    
    @objc private func shuffle() {
        items.shuffle()
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TableCell>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot)
    }

}


extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let model = dataSource.itemIdentifier(for: indexPath),
            let firstItem = dataSource.itemIdentifier(for: IndexPath(row: 0, section: 0))
        else {
            return
        }
        
        model.isChecked.toggle()
        var snapshot = dataSource.snapshot()
        var isAnimated = false
        
        snapshot.reloadItems([model])
        
        if model.isChecked, model != firstItem {
            snapshot.moveItem(model, beforeItem: firstItem)
            isAnimated = true
        }
        
        
        dataSource.apply(snapshot, animatingDifferences: isAnimated)
    }
}
