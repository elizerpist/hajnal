import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics_compat.dart'
    show RenderingStrategy;
import '../../../core/artwork/artwork_catalog.dart';
import '../../../core/brand/brand_assets.dart';
import '../../../core/theme/hajnal_theme.dart';
import '../../../core/theme/hajnal_components.dart';
import '../../../core/theme/domain/style_roles.dart';
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
          backgroundColor: HajnalStyle.of(context).color('background'),
          body: flow.page == 0
              ? _welcomeFirst(draft)
              : SafeArea(
                  child: Column(
                    children: [
                      _header(),
                      Expanded(
                        child: SingleChildScrollView(
                          key: ValueKey('onboarding-page-${flow.page}'),
                          padding: EdgeInsets.fromLTRB(
                            HajnalStyle.of(context).spacing('margin'),
                            0,
                            HajnalStyle.of(context).spacing('margin'),
                            24,
                          ),
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
        decoration: HajnalStyle.of(context).indicator(selected: i == active),
      ),
    ),
  );

  Widget _welcomeFirst(OnboardingDraft draft) => Stack(
    children: [
      Positioned.fill(
        child: SvgPicture.asset(
          welcomeArtwork,
          renderingStrategy: RenderingStrategy.raster,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      SafeArea(
        child: LayoutBuilder(
          builder: (context, size) => SingleChildScrollView(
            padding: EdgeInsets.all(HajnalStyle.of(context).spacing('margin')),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    (size.maxHeight -
                            2 * HajnalStyle.of(context).spacing('margin'))
                        .clamp(0, double.infinity),
              ),
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
                    Text(
                      'Hajnal',
                      style: HajnalStyle.of(context).text(TextRole.brand),
                    ),
                    Text(
                      'Csak a mai nap.',
                      style: HajnalStyle.of(
                        context,
                      ).text(TextRole.brandTagline),
                    ),
                    const Spacer(),
                    HajnalAction(
                      label: draft.completed
                          ? 'Beállítások áttekintése'
                          : 'Kezdjük el',
                      role: ButtonRole.secondary,
                      onPressed: flow.next,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Fiók nélkül. Offline.',
                      style: HajnalStyle.of(
                        context,
                      ).text(TextRole.artworkHelper),
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
      HajnalHeading(title: title, subtitle: subtitle),
      SizedBox(height: HajnalStyle.of(context).spacing('sectionGap')),
    ],
  );

  Widget _button(String text, VoidCallback? onPressed) =>
      HajnalAction(label: text, loading: flow.saving, onPressed: onPressed);

  Widget _card(Widget child, {bool selected = false}) => Padding(
    padding: EdgeInsets.only(
      bottom: HajnalStyle.of(context).spacing('cardGap'),
    ),
    child: HajnalCard(selected: selected, child: child),
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
      padding: EdgeInsets.fromLTRB(
        HajnalStyle.of(context).spacing('margin'),
        8,
        HajnalStyle.of(context).spacing('margin'),
        0,
      ),
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
            Text(
              'Ez az alkalmazás segít, hogy minden nap egy kicsit közelebb kerülj a számodra fontos élethez.',
              textAlign: TextAlign.center,
              style: HajnalStyle.of(context).text(TextRole.body),
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
            Column(
              children: [
                Text(
                  'Ma a ${flow.cleanDayCount}. napnál tartasz.',
                  style: HajnalStyle.of(context).text(TextRole.cardTitle),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Minden eltelt éjfél egy újabb nap.',
                  textAlign: TextAlign.center,
                ),
              ],
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
                style: HajnalStyle.of(context).text(TextRole.editor),
                textAlign: switch (HajnalStyle.of(
                  context,
                ).definitions.texts[TextRole.editor]!.align) {
                  'center' => TextAlign.center,
                  'right' => TextAlign.right,
                  'justify' => TextAlign.justify,
                  _ => TextAlign.left,
                },
                onChanged: flow.setMotivation,
                minLines: 6,
                maxLines: 10,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(
                    left: HajnalStyle.of(
                      context,
                    ).definitions.texts[TextRole.editor]!.indent,
                  ),
                  labelText: 'Saját emlékeztetőm',
                  hintText: 'Miért fontos nekem a változás?',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.auto_awesome),
                title: Text(
                  'Mindig veled van',
                  style: HajnalStyle.of(context).text(TextRole.cardTitle),
                ),
                subtitle: Text(
                  'Tiszta napok · Pánik mód\nIdővonal · Gyakorlatkártyák',
                ),
              ),
              selected: true,
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
            _title('Szeretnéd hozzáadni a szponzorodat?'),
            RadioGroup<SponsorChoice>(
              groupValue: draft.sponsorChoice,
              onChanged: (v) {
                if (v != null) flow.setSponsorChoice(v);
              },
              child: Column(
                children: [
                  _sponsorChoice(
                    SponsorChoice.add,
                    Icons.people,
                    (draft.baseline['sponsorName'] ?? '') == ''
                        ? 'Hozzáadom a szponzoromat'
                        : 'Szerkesztem a szponzorom adatait',
                  ),
                  _sponsorChoice(
                    SponsorChoice.skip,
                    Icons.schedule,
                    'Most kihagyom',
                  ),
                ],
              ),
            ),
            if (draft.sponsorChoice == SponsorChoice.add)
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
              'Szponzort később is hozzáadhatsz a Szponzor menüben.',
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
          backgroundColor: HajnalStyle.of(context).color('accent'),
          foregroundColor: HajnalStyle.of(context).color('onAccent'),
          child: Icon(icon),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(text, style: HajnalStyle.of(context).text(TextRole.body)),
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
  ) => Padding(
    padding: EdgeInsets.only(
      bottom: HajnalStyle.of(context).spacing('cardGap'),
    ),
    child: HajnalChoiceCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      multiple: true,
      selected: draft.modules.contains(module),
      onTap: () => flow.setModule(module, !draft.modules.contains(module)),
    ),
  );

  Widget _sponsorChoice(SponsorChoice value, IconData icon, String label) =>
      Padding(
        padding: EdgeInsets.only(
          bottom: HajnalStyle.of(context).spacing('cardGap'),
        ),
        child: HajnalChoiceCard(
          icon: icon,
          title: label,
          selected: flow.draft!.sponsorChoice == value,
          onTap: () => flow.setSponsorChoice(value),
        ),
      );
}
