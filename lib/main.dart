import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFA64B28),
      surface: const Color(0xFFFFFBF5),
    ),
    scaffoldBackgroundColor: const Color(0xFFFFFBF5),
    appBarTheme: const AppBarThemeData(
      backgroundColor: Color(0xFFF8E7D3),
      foregroundColor: Color(0xFF57301E),
    ),
  ),
  home: const IcecreamApp(),
));

class IcecreamApp extends StatefulWidget {
  const IcecreamApp({super.key});
  @override
  State<IcecreamApp> createState() => _IcecreamAppState();
}

class _IcecreamAppState extends State<IcecreamApp> {
  final foods = {
    '🍳 たません': 350,
    '🐙 たこせん': 350,
    '🍳🐙 たまたこせん': 500,
  };
  late String food = foods.keys.first;
  String deco = 'なし';
  final fruits = <String>{};
  int decoCount = 1, order = 0;
  bool spoon = false, napkin = false;
  String receipt = '';

  Widget choices(Iterable<String> items, String value,
      void Function(String) change) => Wrap(spacing: 8, runSpacing: 6, children: [
    for (final s in items)
      ChoiceChip(label: Text(s), selected: value == s,
        onSelected: (_) => setState(() => change(s))),
  ]);

  @override
  Widget build(BuildContext context) {
    final subtotal = foods[food]! + fruits.length * 100
        + (deco == 'なし' ? 0 : decoCount * 50);
    // 商品・追加料金はすべて税込。内税は合計×8÷108の1円未満切り捨て。
    final total = subtotal;
    final tax = total * 8 ~/ 108;
    final photo = SizedBox(width: 190, height: 145, child: Stack(children: [
      Positioned(top: 0, left: 0, right: 0, child: Center(
        child: Text(deco == 'なし' ? '' : List.filled(decoCount, deco.split(' ').first).join(),
          style: const TextStyle(fontSize: 22)))),
      Center(child: FittedBox(fit: BoxFit.scaleDown,
        child: Text(food.split(' ').first,
          style: const TextStyle(fontSize: 90)))),
      Positioned(top: 35, right: 28, child: SizedBox(width: 78,
        child: Text(fruits.map((s) => s.split(' ').first).join(), textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 22)))),
    ]));
    final products = choices(foods.keys.map((s) => '$s  ${foods[s]}円'),
      '$food  ${foods[food]}円',
      (s) => food = s.substring(0, s.lastIndexOf('  ')));
    final toppings = Wrap(spacing: 8, runSpacing: 6, children: [
      for (final s in ['🧀 チーズ', '🥬 キャベツ', '🥓 ベーコン'])
        FilterChip(label: Text(s), selected: fruits.contains(s),
          onSelected: (v) => setState(() {
            if (v) { fruits.add(s); } else { fruits.remove(s); }
          })),
    ]);
    final decorations = Column(children: [
      choices(['なし', '🍘 追いせんべい', '🧅 ねぎ', '🌶 七味'], deco, (s) => deco = s),
      if (deco != 'なし') Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('追加の個数'),
          IconButton(onPressed: decoCount > 0
            ? () => setState(() => decoCount--) : null,
            icon: const Icon(Icons.remove)),
          Text('$decoCount', style: const TextStyle(fontSize: 22)),
          IconButton(onPressed: decoCount < 3
            ? () => setState(() => decoCount++) : null,
            icon: const Icon(Icons.add)),
        ]),
    ]);
    Widget supply(String label, bool value, void Function(bool) change) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Checkbox(value: value,
          onChanged: (v) => setState(() => change(v ?? false))),
        Text(label),
      ]);
    final supplies = Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        supply('🥢 箸（無料）', spoon, (v) => spoon = v),
        supply('🧻 紙ナプキン（無料）', napkin, (v) => napkin = v),
      ]);
    final bill = Column(children: [
      Text('税込合計 $total 円', style: const TextStyle(fontSize: 28)),
      Text('うち消費税（8%） $tax 円'),
      const Text('内税 = 税込合計 × 8 ÷ 108（1円未満切り捨て）',
        style: TextStyle(fontSize: 11)),
    ]);
    final submit = Center(child: FilledButton(onPressed: () => setState(() {
      order = Random().nextInt(999) + 1;
      receipt = '$food  ${foods[food]}円（税込）\n'
          '追加具材: ${fruits.isEmpty ? 'なし' : fruits.join(' ')}  ${fruits.length * 100}円\n'
          '追加トッピング: ${deco == 'なし' ? 'なし' : '$deco × $decoCount'}  ${deco == 'なし' ? 0 : decoCount * 50}円\n'
          '🥢 箸: ${spoon ? 'あり' : 'なし'}\n'
          '🧻 紙ナプキン: ${napkin ? 'あり' : 'なし'}\n'
          '税込合計: $total 円\n'
          '内税（8%）: $tax 円\n'
          '（内税は合計×8÷108・1円未満切り捨て）';
    }), child: const Text('注文する')));
    final ticket = order == 0 ? const SizedBox.shrink() : Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2),
        side: const BorderSide(color: Color(0xFFD8D0C4))),
      child: Padding(padding: const EdgeInsets.all(20), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('たません屋', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 3)),
          const Text('高専祭 / ご注文控え', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54)),
          const Divider(height: 24),
          Text('注文番号 #$order', textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          Text.rich(TextSpan(children: [
            for (final line in receipt.split('\n'))
              TextSpan(text: '$line\n',
                style: line.startsWith('税込合計:')
                  ? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold) : null),
          ]), style: const TextStyle(fontSize: 13, height: 1.7, color: Colors.black87)),
          const Divider(height: 20),
          const Text('ありがとうございました', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12)),
        ],
      )),
    );

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('🍳 たません屋 POS')),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('表示価格は税込・税率8%',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold)),
        Center(child: photo),
        const Text('商品を選ぶ', style: TextStyle(fontWeight: FontWeight.bold)), products,
        const SizedBox(height: 16),
        const Text('追加具材・トッピングは課題用の追加設定です。',
          style: TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        const Text('追加具材（1種類100円）'), toppings,
        const SizedBox(height: 16),
        const Text('追加トッピング（1個50円・0〜3個）'), decorations,
        const SizedBox(height: 16),
        const Text('無料サービス'), supplies,
        const Divider(height: 24),
        bill,
        const SizedBox(height: 8),
        submit, ticket,
      ]))),
    );
  }
}
