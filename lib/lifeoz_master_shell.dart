import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeOZMasterShell extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZMasterShell({super.key, required this.prefs});

  @override
  State<LifeOZMasterShell> createState() => _LifeOZMasterShellState();
}

class _LifeOZMasterShellState extends State<LifeOZMasterShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  final FlutterTts _tts = FlutterTts();
  Timer? _splashTimer;
  String _name = '';
  bool _splash = true;
  int _activeCore = -1;
  int _environment = 0;
  int _reality = 0;
  double _yaw = 0;
  double _pitch = 0;

  static const List<Color> coreColors = <Color>[
    Color(0xFF42F5A7),
    Color(0xFFFFB14A),
    Color(0xFFB66BFF),
    Color(0xFF42DFFF),
    Color(0xFFD968FF),
  ];
  static const List<String> coreMessages = <String>[
    'Life and household intelligence is ready.',
    'Goals and growth intelligence is ready.',
    'Productivity intelligence is ready.',
    'Time and calendar intelligence is ready.',
    'Future intelligence is ready.',
  ];
  static const List<String> environments = <String>['Morning', 'Work', 'Evening', 'Focus', 'Rest'];
  static const List<String> realities = <String>[
    'OREON PRIME', 'TERRA FLUX', 'VORTEX NEXUS', 'CRYSTA LUMEN', 'NEBULA SOUL', 'SHADOW CORE'
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.prefs.getString('user_name') ?? '';
    _motion = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat();
    _tts.setSpeechRate(.44);
    _splashTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _splash = false);
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _motion.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Color get _realmColor => <Color>[
    const Color(0xFF20D9FF), const Color(0xFF48F0A0), const Color(0xFF9C70FF),
    const Color(0xFF62E7FF), const Color(0xFFFF67D4), const Color(0xFF9B9BFF)
  ][_reality];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01040A),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _motion,
          builder: (_, __) => Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CustomPaint(painter: _SpacePainter(_motion.value, _reality, _environment)),
              if (_splash) _splashView() else _homeView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _splashView() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      SizedBox(width: 210, height: 210, child: CustomPaint(painter: _Yansi3DPainter(_motion.value, const Color(0xFF20D9FF), _yaw, _pitch, true))),
      const SizedBox(height: 14),
      const Text('LifeOZ', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 5)),
      const SizedBox(height: 7),
      const Text('INITIALIZING LIVING INTELLIGENCE', style: TextStyle(color: Color(0xFF63E8FF), fontSize: 9, letterSpacing: 1.7)),
    ]),
  );

  Widget _homeView() => LayoutBuilder(builder: (_, c) {
    final double w = c.maxWidth, h = c.maxHeight;
    final Offset center = Offset(w / 2, h * .46);
    final double orb = math.min(w * .70, 330);
    final List<Offset> nodes = <Offset>[
      Offset(w*.50,h*.14), Offset(w*.16,h*.30), Offset(w*.84,h*.30),
      Offset(w*.17,h*.70), Offset(w*.83,h*.70)
    ];
    return Stack(children: <Widget>[
      Positioned(top: 12,left: 18,right: 18,child: _topBar()),
      Positioned.fill(child: CustomPaint(painter: _NetworkPainter(_motion.value,nodes,center,_activeCore,_realmColor))),
      for (int i=0;i<nodes.length;i++) Positioned(
        left:nodes[i].dx-50,top:nodes[i].dy-50,
        child: GestureDetector(onTap:(){setState(()=>_activeCore=i);_speak(coreMessages[i]);},child:SizedBox(width:100,height:100,child:CustomPaint(painter:_Core3DPainter(i,coreColors[i],_motion.value,_activeCore==i))))),
      Positioned(left:center.dx-orb/2,top:center.dy-orb/2,child:GestureDetector(
        onPanUpdate:(d){setState((){_yaw=(_yaw+d.delta.dx*.008).clamp(-1.2,1.2);_pitch=(_pitch+d.delta.dy*.008).clamp(-.8,.8);});},
        onTap:()=>_speak(_name.isEmpty?'I am Yansi, your personal LifeOS intelligence.':'Welcome, $_name. I am Yansi, your personal LifeOS intelligence.'),
        child:SizedBox(width:orb,height:orb,child:CustomPaint(painter:_Yansi3DPainter(_motion.value,_activeCore<0?_realmColor:coreColors[_activeCore],_yaw,_pitch,true))),
      )),
      Positioned(left:18,right:18,bottom:14,child:_bottomBar()),
    ]);
  });

  Widget _topBar()=>Row(children:<Widget>[
    SizedBox(width:44,height:44,child:CustomPaint(painter:_LogoPainter(_motion.value))),
    const SizedBox(width:9),
    const Text('LifeOZ',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.w900,letterSpacing:3)),
    const Spacer(),
    _circleButton(Icons.auto_awesome,_openRealities),
  ]);

  Widget _circleButton(IconData icon,VoidCallback tap)=>GestureDetector(onTap:tap,child:Container(width:48,height:48,decoration:BoxDecoration(shape:BoxShape.circle,color:Colors.black.withValues(alpha:.3),border:Border.all(color:const Color(0xFF20D9FF).withValues(alpha:.65)),boxShadow:<BoxShadow>[BoxShadow(color:const Color(0xFF20D9FF).withValues(alpha:.2),blurRadius:18)]),child:Icon(icon,color:const Color(0xFF20D9FF),size:24)));

  Widget _bottomBar()=>Row(children:<Widget>[
    Expanded(child:_bottomButton(Icons.auto_awesome,realities[_reality],_openRealities)),const SizedBox(width:10),
    Expanded(child:_bottomButton(Icons.wb_sunny_outlined,environments[_environment].toUpperCase(),_openEnvironment)),
  ]);

  Widget _bottomButton(IconData icon,String text,VoidCallback tap)=>GestureDetector(onTap:tap,child:Container(height:50,decoration:BoxDecoration(color:Colors.black.withValues(alpha:.34),borderRadius:BorderRadius.circular(25),border:Border.all(color:Colors.white.withValues(alpha:.1))),child:Row(mainAxisAlignment:MainAxisAlignment.center,children:<Widget>[Icon(icon,color:const Color(0xFF6BEAFF),size:17),const SizedBox(width:7),Flexible(child:Text(text,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.white70,fontSize:9,letterSpacing:1.1,fontWeight:FontWeight.w700))) ])));

  void _openRealities()=>showModalBottomSheet<void>(context:context,backgroundColor:const Color(0xFF050B14),isScrollControlled:true,builder:(ctx)=>SafeArea(child:SizedBox(height:MediaQuery.of(ctx).size.height*.72,child:Column(children:<Widget>[
    const SizedBox(height:18),const Text('LIVING VISUAL REALITIES',style:TextStyle(color:Colors.white,fontSize:17,fontWeight:FontWeight.w800,letterSpacing:2)),
    const SizedBox(height:5),const Text('Moving worlds — not static images.',style:TextStyle(color:Color(0xFF6BEAFF),fontSize:9)),const SizedBox(height:14),
    Expanded(child:ListView.builder(padding:const EdgeInsets.all(16),itemCount:realities.length,itemBuilder:(ctx,i)=>GestureDetector(onTap:(){setState(()=>_reality=i);Navigator.pop(ctx);_speak('${realities[i]} selected.');},child:Container(height:88,margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.symmetric(horizontal:12),decoration:BoxDecoration(borderRadius:BorderRadius.circular(20),border:Border.all(color:(<Color>[const Color(0xFF20D9FF),const Color(0xFF48F0A0),const Color(0xFF9C70FF),const Color(0xFF62E7FF),const Color(0xFFFF67D4),const Color(0xFF9B9BFF>)[i]).withValues(alpha:_reality==i?.85:.22)),gradient:LinearGradient(colors:<Color>[(<Color>[const Color(0xFF20D9FF),const Color(0xFF48F0A0),const Color(0xFF9C70FF),const Color(0xFF62E7FF),const Color(0xFFFF67D4),const Color(0xFF9B9BFF>)[i]).withValues(alpha:.15),Colors.black.withValues(alpha:.35)])),child:Row(children:<Widget>[SizedBox(width:70,height:70,child:CustomPaint(painter:_Yansi3DPainter(_motion.value+i*.1,(<Color>[const Color(0xFF20D9FF),const Color(0xFF48F0A0),const Color(0xFF9C70FF),const Color(0xFF62E7FF),const Color(0xFFFF67D4),const Color(0xFF9B9BFF>)[i],_yaw,_pitch,false))),const SizedBox(width:12),Expanded(child:Text(realities[i],style:const TextStyle(color:Colors.white,fontSize:12,fontWeight:FontWeight.w800,letterSpacing:1))),Icon(Icons.arrow_forward_ios,color:const Color(0xFF6BEAFF),size:14)]))))),
  ]))));

  void _openEnvironment()=>showModalBottomSheet<void>(context:context,backgroundColor:const Color(0xFF050B14),builder:(ctx)=>SafeArea(child:Padding(padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,children:<Widget>[
    const Text('ADAPTIVE ENVIRONMENT',style:TextStyle(color:Colors.white,fontSize:16,fontWeight:FontWeight.w800,letterSpacing:1.8)),const SizedBox(height:15),
    Wrap(alignment:WrapAlignment.center,spacing:12,runSpacing:12,children:List<Widget>.generate(environments.length,(i)=>GestureDetector(onTap:(){setState(()=>_environment=i);Navigator.pop(ctx);_speak('${environments[i]} environment selected.');},child:Container(width:82,height:82,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:coreColors[i].withValues(alpha:_environment==i?.9:.35)),gradient:RadialGradient(colors:<Color>[coreColors[i],const Color(0xFF02050A)])),child:Center(child:Text(environments[i],style:const TextStyle(color:Colors.white,fontSize:9))))))
  ]))));
}

class _SpacePainter extends CustomPainter {
  final double phase;final int reality;final int environment;_SpacePainter(this.phase,this.reality,this.environment);
  @override void paint(Canvas c,Size s){
    const List<Color> b=<Color>[Color(0xFF061A2A),Color(0xFF071E16),Color(0xFF160A25),Color(0xFF061923),Color(0xFF190817),Color(0xFF03030A)];
    c.drawRect(Offset.zero&s,Paint()..shader=RadialGradient(center:Alignment(0,-.15),radius:1.15,colors:<Color>[b[reality],const Color(0xFF010207)]).createShader(Offset.zero&s));
    final math.Random r=math.Random(700+reality*17);for(int i=0;i<120;i++){final double tw=.2+.8*((math.sin(phase*math.pi*2+i*.77)+1)/2);c.drawCircle(Offset(r.nextDouble()*s.width,r.nextDouble()*s.height),.4+r.nextDouble()*1.1,Paint()..color=Colors.white.withValues(alpha:.06*tw));}
    c.drawCircle(Offset(s.width/2,s.height*.46),s.width*.28,Paint()..color=const Color(0xFF20D9FF).withValues(alpha:.025+.02*((math.sin(phase*math.pi*2+environment)+1)/2))..maskFilter=const MaskFilter.blur(BlurStyle.normal,55));
  }
  @override bool shouldRepaint(covariant _SpacePainter old)=>true;
}

class _NetworkPainter extends CustomPainter {
  final double phase;final List<Offset> nodes;final Offset center;final int active;final Color color;_NetworkPainter(this.phase,this.nodes,this.center,this.active,this.color);
  @override void paint(Canvas c,Size s){final Paint p=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=color.withValues(alpha:.13);for(final n in nodes){c.drawLine(center,n,p);final m=Offset.lerp(center,n,(phase+n.dx/s.width)%1)!;c.drawCircle(m,2.1,Paint()..color=color.withValues(alpha:.7));}for(int i=0;i<nodes.length;i++){for(int j=i+1;j<nodes.length;j++)c.drawLine(nodes[i],nodes[j],p..color=color.withValues(alpha:.035));}c.drawCircle(center,42+8*math.sin(phase*math.pi*2),Paint()..style=PaintingStyle.stroke..strokeWidth=1.2..color=color.withValues(alpha:active>=0?.3:.14));}
  @override bool shouldRepaint(covariant _NetworkPainter old)=>true;
}

class _LogoPainter extends CustomPainter {
  final double phase;_LogoPainter(this.phase);
  @override void paint(Canvas c,Size s){final Offset m=Offset(s.width/2,s.height/2);final double r=s.width*.4;final Paint p=Paint()..style=PaintingStyle.stroke..strokeWidth=1.8..color=const Color(0xFF20D9FF).withValues(alpha:.8);c.drawCircle(m,r,p);c.drawOval(Rect.fromCenter(center:m,width:r*1.55,height:r*.55),p);c.drawCircle(Offset(m.dx+math.cos(phase*math.pi*2)*r*.7,m.dy),2.8,Paint()..color=const Color(0xFF48F0A0));}
  @override bool shouldRepaint(covariant _LogoPainter old)=>true;
}

class _Core3DPainter extends CustomPainter {
  final int index;final Color color;final double phase;final bool active;_Core3DPainter(this.index,this.color,this.phase,this.active);
  @override void paint(Canvas c,Size s){final Offset m=Offset(s.width/2,s.height/2);final double rad=28*(1+.06*math.sin(phase*math.pi*2+index));c.drawCircle(m,rad*1.2,Paint()..color=color.withValues(alpha:active?.28:.12)..maskFilter=const MaskFilter.blur(BlurStyle.normal,16));c.drawCircle(m,rad,Paint()..shader=RadialGradient(colors:<Color>[Colors.white.withValues(alpha:.85),color,Colors.black]).createShader(Rect.fromCircle(center:m,radius:rad)));final Paint p=Paint()..style=PaintingStyle.stroke..strokeWidth=active?2.2:1.1..color=color.withValues(alpha:active?.95:.55);for(int k=0;k<2;k++){c.save();c.translate(m.dx,m.dy);c.rotate(phase*math.pi*2*(k==0?1:-.7)+index);c.drawOval(Rect.fromCenter(center:Offset.zero,width:rad*2.6,height:rad*.72),p);c.restore();}}
  @override bool shouldRepaint(covariant _Core3DPainter old)=>true;
}

class _Yansi3DPainter extends CustomPainter {
  final double phase;final Color color;final double yaw;final double pitch;final bool large;_Yansi3DPainter(this.phase,this.color,this.yaw,this.pitch,this.large);
  Offset project(double x,double y,double z,double scale){final double a=yaw+math.sin(phase*math.pi*2)*.3;final double b=pitch+math.cos(phase*math.pi*2)*.15;final double x1=x*math.cos(a)-z*math.sin(a);final double z1=x*math.sin(a)+z*math.cos(a);final double y1=y*math.cos(b)-z1*math.sin(b);final double z2=y*math.sin(b)+z1*math.cos(b);final double q=1/(1+z2*.42);return Offset(x1*q*scale,y1*q*scale);}
  @override void paint(Canvas c,Size s){final Offset m=Offset(s.width/2,s.height/2);final double sc=s.shortestSide*(large?.31:.36);final double breath=1+.055*math.sin(phase*math.pi*2);c.drawCircle(m,sc*1.35*breath,Paint()..color=color.withValues(alpha:large?.16:.12)..maskFilter=MaskFilter.blur(BlurStyle.normal,large?28:13));c.drawCircle(m,sc*breath,Paint()..shader=RadialGradient(center:const Alignment(-.25,-.28),radius:1,colors:<Color>[Colors.white.withValues(alpha:.95),color.withValues(alpha:.9),color.withValues(alpha:.3),const Color(0xFF01040A)],stops:const <double>[0,.17,.58,1]).createShader(Rect.fromCircle(center:m,radius:sc)));
    final Paint filament=Paint()..style=PaintingStyle.stroke..strokeWidth=large?1:.65..color=color.withValues(alpha:.6);for(int ring=0;ring<7;ring++){final double lat=-1+ring*(2/6),yy=lat*sc,width=math.sqrt(math.max(0,1-lat*lat))*sc; c.save();c.translate(m.dx,m.dy+yy*math.cos(pitch));c.rotate(phase*math.pi*2*(ring.isEven?.55:-.4)+yaw);c.drawOval(Rect.fromCenter(center:Offset.zero,width:width*2,height:sc*.28),filament);c.restore();}
    final math.Random r=math.Random(92);final List<_P> ps=< _P>[];for(int i=0;i<(large?120:42);i++){final double t=r.nextDouble()*math.pi*2,ph=math.acos(2*r.nextDouble()-1),rr=.72+r.nextDouble()*.36;double x=math.sin(ph)*math.cos(t)*rr,y=math.cos(ph)*rr,z=math.sin(ph)*math.sin(t)*rr;final double spin=phase*math.pi*2*(.7+(i%5)*.08);final double rx=x*math.cos(spin)-z*math.sin(spin);z=x*math.sin(spin)+z*math.cos(spin);x=rx;ps.add(_P(project(x,y,z,sc),(1-z).clamp(.35,1.6),z));}ps.sort((a,b)=>a.z.compareTo(b.z));for(final p in ps){final double rr=(.7+p.d*(large?1.9:1.2)).clamp(.55,3.0);c.drawCircle(m+p.o,rr,Paint()..color=Colors.white.withValues(alpha:(.18+p.d*.35).clamp(.12,.75)));}
    for(int i=0;i<3;i++){final double a=phase*math.pi*2*(1+i*.17)+i*2.1,x=math.cos(a)*1.18,y=math.sin(a*1.7)*.55,z=math.sin(a)*.85;final Offset p=m+project(x,y,z,sc);c.drawCircle(p,2.2+(1-z).clamp(0,1)*2.5,Paint()..color=color);}
    c.drawCircle(m.translate(-sc*.25,-sc*.30),sc*.12,Paint()..color=Colors.white.withValues(alpha:.45+.25*math.sin(phase*math.pi*4)));
  }
  @override bool shouldRepaint(covariant _Yansi3DPainter old)=>true;
}
class _P{final Offset o;final double d;final double z;_P(this.o,this.d,this.z);}
