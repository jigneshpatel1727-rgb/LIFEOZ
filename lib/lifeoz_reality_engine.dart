import 'dart:math' as math;
import 'package:flutter/material.dart';

class LifeOZRealityEngine extends StatefulWidget {
  final int initialReality;
  const LifeOZRealityEngine({super.key, this.initialReality = 0});
  @override State<LifeOZRealityEngine> createState() => _LifeOZRealityEngineState();
}

class _LifeOZRealityEngineState extends State<LifeOZRealityEngine> with SingleTickerProviderStateMixin {
  late final AnimationController motion = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  late int reality;
  double rotation = 0, tilt = 0;
  static const names = <String>['OREON PRIME','TERRA FLUX','VORTEX NEXUS','CRYSTA LUMEN','NEBULA SOUL','SHADOW CORE'];
  static const accents = <Color>[Color(0xFFFFB14A),Color(0xFF42F5A7),Color(0xFF42DFFF),Color(0xFFB66BFF),Color(0xFFD968FF),Color(0xFF7A8CFF)];

  @override void initState(){super.initState(); reality = widget.initialReality.clamp(0, names.length - 1).toInt();}
  @override void dispose(){motion.dispose();super.dispose();}

  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor:const Color(0xFF01040A),body:SafeArea(child:GestureDetector(
      onPanUpdate:(d){setState((){rotation+=d.delta.dx*.008;tilt+=d.delta.dy*.006;if(tilt>.7)tilt=.7;if(tilt<-.7)tilt=-.7;});},
      child:AnimatedBuilder(animation:motion,builder:(context,_){return Stack(fit:StackFit.expand,children:[
        CustomPaint(painter:RealityPainter(motion.value,rotation,tilt,accents[reality],reality)),
        Positioned(top:20,left:20,right:20,child:Row(children:[IconButton(onPressed:()=>Navigator.maybePop(context),icon:const Icon(Icons.arrow_back_ios_new),color:Colors.white70),const Spacer(),Text(names[reality],style:const TextStyle(color:Colors.white,fontSize:12,fontWeight:FontWeight.w800,letterSpacing:2.2))])),
        Positioned(left:18,right:18,bottom:18,child:RealityPicker(current:reality,accents:accents,onChanged:(v)=>setState(()=>reality=v))),
      ];});
    )));
  }
}

class RealityPicker extends StatelessWidget {
  final int current; final List<Color> accents; final ValueChanged<int> onChanged;
  const RealityPicker({super.key,required this.current,required this.accents,required this.onChanged});
  @override Widget build(BuildContext context){return Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.black.withValues(alpha:.42),borderRadius:BorderRadius.circular(24),border:Border.all(color:Colors.white.withValues(alpha:.10))),child:Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:List.generate(6,(i){final selected=i==current;return GestureDetector(onTap:()=>onChanged(i),child:AnimatedContainer(duration:const Duration(milliseconds:240),width:selected?42:30,height:selected?42:30,decoration:BoxDecoration(shape:BoxShape.circle,color:accents[i].withValues(alpha:selected?.20:.07),border:Border.all(color:accents[i].withValues(alpha:selected?.95:.35),width:selected?1.6:1),boxShadow:selected?[BoxShadow(color:accents[i].withValues(alpha:.35),blurRadius:16)]:null),child:Center(child:Text('${i+1}',style:TextStyle(color:accents[i],fontSize:selected?13:10,fontWeight:FontWeight.w900)))));})));}
}

class RealityPainter extends CustomPainter {
  final double phase,rotation,tilt; final Color accent; final int reality;
  const RealityPainter(this.phase,this.rotation,this.tilt,this.accent,this.reality);
  @override void paint(Canvas canvas,Size size){
    final center=Offset(size.width/2,size.height*.50);final scale=math.min(size.width,size.height)*.28;final bg=Offset.zero&size;
    canvas.drawRect(bg,Paint()..shader=RadialGradient(radius:1.1,colors:[accent.withValues(alpha:.12),const Color(0xFF01040A)]).createShader(bg));
    final star=math.Random(100+reality);for(var i=0;i<130;i++){final p=Offset(star.nextDouble()*size.width,star.nextDouble()*size.height);final pulse=.15+.30*((math.sin(phase*math.pi*2+i)+1)/2);canvas.drawCircle(p,.5+star.nextDouble()*1.2,Paint()..color=Colors.white.withValues(alpha:pulse));}
    canvas.save();canvas.translate(center.dx,center.dy);canvas.rotate(rotation*.18+tilt*.08);
    canvas.drawCircle(Offset.zero,scale*1.25,Paint()..color=accent.withValues(alpha:.12)..maskFilter=const MaskFilter.blur(BlurStyle.normal,30));
    canvas.drawCircle(Offset.zero,scale*.62,Paint()..shader=RadialGradient(colors:[Colors.white.withValues(alpha:.92),accent,const Color(0xFF02050A)],stops:const[0,.26,1]).createShader(Rect.fromCircle(center:Offset.zero,radius:scale)));
    for(var ring=0;ring<8;ring++){final r=scale*(.42+ring*.095);final p=Paint()..style=PaintingStyle.stroke..strokeWidth=ring.isEven?1.5:.75..color=accent.withValues(alpha:.20+ring*.035);canvas.save();canvas.rotate(phase*math.pi*2*(ring.isEven?.35:-.24)+ring*.7);canvas.drawOval(Rect.fromCenter(center:Offset.zero,width:r*2,height:r*(.35+.08*math.sin(phase*6+ring))),p);canvas.restore();}
    for(var i=0;i<42;i++){final a=phase*math.pi*2*(.5+i%4*.07)+i*.91;final r=scale*(.70+.32*((i%7)/7));final p=Offset(math.cos(a+rotation)*r,math.sin(a*1.27+tilt)*r*.58);canvas.drawCircle(p,1+(i%3)*.55,Paint()..color=accent.withValues(alpha:.35+(i%4)*.1));}
    for(var i=0;i<6;i++){final a=phase*math.pi*2*(.7+i*.08)+i*1.05;final r=scale*(.82+i*.055);canvas.drawCircle(Offset(math.cos(a)*r,math.sin(a)*r*.42),3,Paint()..color=accent.withValues(alpha:.75));}
    canvas.restore();
  }
  @override bool shouldRepaint(covariant RealityPainter oldDelegate)=>true;
}
