import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/yansi_design_profile.dart';

class YansiDesignSelector extends StatefulWidget {
  final SharedPreferences prefs;
  final bool showPreviewAction;
  final ValueChanged<YansiDesignProfile>? onSelected;

  const YansiDesignSelector({
    super.key,
    required this.prefs,
    this.showPreviewAction = true,
    this.onSelected,
  });

  @override
  State<YansiDesignSelector> createState() => _YansiDesignSelectorState();
}

class _YansiDesignSelectorState extends State<YansiDesignSelector> {
  late YansiDesignId _selected;

  @override
  void initState() {
    super.initState();
    _selected = YansiDesignCatalog.current(widget.prefs).id;
  }

  Future<void> _select(YansiDesignId id) async {
    await YansiDesignCatalog.save(widget.prefs, id);
    if (!mounted) return;
    setState(() => _selected = id);
    widget.onSelected?.call(YansiDesignCatalog.byId(id.name));
  }

  @override
  Widget build(BuildContext context) {
    final profile = YansiDesignCatalog.byId(_selected.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose your visual world',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text(
          'Yansi stays the same intelligence. You choose how it looks and feels.',
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.48)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 122,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: YansiDesignCatalog.profiles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = YansiDesignCatalog.profiles[index];
              final selected = item.id == _selected;
              return GestureDetector(
                onTap: () => _select(item.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 118,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(selected ? .075 : .025),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF00E5FF).withOpacity(.62)
                          : Colors.white.withOpacity(.07),
                      width: selected ? 1.4 : .8,
                    ),
                    boxShadow: selected
                        ? [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(.10), blurRadius: 20)]
                        : const [],
                  ),
                  child: Column(
                    children: [
                      Expanded(child: _DesignPreview(profile: item, selected: selected)),
                      const SizedBox(height: 6),
                      Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Container(
            key: ValueKey(profile.id),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withOpacity(.025),
              border: Border.all(color: Colors.white.withOpacity(.06)),
            ),
            child: Row(
              children: [
                _LargeOrb(profile: profile),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(profile.description, style: TextStyle(fontSize: 10, height: 1.3, color: Colors.white.withOpacity(.48))),
                      const SizedBox(height: 7),
                      Text('5-core icon family • ${profile.motionStyle} motion', style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(.34))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.showPreviewAction) ...[
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => widget.onSelected?.call(profile),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text('USE ${profile.name.toUpperCase()}'),
          ),
        ],
      ],
    );
  }
}

class _DesignPreview extends StatelessWidget {
  final YansiDesignProfile profile;
  final bool selected;
  const _DesignPreview({required this.profile, required this.selected});

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [const Color(0xFF00E5FF).withOpacity(.26), Colors.transparent]),
              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(.30)),
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 20, color: Color(0xFFBFFFFF)),
          ),
          for (var i = 0; i < 5; i++)
            Transform.rotate(
              angle: i * 1.256,
              child: Transform.translate(
                offset: const Offset(0, -32),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E5FF).withOpacity(selected ? .75 : .45),
                  ),
                ),
              ),
            ),
        ],
      );
}

class _LargeOrb extends StatelessWidget {
  final YansiDesignProfile profile;
  const _LargeOrb({required this.profile});

  @override
  Widget build(BuildContext context) => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [const Color(0xFF7CFFFF).withOpacity(.28), Colors.transparent]),
          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(.35)),
          boxShadow: [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(.10), blurRadius: 18)],
        ),
        child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFBFFFFF), size: 22),
      );
}
