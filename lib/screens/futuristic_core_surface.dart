import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lifeos_core.dart';
import '../services/yansi_brain.dart';

class FuturisticCoreSurface extends StatefulWidget {
  final int core;
  final String currency;
  const FuturisticCoreSurface({super.key,required this.core,required this.currency});
  @override State<FuturisticCoreSurface> createState()=>_FuturisticCoreSurfaceState();
}

class _FuturisticCoreSurfaceState extends State<FuturisticCoreSurface> with SingleTickerProviderStateMixin {
  late final AnimationController _motion=AnimationController(vsync:this,duration:const Duration(seconds:7))..repeat();
  final FlutterTts _tts=FlutterTts();
  bool _loading=true;
  int _records=0;
  double _income=0,_expenses=0,_balance=0;
  String _insight='YANSI IS ANALYZING YOUR LIFEOS MEMORY';

  @override void initState(){super.initState();_load();}
  @override void dispose(){_motion.dispose();_tts.stop();super.dispose();}

  Future<void> _load() async{
    final prefs=await SharedPreferences.getInstance();
    final brain=YansiBrain(prefs:prefs);
    final memory=await brain.getMemory();
    final summary=await brain.getSummary();
    final filtered=memory.where((item){switch(widget.core){case 0:return item['type']=='expense'||item['type']=='income';case 1:return item['type']=='goal';case 2:return item['type']=='task'||item['type']=='reminder';case 3:return item['type']=='household';case 4:return item['type']=='reminder';default:return false;}}).toList();
    final income=(summary['income'] as num?)?.toDouble()??0;
    final expenses=(summary['expenses'] as num?)?.toDouble()??0;
    if(!mounted)return;
    setState((){_records=filtered.length;_income=income;_expenses=expenses;_balance=(summary['balance'] as num?)?.toDouble()??income-expenses;_loading=false;_insight=_makeInsight(filtered.length,income,expenses);});
  }

  String _makeInsight(int count,double income,double expenses){
    switch(widget.core){case 0:return expenses>income&&income>0?'Financial pressure detected — Yansi recommends reviewing spending.':'Financial field stable — Yansi is watching spending patterns.';case 1:return count==0?'No goal signal yet — tell Yansi what future you want.':'Yansi is tracking $count goal signal${count==1?'':'s'} toward your future.';case 2:return count==0?'No active task signal — Yansi is ready to organize your day.':'Yansi detected $count productivity signal${count==1?'':'s'} and can prioritize them.';case 3:return count==0?'Household intelligence is ready for your first signal.':'Yansi is tracking $count household record${count==1?'':'s'}.';default:return count==0?'Your Life calendar is waiting for its first event.':'Yansi has mapped $count upcoming calendar signal${count==1?'':'s'}.';}}

  Future<void> _speakInsight() async{try{await _tts.setLanguage('en-IN');await _tts.setSpeechRate(.45);await _tts.speak(_insight);}catch(_){}}
  String _money(double v){return v==v.roundToDouble()?'${widget.currency}${v.toInt()}':'${widget.currency}${v.toStringAsFixed(2)}';}
  String _main(){if(widget.core==0)return _money(_expenses);return '$_records';}
  String _label(){const x=['TOTAL SPENDING','GOALS','ACTIVE SIGNALS','HOUSEHOLD SIGNALS','UPCOMING EVENTS'];return x[widget.core];}

