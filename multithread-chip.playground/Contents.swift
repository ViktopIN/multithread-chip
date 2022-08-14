import Foundation

class Storage {
    var storage = [Chip]()
    var isAvaliable = false
    var condition = NSCondition()
    private var count = 0
    
    var isEmpty: Bool {
        storage.isEmpty
    }
    
    func push(item: Chip) {
        condition.lock()
        isAvaliable = true
        storage.append(item)
        count += 1
        print("Чип \(count) в хранилище")
        condition.signal()
        print("Сигнал")
        condition.unlock()
    }
    
    func pop() -> Chip {
        condition.lock()
        while !isAvaliable {
            condition.wait()
            print("Ждет экземпляра")
        }
        isAvaliable = false
        condition.unlock()
        
        return storage.removeLast()
    }
}

class GeneratingThread: Thread {
    private let storage: Storage
    private var timer = Timer()
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    override func main() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(getChipCopy), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 20.0))
    }
    
    @objc func getChipCopy() {
        storage.push(item: Chip.make())
    }
}

class WorkingThread: Thread {
    private var storage: Storage
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    override func main() {
        repeat {
            storage.pop().sodering()
            print("Припайка микросхемы")
        } while storage.isEmpty || storage.isAvaliable
    }
}

var storage = Storage()
var generationThread = GeneratingThread(storage: storage)
var workingThread = WorkingThread(storage: storage)

generationThread.start()
workingThread.start()
sleep(20)
generationThread.cancel()
