import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'services/yansi_brain.dart';

class LifeOZFutureShell extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZFutureShell({super.key, required this.prefs});
  @override State<LifeOZFutureShell> createState() => _LifeOZFutureShellState();
}

class _LifeOZFutureShellState extends State<LifeOZFutureShell> with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  late final YansiBrain _brain;
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _input = TextEditingController();
  String _name = '', _country = 'India', _currency = 'INR', _language = 'English';
  String _design = 'neural_void', _message = 'Yansi is present.', _transcript = '';
  bool _onboarding = true, _listening = false, _speaking = false, _controls = false;
  int _activeCore = -1;

  static const _designs = <_Reality>[
    _Reality('neural_void','NEURAL VOID','Living neural space',Color(0xFF00F0FF),Color(0xFF00FF9D),0),
    _Reality('quantum_glass','QUANTUM GLASS','Transparent quantum layers',Color(0xFFB48CFF),Color(0xFF44E7FF),1),
    _Reality('holo_prism','HOLO PRISM','Volumetric light geometry',Color(0xFFFF4FD8),Color(0xFF52F7FF),2),
    _Reality('aurora_intelligence','AURORA INTELLIGENCE','Organic adaptive field',Color(0xFFB4FF58),Color(0xFF00E5FF),3),
    _Reality('singularity','SINGULARITY','Deep-space minimalism',Color(0xFFEAF8FF),Color(0xFF4DE7FF),4),
    _Reality('terra_flux','TERRA FLUX','Bio-energy life topology',Color(0xFFFFB15C),Color(0xFF58FFD2),5),
  ];
  static const _coreNames = ['PROSPERITY','MOTION','TIME','HABITAT','ASCENT'];
  static const _coreMeaning = ['Money, income, bills and investments','Work, tasks and execution','Calendar, renewals and commitments','Home, shopping and household','Goals, diary and personal growth'];

  _Reality get _reality => _designs.firstWhere((x) => x.id == _design, orElse: () => _designs.first);

  @override void initState() {
    super.initState();
    _motion = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    _brain = YansiBrain(prefs: widget.prefs);
    _name = widget.prefs.getString('user_name') ?? '';
    _country = widget.prefs.getString('user_country') ?? 'India';
    _currency = widget.prefs.getString('user_currency') ?? 'INR';
    _language = widget.prefs.getString('user_language') ?? 'English';
    _design = widget.prefs.getString('lifeoz_reality') ?? widget.prefs.getString('lifeos_design') ?? 'neural_void';
    _onboarding = widget.prefs.getBool('lifeoz_master_ready') != true;
    _configureVoice();
  }

  Future<void> _configureVoice() async {
    await _tts.setSpeechRate(.44);
    _tts.setStartHandler(() { if (mounted) setState(() => _speaking = true); });
    _tts.setCompletionHandler(() { if (mounted) setState(() => _speaking = false); });
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    await _speech.stop();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _listen() async {
    if (_listening) { await _speech.stop(); if (mounted) setState(() => _listening = false); return; }
    final available = await _speech.initialize(
      onStatus: (s) { if ((s == 'done' || s == 'notListening') && mounted) setState(() => _listening = false); },
      onError: (_) { if (mounted) setState(() => _listening = false); },
    );
    if (!available) { _toast('Microphone permission is required for Yansi.'); return; }
    setState(() { _listening = true; _transcript = ''; });
    await _speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      onResult: (r) { if (!mounted) return; setState(() => _transcript = r.recognizedWords); if (r.finalResult && r.recognizedWords.trim().isNotEmpty) _process(r.recognizedWords); },
    );
  }

  Future<void> _process(String text) async {
    await _speech.stop();
    if (mounted) setState(() => _listening = false);
    final result = await _brain.process(text);
    if (!mounted) return;
    setState(() { _message = result.response; _transcript = ''; });
    await _speak(result.response);
  }

  Future<void> _enter() async {
    if (_name.trim().isEmpty) { _toast('Enter your name so Yansi knows who she is assisting.'); return; }
    await widget.prefs.setString('user_name', _name.trim());
    await widget.prefs.setString('user_country', _country);
    await widget.prefs.setString('user_currency', _currency);
    await widget.prefs.setString('user_language', _language);
    await widget.prefs.setString('lifeoz_reality', _design);
    await widget.prefs.setBool('lifeoz_master_ready', true);
    await widget.prefs.setBool('permission_voice', true);
    if (!mounted) return;
    setState(() => _onboarding = false);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await _speak('Welcome, $_name. I am Yansi. Your life is now connected. Tell me what you need.');
  }

  void _selectReality(String id) { setState(() => _design = id); widget.prefs.setString('lifeoz_reality', id); }
  void _toast(String s) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s))); }

  @override void dispose() { _motion.dispose(); _tts.stop(); _speech.stop(); _input.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFF010207), body: AnimatedBuilder(animation: _motion, builder: (_,__) => _onboarding ? _buildOnboarding() : _buildHome()));

  Widget _buildOnboarding() => Stack(children: [
    _environment(),
    SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(22,30,22,28), child: Column(children: [
      _brandMark(size: 76),
      const SizedBox(height: 16),
      const Text('LIFEOZ', style: TextStyle(fontSize: 32, letterSpacing: 9, fontWeight: FontWeight.w200)),
      const SizedBox(height: 6),
      Text('A LIFE OPERATING SYSTEM', style: TextStyle(fontSize: 9, letterSpacing: 3.2, color: _reality.a.withOpacity(.72))),
      const SizedBox(height: 28),
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _section('IDENTITY FIELD'),
        TextField(onChanged: (v) => _name = v, style: const TextStyle(fontSize: 18), decoration: _inputDecoration('What should Yansi call you?')),
        const SizedBox(height: 18),
        Row(children: [Expanded(child: _selector('LOCATION',_country,['India','United States','United Kingdom','Canada','Australia','Other'],(v)=>setState(()=>_country=v))),const SizedBox(width:12),Expanded(child:_selector('CURRENCY',_currency,['INR','USD','GBP','CAD','AUD','EUR'],(v)=>setState(()=>_currency=v)))]),
        const SizedBox(height: 14),
        _selector('LANGUAGE',_language,['English','Hindi','Gujarati'],(v)=>setState(()=>_language=v)),
      ])),
      const SizedBox(height: 14),
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _section('CHOOSE YOUR REALITY'),
        const SizedBox(height: 10),
        SizedBox(height: 170, child: ListView.separated(scrollDirection: Axis.horizontal,itemCount:_designs.length,separatorBuilder:(_,__)=>const SizedBox(width:10),itemBuilder:(_,i)=>_realityCard(_designs[i]))),
      ])),
      const SizedBox(height: 18),
      _glass(child: Row(children: [Icon(Icons.graphic_eq_rounded,color:_reality.a),const SizedBox(width:12),Expanded(child:Text('Yansi will become the ambient intelligence layer of your LifeOS.',style:TextStyle(fontSize:11,height:1.45,color:Colors.white.withOpacity(.64))))])),
      const SizedBox(height: 22),
      _primary('ENTER THE LIFEOZ FIELD',_enter),
    ]))),
  ]);

  Widget _buildHome() => Stack(children: [
    _environment(),
    SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(18,10,18,0), child: Row(children: [
        _controlNode(), const Spacer(), Column(children:[const Text('LIFEOZ',style:TextStyle(fontSize:13,letterSpacing:5,fontWeight:FontWeight.w700)),Text(_name.toUpperCase(),style:TextStyle(fontSize:7,letterSpacing:2,color:_reality.a.withOpacity(.6)))]), const Spacer(), _voiceNode(),
      ])),
      Expanded(child: LayoutBuilder(builder: (_,c)=>SingleChildScrollView(padding:const EdgeInsets.fromLTRB(16,4,16,24),child:Column(children:[
        SizedBox(height: math.min(310,c.maxHeight*.46),child:Center(child:GestureDetector(onTap:_listen,child:_yansi()))),
        AnimatedSwitcher(duration:const Duration(milliseconds:260),child:Text(_transcript.isNotEmpty?_transcript:_message,key:ValueKey(_transcript.isNotEmpty?_transcript:_message),textAlign:TextAlign.center,style:TextStyle(fontSize:13,height:1.5,color:Colors.white.withOpacity(.78)))),
        const SizedBox(height:12),
        _constellation(),
        const SizedBox(height:14),
        _commandField(),
      ]))),
    ])),
    if (_controls) _controlField(),
  ]);

  Widget _environment() => Positioned.fill(child: CustomPaint(painter:_EnvironmentPainter(_reality,_motion.value)));

  Widget _brandMark({double size=58}) => SizedBox(width:size,height:size,child:CustomPaint(painter:_BrandPainter(_reality.a,_reality.b)));

  Widget _controlNode() => GestureDetector(onTap:()=>setState(()=>_controls=true),child:Container(width:42,height:42,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:_reality.a.withOpacity(.45)),boxShadow:[BoxShadow(color:_reality.a.withOpacity(.15),blurRadius:18)]),child:CustomPaint(painter:_ControlGlyphPainter(_reality.a))));
  Widget _voiceNode() => GestureDetector(onTap:_listen,child:Container(width:42,height:42,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:_reality.b.withOpacity(.5)),boxShadow:[BoxShadow(color:_reality.b.withOpacity(_listening?.28:.12),blurRadius:18)]),child:Icon(_listening?Icons.graphic_eq_rounded:Icons.mic_none_rounded,color:_reality.b,size:19)));

  Widget _yansi() => SizedBox(width:250,height:250,child:CustomPaint(painter:_YansiPainter(_reality,_motion.value,_listening,_speaking)));

  Widget _constellation() => SizedBox(height:205,width:350,child:Stack(alignment:Alignment.center,children:[CustomPaint(size:const Size(340,205),painter:_ConstellationPainter(_reality,_motion.value)),...List.generate(5,(i){final a=-math.pi/2+i*2*math.pi/5;return Transform.translate(offset:Offset(math.cos(a)*116,math.sin(a)*78),child:GestureDetector(onTap:(){setState(()=>_activeCore=i);_speak(_coreMeaning[i]);},child:_glyph(i, _activeCore==i)));}),_brandMark(size:70)]));

  Widget _glyph(int i,bool active)=>Container(width:60,height:60,decoration:BoxDecoration(shape:BoxShape.circle,color:const Color(0xCC050912),border:Border.all(color:(active?_reality.b:_reality.a).withOpacity(.72),width:active?2:1),boxShadow:[BoxShadow(color:_reality.a.withOpacity(active?.25:.09),blurRadius:24)]),child:CustomPaint(painter:_CoreGlyphPainter(i,active?_reality.b:_reality.a)));

  Widget _commandField()=>_glass(child:Row(children:[Icon(Icons.auto_awesome_rounded,color:_reality.a,size:19),const SizedBox(width:10),Expanded(child:TextField(controller:_input,onSubmitted:_process,style:const TextStyle(fontSize:12),decoration:const InputDecoration(hintText:'Speak to Yansi…',hintStyle:TextStyle(color:Colors.white30),border:InputBorder.none))),IconButton(onPressed:_listen,icon:Icon(Icons.mic_none_rounded,color:_reality.b))]));

  Widget _controlField()=>Positioned.fill(child:GestureDetector(onTap:()=>setState(()=>_controls=false),child:Container(color:Colors.black.withOpacity(.72),child:Center(child:GestureDetector(onTap:(){},child:Container(width:330,padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:const Color(0xF0070B14),borderRadius:BorderRadius.circular(28),border:Border.all(color:_reality.a.withOpacity(.25)),boxShadow:[BoxShadow(color:_reality.a.withOpacity(.12),blurRadius:50)]),child:Column(mainAxisSize:MainAxisSize.min,children:[_brandMark(size:58),const SizedBox(height:12),Text('CONTROL FIELD',style:TextStyle(letterSpacing:3,color:_reality.a,fontSize:13)),const SizedBox(height:20),_controlAction('REALITY',Icons.blur_on_rounded,()=>_showRealities()),_controlAction('IDENTITY',Icons.person_outline_rounded,()=>_showInfo('IDENTITY',['Name: $_name','Location: $_country','Currency: $_currency','Language: $_language'])),_controlAction('PERMISSIONS',Icons.shield_outlined,()=>_showInfo('PERMISSIONS',['Voice: enabled by profile','Background AI: controlled','Web access: permission controlled'])),_controlAction('YANSI',Icons.auto_awesome_rounded,()=>_speak('I am Yansi. I connect the information you allow me to access and turn it into useful intelligence.'))]))))));

  Widget _controlAction(String t,IconData icon,VoidCallback fn)=>ListTile(onTap:fn,contentPadding:EdgeInsets.zero,leading:Icon(icon,color:_reality.a),title:Text(t,style:const TextStyle(fontSize:11,letterSpacing:1.8)),trailing:Icon(Icons.arrow_forward_ios_rounded,size:12,color:Colors.white30));

  void _showRealities()=>showModalBottomSheet(context:context,backgroundColor:const Color(0xFF05080E),isScrollControlled:true,builder:(_)=>SafeArea(child:Padding(padding:const EdgeInsets.all(18),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text('CHOOSE YOUR REALITY',style:TextStyle(color:_reality.a,fontSize:17,letterSpacing:2)),const SizedBox(height:14),SizedBox(height:190,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:_designs.length,separatorBuilder:(_,__)=>const SizedBox(width:10),itemBuilder:(_,i)=>_realityCard(_designs[i])))]))));
  void _showInfo(String title,List<String> lines)=>showModalBottomSheet(context:context,backgroundColor:const Color(0xFF060A12),builder:(_)=>Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(color:_reality.a,letterSpacing:2)),const SizedBox(height:15),...lines.map((x)=>Padding(padding:const EdgeInsets.only(bottom:10),child:Text(x,style:const TextStyle(color:Colors.white70))))]));

  Widget _realityCard(_Reality r)=>GestureDetector(onTap:(){_selectReality(r.id);Navigator.of(context).maybePop();},child:AnimatedContainer(duration:const Duration(milliseconds:220),width:155,padding:const EdgeInsets.all(12),decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),border:Border.all(color:_design==r.id?r.a:Colors.white.withOpacity(.08),width:_design==r.id?2:1),gradient:LinearGradient(colors:[r.a.withOpacity(.16),const Color(0xFF05070D)],begin:Alignment.topLeft,end:Alignment.bottomRight)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:CustomPaint(painter:_RealityPreviewPainter(r))),Text(r.name,style:TextStyle(color:r.a,fontSize:9,letterSpacing:1.1,fontWeight:FontWeight.bold)),const SizedBox(height:3),Text(r.subtitle,style:const TextStyle(color:Colors.white38,fontSize:8))]));

  Widget _section(String t)=>Text(t,style:TextStyle(color:_reality.a.withOpacity(.72),fontSize:9,letterSpacing:2));
  Widget _glass({required Widget child})=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white.withOpacity(.035),borderRadius:BorderRadius.circular(24),border:Border.all(color:_reality.a.withOpacity(.13)),boxShadow:[BoxShadow(color:_reality.a.withOpacity(.035),blurRadius:30)]),child:child);
  InputDecoration _inputDecoration(String h)=>InputDecoration(hintText:h,hintStyle:const TextStyle(color:Colors.white30),enabledBorder:UnderlineInputBorder(borderSide:BorderSide(color:Colors.white12)),focusedBorder:UnderlineInputBorder(borderSide:BorderSide(color:Colors.white38)),border:InputBorder.none);
  Widget _selector(String label,String value,List<String> values,ValueChanged<String> fn)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(color:Colors.white30,fontSize:8,letterSpacing:1.4)),DropdownButton<String>(value:values.contains(value)?value:values.first,isExpanded:true,underline:const SizedBox(),dropdownColor:const Color(0xFF101620),items:values.map((x)=>DropdownMenuItem(value:x,child:Text(x,style:const TextStyle(fontSize:12)))).toList(),onChanged:(v){if(v!=null)fn(v);})]);
  Widget _primary(String text,VoidCallback fn)=>GestureDetector(onTap:fn,child:Container(width:double.infinity,padding:const EdgeInsets.symmetric(vertical:16),decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),gradient:LinearGradient(colors:[_reality.a.withOpacity(.28),_reality.b.withOpacity(.12)]),border:Border.all(color:_reality.a.withOpacity(.35))),child:Center(child:Text(text,style:TextStyle(color:_reality.a,fontSize:10,letterSpacing:2.2,fontWeight:FontWeight.w700))));
}

