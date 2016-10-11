/*
 we use the Background Transfer Service and URLSession API to start downloading a large files that continues to download
 when the app is in the background.
 
 
 A background transfer is initiated by configuring a background URLSession and enqueuing upload or download tasks. If tasks
 complete while the application is backgrounded, suspended, or terminated, iOS will notify the application by calling the 
 completion handler in the application's AppDelegate.
*/

import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate {
   
    let downloadUrl = "http://www.iso.org/iso/annual_report_2009.pdf"
    let sessionConfig = URLSessionConfiguration.background(withIdentifier: "com.apple.unique.background.id")
    
    var urlSession: URLSession {
        sessionConfig.isDiscretionary = true
        return URLSession(configuration: sessionConfig, delegate: self, delegateQueue: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: downloadUrl) {
            let task = urlSession.downloadTask(with: url)
            task.resume()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
            let path = dir?.appendingPathComponent("Sample.pdf")
            try FileManager.default.copyItem(at: location, to: path!)
            print("File Downloaded to: \(path!)")
        }
        catch let error {
            print(error)
        }
    }
    
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("calling completion handler")
        
          /* When the last task completes, a suspended or terminated application is re-launched into the background. Then, the
             application re-connects to the URLSession using the unique session identifier, and calls this method on the session 
             delegate. This method is the application's opportunity to handle new content, including updating the UI to reflect the 
             results of the transfer,
             
            Once we're done handling new content, we call the completion handler to let the system know it is safe to take a snapshot 
            of the application and go back to sleep.
          */
        
        let sessionIdentifier = urlSession.configuration.identifier
        if let sessionId = sessionIdentifier, let app = UIApplication.shared.delegate as? AppDelegate , let handler = app.completionHandlers.removeValue(forKey: sessionId) {
            handler()
        }
    }
}
