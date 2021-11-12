//
//  CrashReport.swift
//  Demo
//
//  Created by ming on 2021/5/28.
//

import UIKit
import MachO

private func registerSignalHandler() {
    // OC捕获异常
    // NSSetUncaughtExceptionHandler(uncaughtExceptionHandler(_:))
    
    // Swift捕获异常
    //    如果在运行时遇到意外情况，Swift代码将以SIGTRAP此异常类型终止，例如：
    //    1.具有nil值的非可选类型
    //    2.一个失败的强制类型转换
    //    查看Backtraces以确定遇到意外情况的位置。附加信息也可能已被记录到设备的控制台。您应该修改崩溃位置的代码，以正常处理运行时故障。例如，使用可选绑定而不是强制解开可选的。
    
    signal(SIGABRT, signalExceptionHandler)
    signal(SIGSEGV, signalExceptionHandler)
    signal(SIGBUS, signalExceptionHandler)
    signal(SIGTRAP, signalExceptionHandler)
    signal(SIGILL, signalExceptionHandler)
    
    //其他信号崩溃
    //    signal(SIGHUP, signalExceptionHandler)
    //    signal(SIGINT, signalExceptionHandler)
    //    signal(SIGQUIT, signalExceptionHandler)
    //    signal(SIGFPE, signalExceptionHandler)
    //    signal(SIGPIPE, signalExceptionHandler)
}

private func unregisterSignalHandler() {
    signal(SIGABRT, SIG_DFL)
    signal(SIGSEGV, SIG_DFL)
    signal(SIGBUS, SIG_DFL)
    signal(SIGTRAP, SIG_DFL)
    signal(SIGILL, SIG_DFL)
}

private func crashReportPath() -> String? {
    if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
        let reportPath = "\(path)/Crashs"
        if !FileManager.default.fileExists(atPath: reportPath) {
            FileManager.default.createFile(atPath: reportPath, contents: nil, attributes: nil)
        }
        return reportPath
    }
    return nil
}

private func getCrashReportPaths() -> [String] {
    guard let crashPath = crashReportPath() else {
        return []
    }
    do {
        var crashFilePaths: [String] = []
        let fileNames = try FileManager.default.contentsOfDirectory(atPath: crashPath)
        for fileName in fileNames {
            if fileName.hasSuffix(".log") {
                crashFilePaths.append(crashPath + "/" + fileName)
            }
        }
        return crashFilePaths
    } catch {
        kkxPrint("获取崩溃文件列表失败")
    }
    return []
}

private func getCrashReportContents() -> [String] {
    var contents: [String] = []
    let paths = getCrashReportPaths()
    for path in paths {
        if let content = try? String(contentsOfFile: path, encoding: .utf8) {
            contents.append(content)
        }
    }
    return contents
}

public func deleteCrashReport() {
    
}

private func uncaughtExceptionHandler(_ exception: NSException) {
    let name = exception.name.rawValue
    let reason = exception.reason ?? ""
    let callStackSymbols = exception.callStackSymbols.joined(separator: "\n")
    
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    let dateString = formatter.string(from: Date())
    var exception = deviceInfo(dateString)
    exception.append(name)
    exception.append(reason)
    exception.append(callStackSymbols)
    
    guard let crashPath = crashReportPath() else {
        return
    }
    let path = crashPath.appending("\(dateString).log")
    let exceptionString = exception.joined(separator: "\n")
    
    do {
        try exceptionString.write(toFile: path, atomically: true, encoding: .utf8)
    } catch {
        kkxPrint("保存到文件失败：\(path)")
    }
}

private func signalExceptionHandler(_ signal: Int32) -> Void {
    saveSwiftCrash()
    exit(signal)
}

private func saveSwiftCrash() {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    let dateString = formatter.string(from: Date())
    var exception = deviceInfo(dateString)
    
    let mstr = String(format: "slideAdress:0x%0x", slide)
    exception.append(mstr)
    exception.append(contentsOf: Thread.callStackSymbols)
    
    guard let crashPath = crashReportPath() else {
        return
    }
    let path = crashPath.appending("\(dateString)-Swift.log")
    let exceptionString = exception.joined(separator: "\n")
    
    do {
        try exceptionString.write(toFile: path, atomically: true, encoding: .utf8)
    } catch {
        kkxPrint("保存到文件失败：\(path)")
    }
}

/// 崩溃设备信息
private func deviceInfo(_ dateString: String) -> [String] {
    let bundle = Bundle.main
    return [
        dateString,
        bundle.displayName + " " + "\(bundle.version)(\(bundle.build))",
        bundle.bundleId,
        UIDevice.current.machineType,
        UIDevice.current.model,
        UIDevice.current.systemName + " " + UIDevice.current.systemVersion
    ]
}

/// 偏移量地址
private var slide: Int {
    var _slide = 0
    for i in 0..<_dyld_image_count() {
        if _dyld_get_image_header(i).pointee.filetype == MH_EXECUTE {
            _slide = _dyld_get_image_vmaddr_slide(i)
            break
        }
    }
    return _slide
}