  @override Widget build(BuildContext context){
    final d=coreByIndex(widget.core);
    return Scaffold(backgroundColor:const Color(0xFF01060A),body:Stack(children:[
      Positioned.fill(child:AnimatedBuilder(animation:_motion,builder:(_,__)=>CustomPaint(painter:_Field(_motion.value)))),
      SafeArea(child:Column(children:[
        Padding(padding:const EdgeInsets.fromLTRB(12,8,12,0),child:Row(children:[_button(Icons.arrow_back_rounded,()=>Navigator.pop(context)),const Spacer(),Text('LIFEOS / CORE ${widget.core+1}',style:TextStyle(color:Colors.white.withOpacity(.55),fontSize:8,letterSpacing:2.5)),const Spacer(),_button(Icons.auto_awesome, _speakInsight)])),
        const SizedBox(height:18),
        Text(d.title.toUpperCase(),style:const TextStyle(color:Colors.white,fontSize:11,letterSpacing:4,fontWeight:FontWeight.w600)),
        const SizedBox(height:5),Text('INTELLIGENCE SURFACE',style:TextStyle(color:const Color(0xFF00E5FF).withOpacity(.65),fontSize:7,letterSpacing:2.5)),
        const SizedBox(height:20),
        AnimatedBuilder(animation:_motion,builder:(_,__)=>_Orb(icon:d.icon,phase:_motion.value)),
        const SizedBox(height:24),
        if(_loading)const SizedBox(height:100,child:Center(child:CircularProgressIndicator(strokeWidth:1.5,color:Color(0xFF00E5FF)))) else Column(children:[
          Text(_main(),style:const TextStyle(color:Colors.white,fontSize:30,fontWeight:FontWeight.w300,letterSpacing:1)),
          const SizedBox(height:4),Text(_label(),style:TextStyle(color:Colors.white.withOpacity(.42),fontSize:7,letterSpacing:2.4)),
          const SizedBox(height:18),
          if(widget.core==0)_moneyStrip() else _signalStrip(),
        ]),
        const SizedBox(height:18),
        Container(margin:const EdgeInsets.symmetric(horizontal:22),padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:Colors.white.withOpacity(.025),borderRadius:BorderRadius.circular(20),border:Border.all(color:const Color(0xFF00E5FF).withOpacity(.13))),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.psychology_alt_outlined,size:18,color:const Color(0xFF00E5FF).withOpacity(.85)),const SizedBox(width:12),Expanded(child:Text(_insight,style:TextStyle(color:Colors.white.withOpacity(.68),fontSize:10,height:1.4)))])),
        const Spacer(),
        Padding(padding:const EdgeInsets.only(bottom:20),child:Text('YANSI • LIVE INTELLIGENCE • PERMISSION CONTROLLED',style:TextStyle(color:Colors.white.withOpacity(.22),fontSize:6.5,letterSpacing:1.5))),
      ])),
    ]));
  }

  Widget _moneyStrip()=>Container(margin:const EdgeInsets.symmetric(horizontal:24),child:Row(children:[_metric('IN',_money(_income),const Color(0xFF35FF72)),_metric('OUT',_money(_expenses),const Color(0xFFFF5D72)),_metric('NET',_money(_balance),const Color(0xFF00E5FF))]));
  Widget _signalStrip()=>Container(margin:const EdgeInsets.symmetric(horizontal:24),child:Row(children:[_metric('MEMORY','$_records',const Color(0xFF00E5FF)),_metric('STATUS','LIVE',const Color(0xFF35FF72)),_metric('AI','READY',const Color(0xFFD24CFF))]));
  Widget _metric(String a,String b,Color c)=>Expanded(child:Column(children:[Text(b,style:TextStyle(color:c,fontSize:11,fontWeight:FontWeight.w600)),const SizedBox(height:3),Text(a,style:TextStyle(color:Colors.white.withOpacity(.28),fontSize:6.5,letterSpacing:1.4))]));
  Widget _button(IconData icon,VoidCallback action)=>GestureDetector(onTap:action,child:Container(width:38,height:38,decoration:BoxDecoration(shape:BoxShape.circle,color:Colors.white.withOpacity(.035),border:Border.all(color:const Color(0xFF00E5FF).withOpacity(.22))),child:Icon(icon,size:17,color:Colors.white.withOpacity(.72))));
}

class _Orb extends StatelessWidget{final IconData icon;final double phase;const _Orb({required this.icon,required this.phase});@override Widget build(BuildContext context){final s=1+math.sin(phase*math.pi*2)*.04;return Transform.scale(scale:s,child:Stack(alignment:Alignment.center,children:[for(int i=0;i<5;i++)Transform.rotate(angle:phase*math.pi*2*(i.isEven?1:-1)+i*.4,child:Container(width:100+i*27,height:100+i*27,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:(i.isEven?const Color(0xFF00E5FF):const Color(0xFF35FF72)).withOpacity(.08+i*.018))))),Container(width:88,height:88,decoration:BoxDecoration(shape:BoxShape.circle,gradient:const RadialGradient(colors:[Color(0xAA00E5FF),Color(0x2200E5FF),Colors.transparent]),boxShadow:const [BoxShadow(color:Color(0x5500E5FF),blurRadius:48)]),child:Icon(icon,size:28,color:Colors.white))]));}}

class _Field extends CustomPainter{final double phase;_Field(this.phase);@override void paint(Canvas canvas,Size size){final c=Offset(size.width/2,size.height*.38);final p=Paint();for(int i=0;i<45;i++){final a=i*.73+phase*math.pi*2;final r=size.width*(.12+(i%12)*.035);final e=c+Offset(math.cos(a)*r,math.sin(a)*r*.65);p.color=(i%3==0?const Color(0xFF35FF72):const Color(0xFF00E5FF)).withOpacity(.018+(i%5)*.007);canvas.drawCircle(e,i%8==0?1.2:.65,p);if(i%6==0)canvas.drawLine(c,e,p);}final ring=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0xFF00E5FF).withOpacity(.045);canvas.drawOval(Rect.fromCenter(center:c,width:size.width*.75,height:size.height*.22),ring);canvas.drawOval(Rect.fromCenter(center:c,width:size.width*.9,height:size.height*.30),ring);}@override bool shouldRepaint(covariant _Field old)=>old.phase!=phase;}
