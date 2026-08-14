import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeOZMasterShell extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZMasterShell({super.key, required this.prefs});
  @override State<LifeOZMasterShell> createState() => _LifeOZMasterShellState();
}

class _LifeOZMasterShellState extends State<LifeOZMasterShell> with SingleTickerProviderStateMixin {
  late AnimationController animation;
  final FlutterTts tts = FlutterTts();
  Timer? timer;
  String name = '';
  bool splash = true;
  int active = -1;
  double yaw = 0;
  double pitch = 0;
  static const coreColors = <Color>[Color(0xFF42F5A7),Color(0xFFFFB14A),Color(0xFFB66BFF),Color(0xFF42DFFF),Color(0xFFD968FF)];
  static const messages = <String>['Life intelligence is ready.','Growth intelligence is ready.','Productivity intelligence is ready.','Time intelligence is ready.','Future intelligence is ready.'];

  @override void initState(){super.initState();name=widget.prefs.getString('user_name')??'';animation=AnimationController(vsync:this,duration:const Duration(seconds:16))..repeat();tts.setSpeechRate(.44);timer=Timer(const Duration(milliseconds:1600),(){if(mounted)setState((){splash=false;});});}
  @override void dispose(){timer?.cancel();animation.dispose();tts.stop();super.dispose();}
  Future<void> speak(String text)async{await tts.stop();await tts.speak(text);}

  @override Widget build(BuildContext context){return Scaffold(backgroundColor:const Color(0xFF01040A),body:SafeArea(child:AnimatedBuilder(animation:animation,builder:(context,child){return Stack(fit:StackFit.expand,children:<Widget>[CustomPaint(painter:BackgroundPainter(animation.value)),splash?_splash():_home()]);})));}

  Widget _splash(){return Center(child:Column(mainAxisSize:MainAxisSize.min,children:<Widget>[SizedBox(width:210,height:210,child:CustomPaint(painter:YansiPainter(animation.value,const Color(0xFF20D9FF),yaw,pitch,true))),const SizedBox(height:14),const Text('LifeOZ',style:TextStyle(color:Colors.white,fontSize:34,fontWeight:FontWeight.w900,letterSpacing:5)),const SizedBox(height:7),const Text('INITIALIZING LIVING INTELLIGENCE',style:TextStyle(color:Color(0xFF63E8FF),fontSize:9,letterSpacing:1.7))]));}

  Widget _home(){return LayoutBuilder(builder:(context,box){final double w=box.maxWidth;final double h=box.maxHeight;final Offset center=Offset(w/2,h*.46);final double orbSize=math.min(w*.70,330.0);final List<Offset> nodes=<Offset>[Offset(w*.50,h*.14),Offset(w*.16,h*.30),Offset(w*.84,h*.30),Offset(w*.17,h*.70),Offset(w*.83,h*.70)];return Stack(children:<Widget>[
    Positioned(top:12,left:18,right:18,child:Row(children:<Widget>[SizedBox(width:44,height:44,child:CustomPaint(painter:LogoPainter(animation.value))),const SizedBox(width:9),const Text('LifeOZ',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.w900,letterSpacing:3)),const Spacer(),Container(width:48,height:48,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:const Color(0xFF20D9FF).withValues(alpha:.65))),child:const Icon(Icons.auto_awesome,color:Color(0xFF20D9FF)))])),
    Positioned.fill(child:CustomPaint(painter:NetworkPainter(animation.value,nodes,center,active))),
    for(int i=0;i<nodes.length;i++) Positioned(left:nodes[i].dx-50,top:nodes[i].dy-50,child:GestureDetector(onTap:(){setState((){active=i;});speak(messages[i]);},child:SizedBox(width:100,height:100,child:CustomPaint(painter:CorePainter(i,coreColors[i],animation.value,active==i))))),
    Positioned(left:center.dx-orbSize/2,top:center.dy-orbSize/2,child:GestureDetector(onPanUpdate:(details){setState((){yaw=yaw+details.delta.dx*.008;pitch=pitch+details.delta.dy*.008;if(yaw>1.2)yaw=1.2;if(yaw< -1.2)yaw=-1.2;if(pitch>.8)pitch=.8;if(pitch<-.8)pitch=-.8;});},onTap:(){String text='I am Yansi, your personal LifeOS intelligence.';if(name.isNotEmpty){text='Welcome, '+name+'. I am Yansi, your personal LifeOS intelligence.';}speak(text);},child:SizedBox(width:orbSize,height:orbSize,child:CustomPaint(painter:YansiPainter(animation.value,const Color(0xFF20D9FF),yaw,pitch,true))))),
    Positioned(left:18,right:18,bottom:14,child:Container(height:50,decoration:BoxDecoration(color:Colors.black.withValues(alpha:.34),borderRadius:BorderRadius.circular(25),border:Border.all(color:Colors.white.withValues(alpha:.10))),child:const Row(mainAxisAlignment:MainAxisAlignment.center,children:<Widget>[Icon(Icons.threed_rotation,color:Color(0xFF6BEAFF),size:18),SizedBox(width:8),Text('DRAG YANSI • ROTATE THE LIVING CORE',style:TextStyle(color:Colors.white70,fontSize:9,letterSpacing:1.0,fontWeight:FontWeight.w700))]))),
  ]);});}
}

