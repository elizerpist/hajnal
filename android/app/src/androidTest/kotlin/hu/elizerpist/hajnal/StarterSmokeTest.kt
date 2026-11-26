package hu.elizerpist.hajnal

import android.app.Activity
import android.content.Intent
import android.content.res.Configuration
import android.database.sqlite.SQLiteDatabase
import android.util.TypedValue
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.runner.lifecycle.ActivityLifecycleMonitorRegistry
import androidx.test.runner.lifecycle.Stage
import androidx.test.uiautomator.By
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.Until
import org.junit.Assert.*
import org.junit.Test
import org.junit.runner.RunWith
import java.io.File
import java.time.LocalDate
import java.time.temporal.ChronoUnit

@RunWith(AndroidJUnit4::class)
class StarterSmokeTest {
    private val device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
    private val instrumentation = InstrumentationRegistry.getInstrumentation()
    private val context = instrumentation.targetContext
    private val state = File(context.filesDir, "upgrade-before.txt")
    private val dbFile get() = File(context.filesDir, "hajnal.sqlite")
    private fun launch() {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)!!
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
        context.startActivity(intent)
    }
    private fun find(label: String): androidx.test.uiautomator.UiObject2? {
        val deadline = android.os.SystemClock.elapsedRealtime() + 20000
        while (android.os.SystemClock.elapsedRealtime() < deadline) {
            val item = device.findObject(By.textContains(label)) ?: device.findObject(By.descContains(label))
            if (item != null) return item
            Thread.sleep(200)
        }
        return null
    }
    private fun resumeApp() {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)!!
        context.startActivity(intent)
    }
    private fun click(label: String) { val view = find(label); assertNotNull("Missing $label", view); view!!.click() }
    private fun screenshot(name: String) {
        val file = File(context.filesDir, "$name.png")
        assertTrue(device.takeScreenshot(file))
        if (name.contains("upgrade")) file.copyTo(File(context.getExternalFilesDir(null), "$name.png"), overwrite = true)
    }
    private fun openPicker(name: String) {
        click("Dátum kiválasztása")
        assertNotNull(device.wait(Until.findObject(By.clazz("android.widget.DatePicker")), 10000))
        screenshot(name)
        instrumentation.runOnMainSync {
            val activity: Activity = ActivityLifecycleMonitorRegistry.getInstance().getActivitiesInStage(Stage.RESUMED).first()
            val value = TypedValue()
            assertTrue(activity.theme.resolveAttribute(android.R.attr.datePickerDialogTheme, value, true))
            val theme = if (value.resourceId != 0) activity.resources.getResourceName(value.resourceId) else value.toString()
            File(context.filesDir, "$name-theme.txt").writeText(theme)
            if (name.contains("upgrade")) File(context.getExternalFilesDir(null), "$name-theme.txt").writeText(theme)
            if (name != "picker-before-upgrade") {
                assertTrue("Framework Material dialog theme: $theme", theme.contains("Material", ignoreCase = true))
            }
            if (name == "picker-night") {
                assertEquals(Configuration.UI_MODE_NIGHT_YES, activity.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK)
            }
        }
    }
    private fun period(): String {
        val db = SQLiteDatabase.openDatabase(dbFile.path, null, SQLiteDatabase.OPEN_READONLY)
        return db.use { sql ->
            sql.rawQuery("SELECT id, start_local_date, created_at_utc FROM recovery_periods WHERE closed_at_utc IS NULL", null).use { cursor ->
                assertTrue(cursor.moveToFirst())
                val result = "${cursor.getLong(0)}|${cursor.getString(1)}|${cursor.getLong(2)}"
                assertFalse(cursor.moveToNext())
                result
            }
        }
    }
    private fun menuOnboarding() { click("Menü"); click("Onboarding"); assertNotNull(find("Kezdődátum")) }
    private fun installArtworkFixture() {
        val directory = File(context.filesDir, "artwork").apply { mkdirs() }
        val file = File(directory, "artwork-upgrade-fixture.img")
        context.assets.open("flutter_assets/assets/artwork/dashboard/placeholder.png").use { input -> file.outputStream().use { input.copyTo(it) } }
        SQLiteDatabase.openDatabase(dbFile.path, null, SQLiteDatabase.OPEN_READWRITE).use { db ->
            db.execSQL("INSERT OR REPLACE INTO artwork_overrides(role, filename, revision) VALUES (?, ?, ?)", arrayOf("dashboard.default", file.name, "upgrade-fixture"))
        }
        assertTrue(file.length() > 0)
    }
    private fun assertArtwork() {
        val file = File(context.filesDir, "artwork/artwork-upgrade-fixture.img")
        assertTrue(file.length() > 0)
        SQLiteDatabase.openDatabase(dbFile.path, null, SQLiteDatabase.OPEN_READONLY).use { db ->
            db.rawQuery("SELECT filename, revision FROM artwork_overrides WHERE role = 'dashboard.default'", null).use { cursor ->
                assertTrue(cursor.moveToFirst())
                assertEquals(file.name, cursor.getString(0))
                assertEquals("upgrade-fixture", cursor.getString(1))
            }
        }
    }

    @Test fun nativePickerPersistenceAndNavigation() {
        launch()
        assertNotNull(find("Kezdődátum"))
        screenshot("onboarding")
        openPicker("picker-open")
        device.setOrientationLeft(); device.waitForIdle(); device.pressBack()
        device.setOrientationNatural(); device.waitForIdle()
        openPicker("picker-selected")
        click("OK"); click("Mentés")
        assertNotNull(find("Tiszta napok")); screenshot("dashboard-closed")
        val card = find("Napi összegzés"); assertNotNull(card)
        val bounds = card!!.visibleBounds
        assertTrue(device.swipe(bounds.centerX(), bounds.centerY(), bounds.centerX(), bounds.centerY() - 100, 20))
        Thread.sleep(500); screenshot("dashboard-open"); device.pressBack()
        menuOnboarding(); assertNotNull(find("Dátum kiválasztása")); device.pressBack()
    }

    @Test fun verifyRelaunch() {
        launch(); assertNotNull(find("Tiszta napok")); assertNotNull(find("0"))
    }

    @Test fun nightPicker() {
        launch(); assertNotNull(find("Tiszta napok")); menuOnboarding()
        openPicker("picker-night"); device.pressBack(); device.pressBack()
    }

    private fun digit(value: String) {
        val key = device.wait(Until.findObject(By.desc(value)), 5000)
            ?: device.wait(Until.findObject(By.text(value)), 5000)
        assertNotNull("Missing PIN digit", key); key!!.click()
    }
    private fun enterPin() { for (value in listOf("1", "2", "3", "4", "5", "6")) digit(value) }

    @Test fun appLockPinAndBackground() {
        launch(); assertNotNull(find("Tiszta napok"))
        click("Menü"); click("Alkalmazászár"); click("Csak PIN")
        enterPin(); device.waitForIdle(); Thread.sleep(500); screenshot("lock-real-setup"); click("Tovább")
        assertNotNull(find("Ismételd")); enterPin(); click("Tovább")
        assertNotNull(find("PIN módosítása"))
        device.pressHome(); Thread.sleep(1000); resumeApp()
        assertNotNull(find("Add meg a PIN-kódod")); enterPin(); click("Feloldás")
        assertNotNull(find("PIN módosítása"))
        click("Kikapcsolva"); assertNotNull(find("Azonosítás")); enterPin(); click("Feloldás")
        assertNotNull(find("Zárolás minden visszatéréskor"))
    }

    @Test fun launcherIcon() {
        device.pressHome(); device.waitForIdle()
        val size = device.displayWidth to device.displayHeight
        device.swipe(size.first / 2, size.second * 9 / 10, size.first / 2, size.second / 4, 20)
        device.waitForIdle()
        val icon = device.wait(Until.findObject(By.descContains("Hajnal")), 10000)
            ?: device.wait(Until.findObject(By.textContains("Hajnal")), 10000)
        assertNotNull("Installed Hajnal launcher icon", icon)
        screenshot("lock-launcher")
    }

    @Test fun prepareUpgrade() {
        launch(); assertNotNull(find("Kezdődátum")); openPicker("picker-before-upgrade")
        click("OK"); click("Mentés"); assertNotNull(find("Tiszta napok"))
        installArtworkFixture(); state.writeText(period()); assertArtwork()
    }

    @Test fun verifyUpgradeAndCorrect() {
        launch(); assertNotNull(find("Tiszta napok")); assertEquals(state.readText(), period()); assertArtwork()
        menuOnboarding(); openPicker("picker-after-upgrade")
        val year = LocalDate.now().year
        val yearHeader = device.wait(Until.findObject(By.res("android:id/date_picker_header_year")), 10000)
        assertNotNull("Calendar year selector", yearHeader); yearHeader!!.click()
        val previousYear = device.wait(Until.findObject(By.text((year - 1).toString())), 10000)
        assertNotNull("Previous year", previousYear); previousYear!!.click()
        click("OK"); click("Mentés"); assertNotNull(find("Tiszta napok"))
        val before = state.readText().split('|'); val after = period().split('|')
        assertEquals(before[0], after[0]); assertEquals(before[2], after[2]); assertNotEquals(before[1], after[1])
        val days = ChronoUnit.DAYS.between(LocalDate.parse(after[1]), LocalDate.now()).coerceAtLeast(0)
        assertNotNull(find(days.toString())); assertArtwork()
        File(context.filesDir, "upgrade-after.txt").writeText(period())
    }

    @Test fun verifyCorrectedRelaunch() {
        launch(); assertNotNull(find("Tiszta napok"))
        assertEquals(File(context.filesDir, "upgrade-after.txt").readText(), period()); assertArtwork()
    }
}
