//  MIT License
//
//  Created on 08/12/2021 for ConnectStats
//
//  Copyright (c) 2021 Brice Rosenzweig
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//



import UIKit
import RZUtilsSwift



class GCSettingsLogTableViewController: UITableViewController {
    struct LogEntry {
        let time : String
        let pid : String
        let level : String
        let filename : String
        let line : String
        let method : String
        let message : String
        let raw : String
        
        var dateString : String { return "\(self.time) \(self.pid)"}
        var fileString : String { return "\(method) \(filename):\(line)"}
        var messageString : String { return self.message}
     
        var color : UIColor {
            return UIColor.systemFill;
        }
    }
    
    //
    
    func parseLog() -> [LogEntry] {
        var rv : [ LogEntry ] = []
        let pattern = "([0-9]+-[0-9]+-[0-9]+ [:.0-9]+) ([:0-9a-f]+) [-EW] (INFO|ERR |WARN):([A-Za-z0-9.+]+):([0-9]+):([^;]+); (.*)"

        if let log = RZLogFileContent(),
           
            let regexp = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive){
            log.enumerateLines {
                (line, _) in
                let lineRange = NSRange(location: 0, length: line.count)
                let matches = regexp.matches(in: line, options: [], range: lineRange)
                // no match next line
                guard let match = matches.first else { return }
                
                var groups : [String] = []
                
                for rangeIndex in 0..<match.numberOfRanges {
                    let matchRange = match.range(at: rangeIndex)
                    if let substringRange = Range(matchRange, in: line) {
                        let group = String(line[substringRange])
                        groups.append(group)
                    }
                }
                if( groups.count < 8){
                    groups = [ "", "", "", "", "", "", "", ""]
                }
                rv.append(LogEntry(time: groups[1], pid: groups[2], level: groups[3], filename: groups[4], line: groups[5], method: groups[6], message: groups[7], raw: line))
            }
        }
        return rv
        
    }
    
    var logEntries : [LogEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "GCLogEntryTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "GCLogEntryTableViewCell")

        self.logEntries = self.parseLog()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.scrollToRow(at: IndexPath(row: self.logEntries.count-1, section: 0), at: .bottom, animated: true)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.logEntries.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "GCLogEntryTableViewCell", for: indexPath) as? GCLogEntryTableViewCell else {
            return UITableViewCell()
        }
        
        let entry = self.logEntries[indexPath.row]
        cell.contentView.isUserInteractionEnabled = false
        cell.level.text = entry.level
        cell.timestamp.text = entry.dateString
        cell.method.text = entry.fileString
        cell.message.text = entry.messageString

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GCViewConfig.sizeForNumber(ofRows: 3)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