class BackgroundPainter extends CustomPainter{final double phase;BackgroundPainter(this.phase);@override void paint(Canvas c,Size s){final rect=Offset.zero&s;c.drawRect(rect,Paint()..shader=RadialGradient(radius:1.15,colors:<Color>[const Color(0xFF061A2A),const Color(0xFF010207)]).createShader(rect));final r=math.Random(77);for(int i=0;i<120;i++){final a=.02+.04*((math.sin(phase*math.pi*2+i)+1)/2);c.drawCircle(Offset(r.nextDouble()*s.width,r.nextDouble()*s.height),.5+r.nextDouble(),Paint()..color=Colors.white.withValues(alpha:a));}}@override bool shouldRepaint(covariant BackgroundPainter old)=>true;}

class NetworkPainter extends CustomPainter{final double phase;final List<Offset> nodes;final Offset center;final int active;NetworkPainter(this.phase,this.nodes,this.center,this.active);@override void paint(Canvas c,Size s){final p=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0xFF20D9FF).withValues(alpha:.13);for(final n in nodes){c.drawLine(center,n,p);final double t=(phase+n.dx/s.width)%1;c.drawCircle(Offset.lerp(center,n,t)!,2,Paint()..color=const Color(0xFF20D9FF).withValues(alpha:.75));}double ring=44+7*math.sin(phase*math.pi*2);double opacity=.14;if(active>=0)opacity=.30;c.drawCircle(center,ring,Paint()..style=PaintingStyle.stroke..strokeWidth=1.2..color=const Color(0xFF20D9FF).withValues(alpha:opacity));}@override bool shouldRepaint(covariant NetworkPainter old)=>true;}

class LogoPainter extends CustomPainter{final double phase;LogoPainter(this.phase);@override void paint(Canvas c,Size s){final m=Offset(s.width/2,s.height/2);final r=s.width*.4;final p=Paint()..style=PaintingStyle.stroke..strokeWidth=1.8..color=const Color(0xFF20D9FF).withValues(alpha:.8);c.drawCircle(m,r,p);c.drawOval(Rect.fromCenter(center:m,width:r*1.55,height:r*.55),p);c.drawCircle(Offset(m.dx+math.cos(phase*math.pi*2)*r*.7,m.dy),2.8,Paint()..color=const Color(0xFF48F0A0));}@override bool shouldRepaint(covariant LogoPainter old)=>true;}

class CorePainter extends CustomPainter{final int index;final Color color;final double phase;final bool active;CorePainter(this.index,this.color,this.phase,this.active);@override void paint(Canvas c,Size s){final m=Offset(s.width/2,s.height/2);final r=28*(1+.06*math.sin(phase*math.pi*2+index));double glow=.12;double stroke=1.1;double alpha=.55;if(active){glow=.28;stroke=2.2;alpha=.95;}c.drawCircle(m,r*1.2,Paint()..color=color.withValues(alpha:glow)..maskFilter=const MaskFilter.blur(BlurStyle.normal,16));c.drawCircle(m,r,Paint()..shader=RadialGradient(colors:<Color>[Colors.white.withValues(alpha:.85),color,Colors.black]).createShader(Rect.fromCircle(center:m,radius:r)));final p=Paint()..style=PaintingStyle.stroke..strokeWidth=stroke..color=color.withValues(alpha:alpha);for(int k=0;k<2;k++){c.save();c.translate(m.dx,m.dy);c.rotate(phase*math.pi*2*(k==0?1:-.7)+index);c.drawOval(Rect.fromCenter(center:Offset.zero,width:r*2.6,height:r*.72),p);c.restore();}}@override bool shouldRepaint(covariant CorePainter old)=>true;}

