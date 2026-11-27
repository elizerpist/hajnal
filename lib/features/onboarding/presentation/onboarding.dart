import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/artwork/artwork_catalog.dart';
import '../../../core/brand/brand_assets.dart';
import '../../../core/theme/hajnal_tokens.dart';
import '../application/onboarding_controller.dart';
import '../application/onboarding_draft.dart';
import 'onboarding_calendar.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key, required this.controller});
  final OnboardingController controller;
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final motivation = TextEditingController();
  final sponsorName = TextEditingController();
  final sponsorPhone = TextEditingController();
  bool initialized = false;
  OnboardingController get flow => widget.controller;

  @override
  void initState() {
    super.initState();
    flow.load();
  }

  @override
  void dispose() {
    motivation.dispose();
    sponsorName.dispose();
    sponsorPhone.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final success = await flow.finish();
    if (success && mounted) Navigator.of(context).pop();
  }

  Future<void> close() async {
    final saved = await flow.flushDraft();
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('A piszkozat mentése nem sikerült.'),
          action: SnackBarAction(label: 'Újrapróbálás', onPressed: close),
        ),
      );
    }
  }

  void back() {
    if (!flow.back()) close();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: flow,
    builder: (context, _) {
      final draft = flow.draft;
      if (draft == null) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Bezárás',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
          body: Center(
            child: flow.error == null
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: flow.load,
                    child: const Text('Nem sikerült betölteni. Újrapróbálás'),
                  ),
          ),
        );
      }
      if (!initialized) {
        initialized = true;
        motivation.text = draft.motivation;
        sponsorName.text = draft.sponsorName;
        sponsorPhone.text = draft.sponsorPhone;
      }
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && !flow.saving) back();
        },
        child: Scaffold(
          backgroundColor: HajnalColors.sheet,
          body: flow.page == 0
              ? _welcomeFirst(draft)
              : SafeArea(
                  child: Column(
                    children: [
                      _header(),
                      Expanded(
                        child: SingleChildScrollView(
                          key: ValueKey('onboarding-page-${flow.page}'),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: AbsorbPointer(
                                absorbing: flow.saving,
                                child: _content(draft),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _actions(draft),
                    ],
                  ),
                ),
        ),
      );
    },
  );

  Widget _header() => Row(
    children: [
      IconButton(
        tooltip: 'Vissza',
        onPressed: flow.saving ? null : back,
        icon: const Icon(Icons.arrow_back_ios_new),
      ),
      Expanded(
        child: flow.page <= 2
            ? _dots(flow.page)
            : Center(
                child: Text(
                  '${flow.page - 2} / ${flow.draft!.modules.contains(OnboardingModule.sponsor) ? 4 : 3}',
                ),
              ),
      ),
      IconButton(
        tooltip: 'Bezárás',
        onPressed: flow.saving ? null : close,
        icon: const Icon(Icons.close),
      ),
    ],
  );

  Widget _dots(int active) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      3,
      (i) => Container(
        width: i == active ? 22 : 9,
        height: 9,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: i == active ? HajnalColors.purple : HajnalColors.pinUnderline,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  Widget _welcomeFirst(OnboardingDraft draft) => Stack(
    children: [
      Positioned.fill(
        child: SvgPicture.asset(
          welcomeArtwork,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      SafeArea(
        child: LayoutBuilder(
          builder: (context, size) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.maxHeight - 48),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        tooltip: 'Bezárás',
                        onPressed: close,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    SvgPicture.asset(BrandAssets.logo, width: 104, height: 104),
                    const SizedBox(height: 12),
                    const Text(
                      'Hajnal',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Csak a mai nap.',
                      style: TextStyle(
                        color: HajnalColors.brandAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 38),
                    const Text(
                      'Jó, hogy itt vagy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Lépésről lépésre, a saját tempódban.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: flow.next,
                        style: FilledButton.styleFrom(
                          backgroundColor: HajnalColors.card,
                          foregroundColor: HajnalColors.purple,
                          minimumSize: const Size(48, 56),
                        ),
                        child: Text(
                          draft.completed
                              ? 'Beállítások áttekintése'
                              : 'Kezdjük el',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Fiók nélkül. Offline.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _title(String title, [String? subtitle]) => Column(
    children: [
      Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w800,
          height: 1.18,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ],
      const SizedBox(height: 24),
    ],
  );

  Widget _button(String text, VoidCallback? onPressed) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: flow.saving ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: HajnalColors.purple,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
  );

  Widget _card(Widget child, {Color? color}) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color ?? HajnalColors.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: HajnalColors.border),
      boxShadow: const [
        BoxShadow(
          color: HajnalColors.cardShadow,
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );

  Widget _actions(OnboardingDraft draft) {
    final label = switch (flow.page) {
      2 => 'Értem, tovább',
      5 when !draft.modules.contains(OnboardingModule.sponsor) =>
        draft.completed ? 'Módosítások mentése' : 'Mentés és indulás',
      6 => draft.completed ? 'Módosítások mentése' : 'Mentés és indulás',
      _ => 'Tovább',
    };
    final finish =
        flow.page == 6 ||
        (flow.page == 5 && !draft.modules.contains(OnboardingModule.sponsor));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (flow.error != null && flow.page >= 5)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    flow.page == 6
                        ? 'A mentés nem sikerült. Ellenőrizd a nevet, majd próbáld újra.'
                        : 'A mentés nem sikerült. Próbáld újra.',
                    textAlign: TextAlign.center,
                  ),
                ),
              _button(label, finish ? save : flow.next),
              if (flow.page == 4)
                TextButton(
                  onPressed: flow.saving
                      ? null
                      : () {
                          flow.skipMotivation();
                          motivation.text = flow.draft!.motivation;
                          flow.next();
                        },
                  child: const Text('Később írom meg'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(OnboardingDraft draft) {
    switch (flow.page) {
      case 1:
        return Column(
          children: [
            _title('Üdv a Hajnalban!'),
            const SizedBox(height: 30),
            SvgPicture.asset(BrandAssets.logo, width: 190, height: 190),
            const SizedBox(height: 45),
            const Text(
              'Ez az alkalmazás segít, hogy minden nap egy kicsit közelebb kerülj a számodra fontos élethez.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, height: 1.4),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            _title('Fontos tudnivalók'),
            _notice(
              Icons.favorite,
              'A Hajnal támogat, de nem helyettesíti a szakmai segítséget.',
            ),
            _notice(
              Icons.shield,
              'Sürgős helyzetben kérj azonnali segítséget.',
            ),
            _notice(
              Icons.lock,
              'Az adataid a készülékeden maradnak. Alkalmazászárat is beállíthatsz.',
            ),
            const SizedBox(height: 20),
            const Text(
              'A saját tempódban haladhatsz.',
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            _title(
              'Mikor kezdődött a tiszta időszakod?',
              'Válaszd ki a kezdőnapot.',
            ),
            _card(
              OnboardingCalendar(
                date: draft.date,
                today: flow.today,
                onChanged: flow.setDate,
              ),
            ),
            _card(
              Column(
                children: [
                  Text(
                    'Ma a ${flow.cleanDayCount}. napnál tartasz.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Minden eltelt éjfél egy újabb nap.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              color: HajnalColors.selectedCard,
            ),
            const SizedBox(height: 8),
            const Text(
              'A kezdődátumot később is módosíthatod.',
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 4:
        return Column(
          children: [
            _title(
              'Miért kezdtem el?',
              'Adj magadnak egy mondatot a nehezebb pillanatokra.',
            ),
            _card(
              TextField(
                controller: motivation,
                onChanged: flow.setMotivation,
                minLines: 6,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Saját emlékeztetőm',
                  hintText: 'Miért fontos nekem a változás?',
                  border: InputBorder.none,
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ezt a Pánik módban is visszaolvashatod.',
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 5:
        return Column(
          children: [
            _title(
              'Mire használom a Hajnalt?',
              'Csak azt kapcsold be, amire szükséged van.',
            ),
            _card(
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.auto_awesome),
                title: Text(
                  'Mindig veled van',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Tiszta napok · Pánik mód\nIdővonal · Gyakorlatkártyák',
                ),
              ),
              color: HajnalColors.selectedCard,
            ),
            _module(
              draft,
              OnboardingModule.reflection,
              Icons.edit_outlined,
              'Napi reflexiók',
              'Hely a gondolataidnak',
            ),
            _module(
              draft,
              OnboardingModule.sponsor,
              Icons.people_outline,
              'Szponzor',
              'Kapcsolat és átbeszélendő témák',
            ),
            _module(
              draft,
              OnboardingModule.meetings,
              Icons.calendar_month,
              'Gyűlések',
              'Részvételek és megjegyzések',
            ),
            _module(
              draft,
              OnboardingModule.steps,
              Icons.layers_outlined,
              'Lépésmunka',
              'A saját tempódban',
            ),
          ],
        );
      default:
        return Column(
          children: [
            _title('Van szponzorod vagy segítő személyed?'),
            RadioGroup<int>(
              groupValue: draft.sponsorChoice,
              onChanged: (v) {
                if (v != null) flow.setSponsorChoice(v);
              },
              child: Column(
                children: [
                  _sponsorChoice(
                    0,
                    Icons.people,
                    (draft.baseline['sponsorName'] ?? '') == ''
                        ? 'Igen, hozzáadom'
                        : 'Igen, szerkesztem',
                  ),
                  _sponsorChoice(1, Icons.schedule, 'Később'),
                  _sponsorChoice(2, Icons.person_outline, 'Nincs még'),
                ],
              ),
            ),
            if (draft.sponsorChoice == 0)
              _card(
                Column(
                  children: [
                    TextField(
                      key: const Key('sponsor-name'),
                      controller: sponsorName,
                      onChanged: flow.setSponsorName,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Név',
                        hintText: 'Hogyan szólítod?',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: const Key('sponsor-phone'),
                      controller: sponsorPhone,
                      onChanged: flow.setSponsorPhone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefonszám',
                        hintText: '+36',
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'A kapcsolatot később is szerkesztheted.',
              textAlign: TextAlign.center,
            ),
          ],
        );
    }
  }

  Widget _notice(IconData icon, String text) => _card(
    Row(
      children: [
        CircleAvatar(
          backgroundColor: HajnalColors.purple,
          foregroundColor: Colors.white,
          child: Icon(icon),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  Widget _module(
    OnboardingDraft draft,
    OnboardingModule module,
    IconData icon,
    String title,
    String subtitle,
  ) => _card(
    CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: HajnalColors.purple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      value: draft.modules.contains(module),
      onChanged: (value) => flow.setModule(module, value ?? false),
    ),
  );

  Widget _sponsorChoice(int value, IconData icon, String label) => _card(
    RadioListTile<int>(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: HajnalColors.purple),
      title: Text(label),
      value: value,
    ),
  );
}