class _Reality { final String id,name,subtitle; final Color a,b; final int mode; const _Reality(this.id,this.name,this.subtitle,this.a,this.b,this.mode); }

class _EnvironmentPainter extends CustomPainter { final _Reality r; final double t; _EnvironmentPainter(this.r,this.t); @override void paint(Canvas c,Size s){final p=Paint();p.shader=RadialGradient(colors:[r.a.withOpacity(.08),const Color(0x00000000)],stops:const[0,.7]).createShader(Rect.fromCircle(center:Offset(s.width*.5,s.height*.38),radius:s.width*.8));c.drawRect(Offset.zero& s,p);final line=Paint()..style=PaintingStyle.stroke..strokeWidth=.45..color=r.a.withOpacity(.07);for(int i=0;i<18;i++){final y=(i*s.height/18+(t*s.height))%s.height;c.drawLine(Offset(0,y),Offset(s.width,y),line);}final dots=Paint()..color=r.b.withOpacity(.16);for(int i=0;i<55;i++){final x=(math.sin(i*17.3)*.5+.5)*s.width;final y=(math.cos(i*9.7)*.5+.5)*s.height;c.drawCircle(Offset(x,y),1.1,dots);}}@override bool shouldRepaint(covariant _EnvironmentPainter old)=>true; }

