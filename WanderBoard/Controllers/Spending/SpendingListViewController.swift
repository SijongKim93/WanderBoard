//
//  ViewController.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 5/28/24.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

protocol SpendingListViewControllerDelegate: AnyObject {
    func didSaveExpense(_ expense: Expense)
    func didUpdateExpenses(_ expenses: [DailyExpenses])

}

extension SpendingListViewController: DetailInputViewControllerDelegate {
    func didSavePinLog(_ pinLog: PinLog) {
        self.pinLog = pinLog
        self.dailyExpenses = pinLog.expenses ?? []
        self.tableView.reloadData()
    }
}

class SpendingListViewController: UIViewController {
    
    weak var delegate: SpendingListViewControllerDelegate?

    var pinLog: PinLog?
    var dailyExpenses: [DailyExpenses] = []
    var hideEditButton: Bool = false
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    let categoryImageMapping: [String: String] = CategoryData.categoryImageMapping

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        configureUI()
        makeConstraints()
        updateView()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(SpendingTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SpendingTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: SpendingTableViewHeaderView.identifier)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNewExpenseData(_:)), name: .newExpenseData, object: nil)
        
        if let pinLog = pinLog {
            dailyExpenses = pinLog.expenses ?? []
            updateView()
        } else {
            print("No PinLog found.")
        }
        
        tableView.tableFooterView = UIView()
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0.0
        }
        
        if let navigationController = self.navigationController,
           let detailViewController = navigationController.viewControllers.first(where: { $0 is DetailViewController }) as? DetailViewController {
            self.delegate = detailViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        navigationController?.navigationBar.tintColor = .font
        
        if let pinLog = pinLog {
            self.dailyExpenses = pinLog.expenses ?? []
            self.tableView.reloadData()
        } else {
            print("No PinLog found.")
        }
    }
    
    func saveExpense(_ expense: Expense) {
        delegate?.didSaveExpense(expense)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            delegate?.didUpdateExpenses(dailyExpenses)
        }
    }
    
    func isCurrentUser() -> Bool {
        guard let pinLog = pinLog, let currentUserID = Auth.auth().currentUser?.uid else {
            return false
        }
        return pinLog.authorId == currentUserID
    }
    
    func loadExpensesFromFirestore(for pinLog: PinLog) async {
        do {
            let expenses = try await FirestoreManager.shared.fetchExpenses(for: pinLog.id ?? "")
            self.dailyExpenses = expenses
            self.tableView.reloadData()
        } catch {
            print("Failed to fetch expenses: \(error)")
        }
    }
    
    private func updateView() {
        if dailyExpenses.isEmpty {
            tableView.isHidden = true
            navigationItem.rightBarButtonItem?.isHidden = true
        } else {
            tableView.isHidden = false
            navigationItem.rightBarButtonItem?.isHidden = false
        }
        tableView.reloadData()
    }
    
    @objc func didReceiveNewExpenseData(_ notification: Notification) {
        guard let expense = notification.userInfo?["expense"] as? Expense else { return }

        if let index = dailyExpenses.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: expense.date) }) {
            dailyExpenses[index].expenses.append(expense)
        } else {
            let newDailyExpense = DailyExpenses(date: expense.date, expenses: [expense])
            dailyExpenses.append(newDailyExpense)
        }
        sortDailyExpensesByDate()
        tableView.reloadData()
        updateTotalSpendingAmount()
        updateView()
    }
    
    func mergeExpenses(currentExpenses: [DailyExpenses], newExpenses: [DailyExpenses]) -> [DailyExpenses] {
        var mergedExpenses = currentExpenses
        
        for newExpense in newExpenses {
            if let index = mergedExpenses.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: newExpense.date) }) {
                mergedExpenses[index].expenses.append(contentsOf: newExpense.expenses)
            } else {
                mergedExpenses.append(newExpense)
            }
        }
        
        return mergedExpenses
    }
    
    func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
    
    func sortDailyExpensesByDate() {
        dailyExpenses.sort { $0.date > $1.date }
    }
    
    func configureUI() {
        self.view.addSubview(tableView)
    }
    
    func makeConstraints() {
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(0)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
    }
    
    func updateHeaderView(forSection section: Int, withDeletedExpense deletedExpense: Expense) {
        guard section < dailyExpenses.count else { return }
        var dailyTotalAmount: Int = 0
        
        for expense in dailyExpenses[section].expenses {
            dailyTotalAmount += expense.expenseAmount
        }
        
        if let headerView = tableView.headerView(forSection: section) as? SpendingTableViewHeaderView {
            headerView.configure(with: dailyExpenses[section].date, dailyTotalAmount: dailyTotalAmount)
        }
        updateTotalSpendingAmount()
    }

    func updateTotalSpendingAmount() {
        var totalAmount: Int = 0
        
        for dailyExpense in dailyExpenses {
            for expense in dailyExpense.expenses {
                totalAmount += expense.expenseAmount
            }
        }
    }
    
    func totalExpensesAmount() -> Int {
        return dailyExpenses.flatMap { $0.expenses }.reduce(0) { $0 + $1.expenseAmount }
    }
}

