import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var pendingDate: FlutterResult?
  private weak var pickerAlert: UIAlertController?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(name: "hu.elizerpist.hajnal/date_picker", binaryMessenger: engineBridge.applicationRegistrar.messenger())
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "pick" else { result(FlutterMethodNotImplemented); return }
      guard let self = self, self.pendingDate == nil else { result(FlutterError(code: "busy", message: "Date picker is already open", details: nil)); return }
      guard let args = call.arguments as? [String: Int],
            let year = args["year"], let month = args["month"], let day = args["day"],
            let maxYear = args["maxYear"], let maxMonth = args["maxMonth"], let maxDay = args["maxDay"],
            let initial = Calendar.current.date(from: DateComponents(year: year, month: month, day: day)),
            let maximum = Calendar.current.date(from: DateComponents(year: maxYear, month: maxMonth, day: maxDay)),
            let root = self.window?.rootViewController else {
        result(FlutterError(code: "arguments", message: "Invalid date or unavailable window", details: nil)); return
      }
      self.pendingDate = result
      let datePicker = UIDatePicker()
      datePicker.datePickerMode = .date
      datePicker.preferredDatePickerStyle = .wheels
      datePicker.maximumDate = maximum
      datePicker.date = min(initial, maximum)
      let alert = UIAlertController(title: "Kezdődátum", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
      datePicker.translatesAutoresizingMaskIntoConstraints = false
      alert.view.addSubview(datePicker)
      NSLayoutConstraint.activate([
        datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
        datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 42),
        datePicker.widthAnchor.constraint(equalTo: alert.view.widthAnchor, constant: -16),
        datePicker.heightAnchor.constraint(equalToConstant: 180)
      ])
      alert.addAction(UIAlertAction(title: "Mégse", style: .cancel) { _ in self.finishDate(nil) })
      alert.addAction(UIAlertAction(title: "Kész", style: .default) { _ in
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: datePicker.date)
        self.finishDate(["year": parts.year!, "month": parts.month!, "day": parts.day!])
      })
      self.pickerAlert = alert
      root.present(alert, animated: true)
    }
  }

  private func finishDate(_ value: [String: Int]?) {
    let result = pendingDate
    pendingDate = nil
    pickerAlert = nil
    result?(value)
  }
}
