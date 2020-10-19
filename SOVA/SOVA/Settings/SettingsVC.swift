//
//  Settings .swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import UIKit
import MessageUI

class SettingsVC: UIViewController{
    
    static func show(in parent: UIViewController){
        guard let vc = parent as? UINavigationController else {
            parent.present(SettingsVC(), animated: true)
            return
        }
        vc.pushViewController(SettingsVC(), animated: true)
    }
    
    private var model : [Assitant] {
        get{
            return DataManager.shared.assistantsId.compactMap{DataManager.shared.get(by: $0)}
        }
    }
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.doesRelativeDateFormatting = true
        return df
    }
    
    private var mailComposer = MFMailComposeViewController()
    
    private var selectedAssistant = IndexPath(){
        didSet{
            let oldCell = self.tableView.cellForRow(at: oldValue)
            oldCell?.accessoryType = .none
            let newCell = self.tableView.cellForRow(at: self.selectedAssistant)
            newCell?.accessoryType = .checkmark
        }
    }
    
    private var cellId = "SettingsCell"
    
    private var tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    
    //MARK: VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor =  UIColor(named: "Colors/mainbacground")
        
        self.title = "Настройки".localized
        self.navigationController?.navigationBar.isHidden = false
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
        
        let isDarkTheme = UserDefaults.standard.value(forKey: "DarkTheme") as? Bool ?? (UIScreen.main.traitCollection.userInterfaceStyle == .dark)
        if isDarkTheme{
            self.tableView.backgroundColor = UIColor(named: "Colors/settingsBackground")
        }
        
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @objc func changeTheme(){
        let isDarkTheme = UserDefaults.standard.value(forKey: "DarkTheme") as? Bool ?? (UIScreen.main.traitCollection.userInterfaceStyle == .dark)

        UserDefaults.standard.setValue(!isDarkTheme, forKey: "DarkTheme")
        UIApplication.shared.override(isDarkTheme ? .dark : .light)

    }
    
    func createLog(){
        let messageListId = DataManager.shared.currentAssistants.messageListId
        var text: String = ""
        for id in messageListId{
            guard let ms: MessageList = DataManager.shared.get(by: id) else { continue }
            text += self.dateFormatter.string(from: ms.date) + "\n"
            for message in ms.messages{
                text += message.sender.rawValue + ":" + message.title + "\n"
            }
        }
        self.write(text: text, to: "Logs")
    }
    
    func write(text: String, to fileNamed: String, folder: String = "SavedFiles") {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent(folder) else { return }
        do{
            try FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
            let file = writePath.appendingPathComponent(fileNamed + ".txt")
            try text.write(to: file, atomically: false, encoding: String.Encoding.utf8)
            self.sendEmail(fileURL: file)
        }catch{
            self.showSimpleAlert(title: "Не получается сохранть файл".localized)
        }
    }
    
    func sendEmail(fileURL: URL) {
        guard MFMailComposeViewController.canSendMail() else { self.showSimpleAlert(title: "Can send email".localized); return }
        self.mailComposer = MFMailComposeViewController()
        self.mailComposer.mailComposeDelegate = self
        self.mailComposer.setSubject("Logs")
        
        guard let fileData = try? Data(contentsOf: fileURL) else { self.showSimpleAlert(title: "Не получается выгрузить".localized); return }
        self.mailComposer.addAttachmentData(fileData, mimeType: ".txt", fileName: "Logs")
    
        self.present(mailComposer, animated: true, completion: nil)
        
    }
    
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.model.count + 1 : 6
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section != 1 ? "Аккаунт".localized : "Подключить еще".localized
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: self.cellId)
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "Colors/settingsCell")
        //Configure cell with bots
        guard indexPath.section == 1 else {
            guard indexPath.row < self.model.count  else {
                cell.textLabel?.text = "Подключить еще".localized
                cell.accessoryType = .disclosureIndicator
                return cell
            }
            if DataManager.shared.currentAssistants.id == self.model[indexPath.row].id{
                cell.accessoryType = .checkmark
                self.selectedAssistant = indexPath
            }
            cell.textLabel?.text = self.model[indexPath.row].name
            return cell
        }
        
        //Configure setings's cell
        cell.textLabel?.text = UserSettings.allCases[indexPath.row].rawValue.localized
        guard indexPath.row != 0 else {
            cell.accessoryType = .disclosureIndicator
            cell.accessibilityLabel = Language.userValue
        
            return cell
        }
        
        guard indexPath.row != 1 else {
            let switchView = UISwitch(frame: .zero)
            let isDarkTheme = UserDefaults.standard.value(forKey: "DarkTheme") as? Bool ?? (UIScreen.main.traitCollection.userInterfaceStyle == .dark)
            switchView.setOn(isDarkTheme, animated: true)
            switchView.tag = indexPath.row // for detect which row switch Changed
            switchView.addTarget(self, action: #selector(self.changeTheme), for: .valueChanged)
            cell.accessoryView = switchView
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            guard indexPath.row < self.model.count else { AssistantVC.show(with: nil, in: self.navigationController!); return }
            self.selectedAssistant = indexPath
            DataManager.shared.checkAnotherAssistant(self.model[indexPath.row].id)
        }else{
            switch UserSettings.allCases[indexPath.row] {
            case .cashe:
                let alert = UIAlertController(title: "Подтверждение удаления?".localized, message: "Вы уверены что хотите все удалить?", preferredStyle: .alert)
                let delete = UIAlertAction(title: "Удалить все", style: .destructive) { (_) in
                    DataManager.shared.deleteAll()
                }
                let cancel = UIAlertAction(title: "Неее, не надо", style: .cancel)
                alert.addAction(cancel)
                alert.addAction(delete)
                self.present(alert, animated: true, completion: nil)
            case .logs:
                self.createLog()
            case .support:
                let email = "support@sova.ai" 
                guard let url = URL(string: "mailto:\(email)") else { self.showSimpleAlert(title: "Упс, что-то пошло не так".localized); return}
                    UIApplication.shared.open(url)
            case .aboutApp:
                AboutVC.show(parent: self.navigationController!)
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section == 0 else { return false}
        return indexPath.row < self.model.count
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete".localized) { (_, _, _) in
            DataManager.shared.deleteAssistant(self.model[indexPath.row])
            self.tableView.reloadData()
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit".localized) { (_, _, _) in
            AssistantVC.show(with: self.model[indexPath.row], in: self.navigationController!)
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        
        return swipeAction
    }
}

extension SettingsVC: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.mailComposer.dismiss(animated: true, completion: nil)
    }
    
    
    
}


enum UserSettings: String, CaseIterable{
    case language = "Язык приложения"
    case theme = "Темная тема"
    case cashe = "Очистить историю и кеш"
    case logs = "Отправить логи"
    case support = "Техподдержка"
    case aboutApp = "О приложении"
    
    
}