// MARK: TableViewDataSource
extension SpendingListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dailyExpenses.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyExpenses[section].expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SpendingTableViewCell else {
            return UITableViewCell()
        }

        cell.separatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)

        let expense = dailyExpenses[indexPath.section].expenses[indexPath.row]
        cell.configure(with: expense)
        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedExpense = dailyExpenses[indexPath.section].expenses.remove(at: indexPath.row)
                        
            guard let pinLog = pinLog else { return }
            
            Task {
                do {
                    try await FirestoreManager.shared.deleteExpense(pinLogId: pinLog.id ?? "", expense: deletedExpense)
                    
                    await loadExpensesFromFirestore(for: pinLog)

                    if self.dailyExpenses[indexPath.section].expenses.isEmpty {
                        self.dailyExpenses.remove(at: indexPath.section)
                        tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                    } else {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }

                    self.updateHeaderView(forSection: indexPath.section, withDeletedExpense: deletedExpense)
                    delegate?.didUpdateExpenses(dailyExpenses)
                } catch {
                    print("Error removing document: \(error)")
                }
            }
        }
    }
}

// MARK: TableViewDelegate
extension SpendingListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isCurrentUser()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SpendingTableViewHeaderView.identifier) as? SpendingTableViewHeaderView else {
            return nil
        }
        
        var dailyTotalAmount: Int = 0
        
        for i in dailyExpenses[section].expenses {
            dailyTotalAmount += i.expenseAmount
        }
        
        header.configure(with: dailyExpenses[section].date, dailyTotalAmount: dailyTotalAmount)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard isCurrentUser() else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            let deletedExpense = self.dailyExpenses[indexPath.section].expenses.remove(at: indexPath.row)
                        
            guard let pinLogId = self.pinLog?.id else { return }
            
            Task {
                do {
                    try await FirestoreManager.shared.deleteExpense(pinLogId: pinLogId, expense: deletedExpense)
                    
                    if self.dailyExpenses[indexPath.section].expenses.isEmpty {
                        self.dailyExpenses.remove(at: indexPath.section)
                        tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                    } else {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                    
                    self.updateHeaderView(forSection: indexPath.section, withDeletedExpense: deletedExpense)
                    completionHandler(true)
                } catch {
                    print("Error removing document: \(error)")
                    completionHandler(false)
                }
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension SpendingListViewController: SummaryViewControllerDelegate {
    func didSaveExpense(_ expense: Expense) {
        if let index = dailyExpenses.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: expense.date) }) {
            dailyExpenses[index].expenses.append(expense)
        } else {
            let newDailyExpense = DailyExpenses(date: expense.date, expenses: [expense])
            dailyExpenses.append(newDailyExpense)
        }
        
        sortDailyExpensesByDate()
        tableView.reloadData()
        updateTotalSpendingAmount()
        updateView()
        delegate?.didUpdateExpenses(dailyExpenses)
    }
}