class _YansiPainter extends CustomPainter { final _Reality r; final double t; final bool listening,speaking; _YansiPainter(this.r,this.t,this.listening,this.speaking); @override void paint(Canvas c,Size s){final center=s.center;for(int k=0;k<5;k++){final radius=55+k*16+math.sin(t*math.pi*2+k)*4;final p=Paint()..style=PaintingStyle.stroke..strokeWidth=1.2..color=(k.isEven?r.a:r.b).withOpacity(.16+(listening?.12:0));c.drawCircle(center,radius,p);}final glow=Paint()..shader=RadialGradient(colors:[r.a.withOpacity(.35),r.b.withOpacity(.12),const Color(0x00000000)]).createShader(Rect.fromCircle(center:center,radius:92));c.drawCircle(center,92,glow);final core=Paint()..shader=RadialGradient(colors:[Colors.white.withOpacity(.95),r.a.withOpacity(.7),r.b.withOpacity(.15)]).createShader(Rect.fromCircle(center:center,radius:38));c.drawCircle(center,38,core);final nodes=Paint()..color=r.b.withOpacity(.75);for(int i=0;i<18;i++){final a=t*math.pi*2+i*math.pi/9;final rr=48+12*math.sin(i);c.drawCircle(center+Offset(math.cos(a)*rr,math.sin(a)*rr),1.8,nodes);}if(speaking||listening){final ring=Paint()..style=PaintingStyle.stroke..strokeWidth=2..color=(speaking?r.b:r.a).withOpacity(.55);c.drawCircle(center,100+8*math.sin(t*math.pi*4),ring);}}@override bool shouldRepaint(covariant _YansiPainter old)=>true; }

