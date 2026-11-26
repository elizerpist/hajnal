package hu.elizerpist.hajnal

import android.app.DatePickerDialog
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null
    private var picker: DatePickerDialog? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hu.elizerpist.hajnal/date_picker")
            .setMethodCallHandler { call, result ->
                if (call.method != "pick") { result.notImplemented(); return@setMethodCallHandler }
                if (pending != null) { result.error("busy", "Dátumválasztás folyamatban", null); return@setMethodCallHandler }
                val year = call.argument<Int>("year")
                val month = call.argument<Int>("month")
                val day = call.argument<Int>("day")
                val maxYear = call.argument<Int>("maxYear")
                val maxMonth = call.argument<Int>("maxMonth")
                val maxDay = call.argument<Int>("maxDay")
                if (year == null || month == null || day == null || maxYear == null || maxMonth == null || maxDay == null) {
                    result.error("arguments", "Hiányzó dátum", null); return@setMethodCallHandler
                }
                pending = result
                picker = DatePickerDialog(this, { _, y, m, d ->
                    finishPicker(mapOf("year" to y, "month" to m + 1, "day" to d))
                }, year, month - 1, day).also { dialog ->
                    val max = Calendar.getInstance().apply { set(maxYear, maxMonth - 1, maxDay, 23, 59, 59); set(Calendar.MILLISECOND, 999) }
                    val min = Calendar.getInstance().apply { clear(); set(1, Calendar.JANUARY, 1, 0, 0, 0) }
                    dialog.datePicker.minDate = min.timeInMillis
                    dialog.datePicker.maxDate = max.timeInMillis
                    dialog.setOnCancelListener { finishPicker(null) }
                    dialog.show()
                }
            }
    }

    private fun finishPicker(value: Map<String, Int>?) {
        val result = pending ?: return
        pending = null
        picker = null
        result.success(value)
    }

    override fun onDestroy() {
        picker?.dismiss()
        finishPicker(null)
        super.onDestroy()
    }
}