class YansiPainter extends CustomPainter{final double phase;final Color color;final double yaw;final double pitch;final bool large;YansiPainter(this.phase,this.color,this.yaw,this.pitch,this.large);Offset project(double x,double y,double z,double scale){final double a=yaw+math.sin(phase*math.pi*2)*.30;final double b=pitch+math.cos(phase*math.pi*2)*.15;final double x1=x*math.cos(a)-z*math.sin(a);final double z1=x*math.sin(a)+z*math.cos(a);final double y1=y*math.cos(b)-z1*math.sin(b);final double z2=y*math.sin(b)+z1*math.cos(b);final double q=1/(1+z2*.42);return Offset(x1*q*scale,y1*q*scale);}
  @override void paint(Canvas c,Size s){final Offset m=Offset(s.width/2,s.height/2);double scale=s.shortestSide*.31;if(!large)scale=s.shortestSide*.36;final double breathe=1+.055*math.sin(phase*math.pi*2);double glowAlpha=.12;double glowBlur=13;if(large){glowAlpha=.16;glowBlur=28;}c.drawCircle(m,scale*1.35*breathe,Paint()..color=color.withValues(alpha:glowAlpha)..maskFilter=MaskFilter.blur(BlurStyle.normal,glowBlur));c.drawCircle(m,scale*breathe,Paint()..shader=RadialGradient(center:const Alignment(-.25,-.28),radius:1,colors:<Color>[Colors.white.withValues(alpha:.95),color.withValues(alpha:.9),color.withValues(alpha:.3),const Color(0xFF01040A)],stops:const <double>[0,.17,.58,1]).createShader(Rect.fromCircle(center:m,radius:scale)));
    double widthStroke=.65;if(large)widthStroke=1;final p=Paint()..style=PaintingStyle.stroke..strokeWidth=widthStroke..color=color.withValues(alpha:.6);for(int i=0;i<7;i++){final double lat=-1+i*(2/6);final double y=lat*scale;final double width=math.sqrt(math.max(0,1-lat*lat))*scale;c.save();c.translate(m.dx,m.dy+y*math.cos(pitch));double direction=.55;if(!i.isEven)direction=-.4;c.rotate(phase*math.pi*2*direction+yaw);c.drawOval(Rect.fromCenter(center:Offset.zero,width:width*2,height:scale*.28),p);c.restore();}
    final random=math.Random(92);final particles=<Particle>[];int count=42;if(large)count=120;for(int i=0;i<count;i++){final double theta=random.nextDouble()*math.pi*2;final double phi=math.acos(2*random.nextDouble()-1);final double radius=.72+random.nextDouble()*.36;double x=math.sin(phi)*math.cos(theta)*radius;final double y=math.cos(phi)*radius;double z=math.sin(phi)*math.sin(theta)*radius;final double spin=phase*math.pi*2*(.7+(i%5)*.08);final double rx=x*math.cos(spin)-z*math.sin(spin);z=x*math.sin(spin)+z*math.cos(spin);x=rx;particles.add(Particle(project(x,y,z,scale),(1-z).clamp(.35,1.6),z));}particles.sort((a,b)=>a.z.compareTo(b.z));for(final particle in particles){double pr=.7+particle.depth*(large?1.9:1.2);pr=pr.clamp(.55,3.0);c.drawCircle(m+particle.offset,pr,Paint()..color=Colors.white.withValues(alpha:(.18+particle.depth*.35).clamp(.12,.75)));}
    for(int i=0;i<3;i++){final double angle=phase*math.pi*2*(1+i*.17)+i*2.1;final Offset pos=m+project(math.cos(angle)*1.18,math.sin(angle*1.7)*.55,math.sin(angle)*.85,scale);c.drawCircle(pos,2.2,Paint()..color=color);}c.drawCircle(m.translate(-scale*.25,-scale*.30),scale*.12,Paint()..color=Colors.white.withValues(alpha:.5));}
  @override bool shouldRepaint(covariant YansiPainter old)=>true;}
class Particle{final Offset offset;final double depth;final double z;Particle(this.offset,this.depth,this.z);}