class _ConstellationPainter extends CustomPainter { final _Reality r; final double t; _ConstellationPainter(this.r,this.t); @override void paint(Canvas c,Size s){final center=s.center;final p=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=r.a.withOpacity(.18);for(int i=0;i<5;i++){final a=-math.pi/2+i*2*math.pi/5;final end=center+Offset(math.cos(a)*116,math.sin(a)*78);c.drawLine(center,end,p);}for(int i=0;i<5;i++){final a=-math.pi/2+i*2*math.pi/5;final p1=center+Offset(math.cos(a)*116,math.sin(a)*78);final a2=-math.pi/2+((i+1)%5)*2*math.pi/5;final p2=center+Offset(math.cos(a2)*116,math.sin(a2)*78);c.drawLine(p1,p2,Paint()..color=r.b.withOpacity(.08)..strokeWidth=.8);}}@override bool shouldRepaint(covariant _ConstellationPainter old)=>true; }

class _RealityPreviewPainter extends CustomPainter { final _Reality r; _RealityPreviewPainter(this.r); @override void paint(Canvas c,Size s){final center=s.center;final p=Paint()..style=PaintingStyle.stroke;for(int i=0;i<4;i++){p.color=(i.isEven?r.a:r.b).withOpacity(.2);p.strokeWidth=1.2;c.drawCircle(center,18+i*13,p);}final dot=Paint()..color=r.a.withOpacity(.7);for(int i=0;i<9;i++){final a=i*math.pi*2/9;c.drawCircle(center+Offset(math.cos(a)*48,math.sin(a)*34),2,dot);}}@override bool shouldRepaint(covariant _RealityPreviewPainter old)=>false; }

