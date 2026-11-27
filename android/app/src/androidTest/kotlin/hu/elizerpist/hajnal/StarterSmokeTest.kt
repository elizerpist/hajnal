package hu.elizerpist.hajnal

import android.app.Activity
import android.content.Intent
import android.content.res.Configuration
import android.database.sqlite.SQLiteDatabase
import android.graphics.BitmapFactory
import android.graphics.Color
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
import java.time.format.DateTimeFormatter
import java.util.Locale

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
    private fun screenshotWelcomeWhenRendered() {
        val file = File(context.filesDir, "onboarding.png")
        val deadline = android.os.SystemClock.elapsedRealtime() + 15000
        while (android.os.SystemClock.elapsedRealtime() < deadline) {
            screenshot("onboarding")
            val image = BitmapFactory.decodeFile(file.path) ?: continue
            val sky = image.getPixel(image.width / 4, image.height / 8)
            val logo = image.getPixel(image.width * 200 / 412, image.height * 180 / 892)
            image.recycle()
            if (Color.red(sky) < 215 && Color.blue(sky) - Color.red(sky) > 20 &&
                Color.red(logo) < 80 && Color.blue(logo) < 150) return
        }
        fail("Welcome artwork and logo did not render before screenshot deadline")
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
    private fun menuOnboarding() { click("Menü"); click("Onboarding"); assertNotNull(find("Csak a mai nap.")) }
    private fun clickScrolling(label: String) {
        repeat(5) {
            val item = device.findObject(By.textContains(label)) ?: device.findObject(By.descContains(label))
            if (item != null && !item.visibleBounds.isEmpty) { item.click(); return }
            val width = device.displayWidth; val height = device.displayHeight
            device.swipe(width / 2, height * 4 / 5, width / 2, height / 3, 20)
            device.waitForIdle()
        }
        click(label)
    }
    private fun newCalendar(editing: Boolean) {
        if (editing) menuOnboarding()
        click(if (editing) "Beállítások áttekintése" else "Kezdjük el")
        click("Tovább"); click("Értem, tovább")
        assertNotNull(find("Válaszd ki a kezdőnapot"))
    }
    private fun finishOnboarding(editing: Boolean) {
        clickScrolling("Tovább")
        clickScrolling("Később írom meg")
        if (device.findObject(By.text("Tovább")) != null || device.findObject(By.desc("Tovább")) != null) {
            clickScrolling("Tovább")
            clickScrolling("Most kihagyom")
        }
        clickScrolling(if (editing) "Módosítások mentése" else "Mentés és indulás")
        assertNotNull(find("Tiszta napok"))
    }
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
        launch(); assertNotNull(find("Csak a mai nap.")); screenshotWelcomeWhenRendered()
        newCalendar(false); screenshot("picker-open"); clickScrolling("Ma")
        device.setOrientationLeft(); device.waitForIdle(); assertNotNull(find("Válaszd ki a kezdőnapot"))
        device.setOrientationNatural(); device.waitForIdle(); assertNotNull(find("Válaszd ki a kezdőnapot"))
        finishOnboarding(false)
        screenshot("dashboard-closed")
        val card = find("Napi összegzés"); assertNotNull(card)
        val bounds = card!!.visibleBounds
        assertTrue(device.swipe(bounds.centerX(), bounds.centerY(), bounds.centerX(), bounds.centerY() - 100, 20))
        Thread.sleep(500); screenshot("dashboard-open"); device.pressBack()
        newCalendar(true); click("Bezárás")
    }

    @Test fun verifyRelaunch() {
        launch(); assertNotNull(find("Tiszta napok")); assertNotNull(find("0"))
    }

    @Test fun nightPicker() {
        launch(); assertNotNull(find("Tiszta napok")); newCalendar(true)
        screenshot("picker-night"); click("Bezárás")
    }

    private fun calendarDensity(name: String) {
        launch(); assertNotNull(find("Tiszta napok")); newCalendar(true)
        val now = LocalDate.now(); val previous = now.minusDays(1)
        if (previous.month != now.month) clickScrolling("Előző hónap")
        val label = previous.format(DateTimeFormatter.ofPattern("yyyy. MMMM d.", Locale("hu", "HU")))
        clickScrolling(label)
        assertNotNull("Selected day is rendered", device.wait(Until.findObject(By.descContains(label).selected(true)), 10000))
        if (previous.month != now.month) clickScrolling("Következő hónap")
        screenshot(name); click("Bezárás")
    }

    @Test fun calendarDensity160() = calendarDensity("calendar-density160")
    @Test fun calendarDensity240() = calendarDensity("calendar-density240")

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

    private fun extraState(): String {
        val db = SQLiteDatabase.openDatabase(dbFile.path, null, SQLiteDatabase.OPEN_READONLY)
        return db.use { sql ->
            listOf(
                "SELECT motivation, modules, completed FROM onboarding_profiles WHERE id=1",
                "SELECT name, phone FROM sponsor_contacts WHERE id=1",
                "SELECT mode, credential_slot FROM lock_settings WHERE id=1"
            ).joinToString("|") { query ->
                sql.rawQuery(query, null).use { cursor ->
                    assertTrue(cursor.moveToFirst())
                    (0 until cursor.columnCount).joinToString(":") { cursor.getString(it) ?: "" }
                }
            }
        }
    }

    @Test fun prepareUpgrade() {
        launch(); newCalendar(false); screenshot("picker-before-upgrade")
        File(context.getExternalFilesDir(null), "picker-before-upgrade-theme.txt").writeText("Flutter inline calendar")
        clickScrolling("Ma"); finishOnboarding(false)
        SQLiteDatabase.openDatabase(dbFile.path, null, SQLiteDatabase.OPEN_READWRITE).use { db ->
            db.execSQL("UPDATE onboarding_profiles SET motivation=?, modules=? WHERE id=1", arrayOf("Upgrade teszt", 3))
            db.execSQL("INSERT OR REPLACE INTO sponsor_contacts (id,name,phone) VALUES (1,?,?)", arrayOf("Teszt szponzor", "+36123456"))
        }
        click("Menü"); click("Alkalmazászár"); click("Csak PIN")
        enterPin(); click("Tovább"); enterPin(); click("Tovább")
        assertNotNull(find("PIN módosítása")); device.pressBack(); assertNotNull(find("Tiszta napok"))
        installArtworkFixture(); state.writeText(period()); assertArtwork()
        File(context.filesDir, "upgrade-extra-before.txt").writeText(extraState())
    }

    @Test fun verifyUpgradeAndCorrect() {
        launch(); assertNotNull(find("Add meg a PIN-kódod")); enterPin(); click("Feloldás")
        assertNotNull(find("Tiszta napok")); assertEquals(state.readText(), period()); assertArtwork()
        assertEquals(File(context.filesDir, "upgrade-extra-before.txt").readText(), extraState())
        newCalendar(true); screenshot("picker-after-upgrade")
        File(context.getExternalFilesDir(null), "picker-after-upgrade-theme.txt").writeText("Flutter inline calendar")
        val year = LocalDate.now().year
        val yearButton = device.wait(Until.findObject(By.desc("$year.")), 10000)
            ?: device.wait(Until.findObject(By.text("$year.")), 10000)
        assertNotNull("Quick year selector", yearButton); yearButton!!.click()
        click("${year - 1}.")
        assertEquals(state.readText(), period())
        val chosen = LocalDate.of(year - 1, LocalDate.now().month, 15)
            .format(DateTimeFormatter.ofPattern("yyyy. MMMM d.", Locale("hu", "HU")))
        clickScrolling(chosen)
        finishOnboarding(true)
        val before = state.readText().split('|'); val after = period().split('|')
        assertEquals(before[0], after[0]); assertEquals(before[2], after[2]); assertNotEquals(before[1], after[1])
        val days = ChronoUnit.DAYS.between(LocalDate.parse(after[1]), LocalDate.now()).coerceAtLeast(0)
        assertNotNull(find(days.toString())); assertArtwork()
        assertEquals(File(context.filesDir, "upgrade-extra-before.txt").readText(), extraState())
        File(context.filesDir, "upgrade-after.txt").writeText(period())
    }

    @Test fun verifyCorrectedRelaunch() {
        launch(); assertNotNull(find("Add meg a PIN-kódod")); enterPin(); click("Feloldás")
        assertNotNull(find("Tiszta napok"))
        assertEquals(File(context.filesDir, "upgrade-after.txt").readText(), period()); assertArtwork()
        assertEquals(File(context.filesDir, "upgrade-extra-before.txt").readText(), extraState())
    }
}
