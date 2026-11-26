package hu.elizerpist.hajnal

import android.content.Intent
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.Until
import org.junit.Assert.*
import org.junit.Test
import org.junit.runner.RunWith
import java.io.File

@RunWith(AndroidJUnit4::class)
class StarterSmokeTest {
    private val device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
    private val context = InstrumentationRegistry.getInstrumentation().targetContext
    private fun launch() {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)!!
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
        context.startActivity(intent)
    }
    private fun find(label: String) = device.wait(Until.findObject(By.textContains(label)), 20000)
        ?: device.wait(Until.findObject(By.descContains(label)), 20000)
    private fun click(label: String) { val view = find(label); assertNotNull("Missing $label", view); view!!.click() }
    private fun screenshot(name: String) { assertTrue(device.takeScreenshot(File("/sdcard/Download/$name.png"))) }

    @Test fun nativePickerPersistenceAndNavigation() {
        launch()
        assertNotNull(find("Kezdődátum"))
        screenshot("onboarding")
        click("Dátum kiválasztása")
        assertNotNull(device.wait(Until.findObject(By.clazz("android.widget.DatePicker")), 10000))
        device.pressBack()
        click("Dátum kiválasztása")
        assertNotNull(device.wait(Until.findObject(By.clazz("android.widget.DatePicker")), 10000))
        click("OK")
        click("Mentés")
        assertNotNull(find("Tiszta napok"))
        screenshot("dashboard-closed")
        val card = find("Napi összegzés")
        assertNotNull(card)
        val bounds = card!!.visibleBounds
        assertTrue(device.swipe(bounds.centerX(), bounds.centerY(), bounds.centerX(), bounds.centerY() - 100, 20))
        Thread.sleep(500)
        screenshot("dashboard-open")
        device.pressBack()
        click("Menü")
        click("Onboarding")
        assertNotNull(find("nem módosítható"))
        device.pressBack()
    }

    @Test fun verifyRelaunch() {
        launch()
        assertNotNull(find("Tiszta napok"))
        assertNotNull(find("0"))
        assertNull(find("Dátum kiválasztása"))
    }
}