class _BrandPainter extends CustomPainter { final Color a,b; _BrandPainter(this.a,this.b); @override void paint(Canvas c,Size s){final p=Paint()..style=PaintingStyle.stroke..strokeWidth=3..strokeCap=StrokeCap.round..shader=LinearGradient(colors:[a,b]).createShader(Offset.zero&s);final cx=s.width/2,cy=s.height/2;final path=Path();path.moveTo(cx-25,cy);path.cubicTo(cx-17,cy-20,cx-2,cy-20,cx,cy);path.cubicTo(cx+2,cy+20,cx+17,cy+20,cx+25,cy);path.cubicTo(cx+17,cy+20,cx+2,cy+20,cx,cy);path.cubicTo(cx-2,cy-20,cx-17,cy-20,cx-25,cy);c.drawPath(path,p);c.drawCircle(Offset(cx,cy),4,Paint()..color=b.withOpacity(.8));} @override bool shouldRepaint(covariant _BrandPainter old)=>old.a!=a||old.b!=b; }

class _ControlGlyphPainter extends CustomPainter { final Color color; _ControlGlyphPainter(this.color); @override void paint(Canvas c,Size s){final p=Paint()..style=PaintingStyle.stroke..strokeWidth=1.5..color=color;final x=s.width/2,y=s.height/2;c.drawCircle(Offset(x,y),12,p);for(int i=0;i<4;i++){final a=i*math.pi/2;c.drawLine(Offset(x+math.cos(a)*15,y+math.sin(a)*15),Offset(x+math.cos(a)*19,y+math.sin(a)*19),p);}}@override bool shouldRepaint(covariant _ControlGlyphPainter old)=>old.color!=color; }

