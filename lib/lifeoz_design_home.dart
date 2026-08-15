import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lifeoz_core_hub.dart';

class LifeOZDesignHome extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZDesignHome({super.key, required this.prefs});
  @override State<LifeOZDesignHome> createState() => _LifeOZDesignHomeState();
}

class _LifeOZDesignHomeState extends State<LifeOZDesignHome> with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late final AnimationController _motion;
  int _design = 0;
  int? _activeCore;
  bool _yansiActive = false;

  static const realities = [
    ('01_Oreon_Prime.png', 'OREON PRIME'), ('02_Terra_Flux.png', 'TERRA FLUX'),
    ('03_Vortex_Nexus.png', 'VORTEX NEXUS'), ('04_Crysta_Lumen.png', 'CRYSTA LUMEN'),
    ('09_Nebula_Soul-1.png', 'NEBULA SOUL'), ('10_Shadow_Core-1.png', 'SHADOW CORE'),
  ];
  static const coreNames = ['Financial Intelligence','Goals & Growth','Productivity','Household Management','Personal Life & Wellness'];
  static const coreIntro = [
    'This is Financial Intelligence. I organise your expenses, spending patterns, budgets and money insights.',
    'This is Goals and Growth. I help you define goals, track progress and keep you moving toward completion.',
    'This is Productivity. I organise your work and daily tasks, carry pending work forward and help you finish it.',
    'This is Household Management. I help organise shopping, home requirements and recurring household needs.',
    'This is Personal Life and Wellness. I help organise personal records, diary information and life routines.',
  ];

  @override void initState() {
    super.initState();
    _design = (widget.prefs.getInt('lifeos_visual_design') ?? 0).clamp(0, 5);
    _tts.setSpeechRate(.44);
    _motion = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  @override void dispose() { _motion.dispose(); _tts.stop(); SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); super.dispose(); }

  Future<void> _speak(String text) async { await _tts.stop(); await _tts.speak(text); }

  Future<void> _yansi() async {
    setState(() { _yansiActive = true; _activeCore = null; });
    await _speak('Hello. I am Yansi, your LifeOS intelligence. Tap any core and I will explain what it does. You can speak naturally to me and I will help organise your life.');
    if (mounted) setState(() => _yansiActive = false);
  }

  Future<void> _core(int index) async {
    setState(() { _activeCore = index; _yansiActive = false; });
    await _speak(coreIntro[index]);
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => LifeOZCoreHub(prefs: widget.prefs, coreIndex: index)));
    if (mounted) setState(() => _activeCore = null);
  }

  void _designs() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF020711), builder: (ctx) => SafeArea(child: SizedBox(height: MediaQuery.of(ctx).size.height*.92, child: Column(children: [
      const Padding(padding: EdgeInsets.all(18), child: Text('SIX REALITIES — TAP TO ACTIVATE', style: TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 13))),
      Expanded(child: GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: .66), itemCount: realities.length, itemBuilder: (_,i) => GestureDetector(onTap: () async { await widget.prefs.setInt('lifeos_visual_design',i); if(mounted){setState(()=>_design=i);Navigator.pop(ctx);} }, child: Stack(fit: StackFit.expand, children:[ClipRRect(borderRadius:BorderRadius.circular(16),child:Image.asset(realities[i].$1,fit:BoxFit.cover)),Positioned(bottom:8,left:8,right:8,child:Text(realities[i].$2,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold,letterSpacing:1.4)))]))))
    ]))));
  }

  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF01040B), body: AnimatedBuilder(animation:_motion,builder:(_,__) => Stack(fit:StackFit.expand,children:[
      CustomPaint(painter:_ConstellationPainter(_motion.value,_design)),
      SafeArea(child: Stack(children:[
        Positioned(top:12,left:18,child:Row(children:[Image.asset('01_LifeOZ_App_Icon.png',width:44,height:44),const SizedBox(width:10),const Text('LIFEOZ',style:TextStyle(color:Colors.white,fontSize:25,letterSpacing:7,fontWeight:FontWeight.w300))])),
        Positioned(top:18,right:18,child:GestureDetector(onTap:_designs,child:Container(width:48,height:48,decoration:BoxDecoration(borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFFFFB74D),width:1.5),color:Colors.black45),child:const Icon(Icons.auto_awesome,color:Color(0xFFFFB74D))))),
        Center(child: GestureDetector(onTap:_yansi,child: AnimatedScale(duration:const Duration(milliseconds:400),scale:_yansiActive?1.08:1,child:Container(width:190,height:190,decoration:BoxDecoration(shape:BoxShape.circle,boxShadow:[BoxShadow(color:const Color(0xFF00BFFF).withOpacity(.35),blurRadius:55,spreadRadius:12)]),child:ClipOval(child:Image.asset('03_Yansi_Silent_Intelligence.png',fit:BoxFit.cover))))))),
        _coreNode(0, .20, .35, const Color(0xFFFFB52E), Icons.account_balance_wallet_rounded),
        _coreNode(1, .80, .35, const Color(0xFF58FF8B), Icons.track_changes_rounded),
        _coreNode(2, .18, .67, const Color(0xFF3CD7FF), Icons.bolt_rounded),
        _coreNode(3, .82, .67, const Color(0xFFB76CFF), Icons.home_work_rounded),
        _coreNode(4, .50, .84, const Color(0xFFFF6F91), Icons.favorite_rounded),
        Positioned(bottom:22,left:0,right:0,child:Column(children:[Text(_activeCore==null?'ONE TAP  •  ONE SCREEN  •  ONE REPORT':coreNames[_activeCore!],style:const TextStyle(color:Colors.white70,letterSpacing:2,fontSize:11)),const SizedBox(height:6),const Text('LIVING INTELLIGENCE',style:TextStyle(color:Colors.white38,letterSpacing:5,fontSize:10))]))
      ]),
    ]))));
  }

  Widget _coreNode(int index,double x,double y,Color color,IconData icon){
    final active=_activeCore==index;
    return Positioned(left:MediaQuery.sizeOf(context).width*x-42,top:MediaQuery.sizeOf(context).height*y-42,width:84,height:84,child:GestureDetector(onTap:()=>_core(index),child:AnimatedContainer(duration:const Duration(milliseconds:300),decoration:BoxDecoration(shape:BoxShape.circle,color:Colors.black.withOpacity(.72),border:Border.all(color:color,width:active?3:1.6),boxShadow:[BoxShadow(color:color.withOpacity(active?.55:.25),blurRadius:active?30:16,spreadRadius:active?4:1)]),child:Stack(alignment:Alignment.center,children:[Icon(icon,color:color,size:32),Positioned.fill(child:CustomPaint(painter:_OrbitalPainter(color,_motion.value)))]))));
  }
}

