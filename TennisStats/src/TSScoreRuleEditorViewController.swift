//  MIT License
//
//  Created on 29/01/2018 for tennisstats
//
//  Copyright (c) 2018 Brice Rosenzweig
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
import RZUtilsTouch

class TSScoreRuleEditorViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var numberOfSets: UISegmentedControl!
    @IBOutlet weak var gamesPerSet: UISegmentedControl!
    @IBOutlet weak var deciderIsTieBreak: UISegmentedControl!
    @IBOutlet weak var deciderHasTieBreak: UISegmentedControl!
    @IBOutlet weak var gameHasAdvantage: UISegmentedControl!
    
    @objc var scoreRule : TSTennisScoreRule?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateFromScore()  
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        updateToScore()
        super.viewWillDisappear(animated)
    }
    
    @IBAction func setAsDefault(_ sender: Any) {
        self.updateToScore()
        TSAppGlobal.setDefaultScoreRule(self.scoreRule)
    }
    
    func updateToScore() {
        scoreRule?.setsPerMatch = numberOfSets.selectedSegmentIndex == 1 ? 5 : 3
        scoreRule?.gamesPerSet = gamesPerSet.selectedSegmentIndex == 1 ? 6 : 4
        scoreRule?.decidingSetIsTieBreak = deciderIsTieBreak.selectedSegmentIndex == 0
        scoreRule?.decidingSetHasNoTieBreak = deciderHasTieBreak.selectedSegmentIndex == 0
        scoreRule?.gameEndWithSuddenDeath = gameHasAdvantage.selectedSegmentIndex == 0
    }
    
    func updateFromScore() {
        if let scoreRule = self.scoreRule {
            numberOfSets.selectedSegmentIndex = scoreRule.setsPerMatch == 5 ? 1 : 0
            gamesPerSet.selectedSegmentIndex = scoreRule.gamesPerSet == 6 ? 1 : 0
            deciderIsTieBreak.selectedSegmentIndex = scoreRule.decidingSetIsTieBreak ? 0 : 1
            if( scoreRule.decidingSetIsTieBreak){
                deciderHasTieBreak.isEnabled = false
            }else{
                deciderHasTieBreak.isEnabled = true
            }
            deciderHasTieBreak.selectedSegmentIndex = scoreRule.decidingSetHasNoTieBreak ? 0 : 1
            gameHasAdvantage.selectedSegmentIndex = scoreRule.gameEndWithSuddenDeath ? 0 : 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func numberOfSetsChanged(_ sender: UISegmentedControl) {
        print( "\(sender.selectedSegmentIndex)" )
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UITableDatasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TSTennisScoreRule.availableRuleNames().count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = GCCellGrid(cell: tableView)
        cell?.setup(forRows: 1, andCols: 1)
        cell?.label(forRow: 0, andCol: 0).text = TSTennisScoreRule.availableRuleNames()[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = TSTennisScoreRule.availableRuleNames()[indexPath.row]
        let rule = TSTennisScoreRule(forName: name)
        self.scoreRule!.unpack(rule!.pack())
        self.updateFromScore()
    }
    

}