class _CoreGlyphPainter extends CustomPainter { final int i; final Color color; _CoreGlyphPainter(this.i,this.color); @override void paint(Canvas c,Size s){final p=Paint()..style=PaintingStyle.stroke..strokeWidth=2..color=color;final cx=s.width/2,cy=s.height/2;switch(i){case 0: c.drawCircle(Offset(cx,cy),12,p);c.drawArc(Rect.fromCircle(center:Offset(cx,cy),radius:16),-1,2.1,false,p);break;case 1: c.drawPath(Path()..moveTo(cx-12,cy+8)..lineTo(cx-3,cy-12)..lineTo(cx+2,cy-2)..lineTo(cx+13,cy-8),p);break;case 2: c.drawCircle(Offset(cx,cy),12,p);c.drawLine(Offset(cx,cy-12),Offset(cx,cy+12),p);c.drawLine(Offset(cx-12,cy),Offset(cx+12,cy),p);break;case 3: c.drawArc(Rect.fromCircle(center:Offset(cx,cy),radius:13),.3,4.9,false,p);c.drawCircle(Offset(cx,cy),4,p);break;default: c.drawPath(Path()..moveTo(cx-13,cy+9)..lineTo(cx-3,cy-3)..lineTo(cx+4,cy+3)..lineTo(cx+14,cy-11),p);c.drawCircle(Offset(cx+14,cy-11),2,p);}}@override bool shouldRepaint(covariant _CoreGlyphPainter old)=>old.i!=i||old.color!=color; }