class _ConstellationPainter extends CustomPainter { final double t; final int design; _ConstellationPainter(this.t,this.design);
  @override void paint(Canvas c,Size s){final bg=Paint()..shader=RadialGradient(colors:[const Color(0xFF071B42),const Color(0xFF01040B)],radius:.85).createShader(Offset.zero& s);c.drawRect(Offset.zero& s,bg);final p=Paint()..strokeWidth=1..style=PaintingStyle.stroke..color=const Color(0xFF20BFFF).withOpacity(.10);final center=Offset(s.width/2,s.height*.49);for(int i=0;i<3;i++)c.drawOval(Rect.fromCenter(center:center,width:s.width*(.65+i*.14),height:s.height*(.18+i*.06)),p);final stars=Paint()..style=PaintingStyle.fill;for(int i=0;i<70;i++){final x=(math.sin(i*12.9898+design)*.5+.5)*s.width;final y=(math.sin(i*78.233+design*3)*.5+.5)*s.height;stars.color=Colors.white.withOpacity(.12+.12*((i%5)/5));c.drawCircle(Offset(x,y),.7+(i%3)*.35,stars);} }
  @override bool shouldRepaint(covariant _ConstellationPainter old)=>old.t!=t||old.design!=design;
}
class _OrbitalPainter extends CustomPainter { final Color color; final double t; _OrbitalPainter(this.color,this.t); @override void paint(Canvas c,Size s){final p=Paint()..color=color.withOpacity(.22)..style=PaintingStyle.stroke..strokeWidth=1.2;final r=s.width*.38;for(int i=0;i<2;i++){c.save();c.translate(s.width/2,s.height/2);c.rotate(t*math.pi*2+i*math.pi/2);c.drawOval(Rect.fromCenter(center:Offset.zero,width:r*2,height:r*.55),p);c.restore();}} @override bool shouldRepaint(covariant _OrbitalPainter old)=>old.t!=t||old.color!=color; }
