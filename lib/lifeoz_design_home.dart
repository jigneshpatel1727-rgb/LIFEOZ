import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lifeoz_core_hub.dart';

class LifeOZDesignHome extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZDesignHome({super.key, required this.prefs});
  @override State<LifeOZDesignHome> createState() => _LifeOZDesignHomeState();
}

class _LifeOZDesignHomeState extends State<LifeOZDesignHome> {
  final FlutterTts _tts = FlutterTts();
  String _name = '';
  int _design = 0;
  static const designs = <String>['01_Oreon_Prime.png','02_Terra_Flux.png','03_Vortex_Nexus.png','04_Crysta_Lumen.png','09_Nebula_Soul-1.png','10_Shadow_Core-1.png'];
  static const names = <String>['OREON PRIME','TERRA FLUX','VORTEX NEXUS','CRYSTA LUMEN','NEBULA SOUL','SHADOW CORE'];

  @override void initState(){super.initState();_name=widget.prefs.getString('user_name')??'';_design=(widget.prefs.getInt('lifeoz_reality')??0).clamp(0,5);_tts.setSpeechRate(.44);}
  @override void dispose(){_tts.stop();super.dispose();}
  Future<void> _say(String text)async{await _tts.stop();await _tts.speak(text);}
  void _openCore(int index){const messages=['Growth intelligence is ready.','Care and household intelligence is ready.','Prosperity intelligence is ready.','Time and commitment intelligence is ready.','Personal intelligence is ready.'];_say(messages[index]);Navigator.push(context,MaterialPageRoute(builder:(_)=>LifeOZCoreHub(prefs:widget.prefs,coreIndex:index)));}
  void _controls(){showModalBottomSheet<void>(context:context,backgroundColor:const Color(0xFF050A12),builder:(ctx)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[ListTile(leading:const Icon(Icons.person_outline),title:const Text('Profile'),onTap:(){Navigator.pop(ctx);_profile();}),ListTile(leading:const Icon(Icons.palette_outlined),title:const Text('Design'),onTap:(){Navigator.pop(ctx);_showDesigns();}),const ListTile(leading:Icon(Icons.security_outlined),title:Text('Permissions')),const ListTile(leading:Icon(Icons.settings_outlined),title:Text('Settings'))])));}
  Future<void> _profile()async{final c=TextEditingController(text:_name);final value=await showDialog<String>(context:context,builder:(ctx)=>AlertDialog(backgroundColor:const Color(0xFF050A12),title:const Text('PROFILE'),content:TextField(controller:c,autofocus:true,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Name')),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('CANCEL')),FilledButton(onPressed:()=>Navigator.pop(ctx,c.text.trim()),child:const Text('SAVE'))]));c.dispose();if(value!=null&&value.isNotEmpty){await widget.prefs.setString('user_name',value);if(mounted)setState(()=>_name=value);}}
  void _showDesigns(){showModalBottomSheet<void>(context:context,isScrollControlled:true,backgroundColor:const Color(0xFF02050B),builder:(ctx)=>SafeArea(child:SizedBox(height:MediaQuery.of(ctx).size.height*.90,child:Column(children:[const Padding(padding:EdgeInsets.fromLTRB(16,16,16,8),child:Text('LIFEOZ VISUAL REALITIES',style:TextStyle(letterSpacing:2,fontWeight:FontWeight.w700,fontSize:17))),const Padding(padding:EdgeInsets.only(bottom:10),child:Text('Six separate worlds • Choose one',style:TextStyle(color:Colors.white60,fontSize:12))),Expanded(child:GridView.builder(padding:const EdgeInsets.fromLTRB(12,4,12,20),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:.68),itemCount:designs.length,itemBuilder:(_,i)=>GestureDetector(onTap:()async{await widget.prefs.setInt('lifeoz_reality',i);if(mounted)setState(()=>_design=i);if(ctx.mounted)Navigator.pop(ctx);},child:ClipRRect(borderRadius:BorderRadius.circular(16),child:Stack(fit:StackFit.expand,children:[Image.asset(designs[i],fit:BoxFit.cover),Align(alignment:Alignment.bottomCenter,child:Container(width:double.infinity,padding:const EdgeInsets.symmetric(vertical:10,horizontal:8),color:Colors.black.withOpacity(.60),child:Text(names[i],textAlign:TextAlign.center,style:const TextStyle(letterSpacing:1.5,fontWeight:FontWeight.w700,fontSize:11)))),if(_design==i)Positioned.fill(child:DecoratedBox(decoration:BoxDecoration(border:Border.all(color:Colors.cyanAccent,width:3),borderRadius:BorderRadius.circular(16))))])))))]))));}

  @override Widget build(BuildContext context){return Scaffold(backgroundColor:const Color(0xFF01030A),body:SafeArea(child:Stack(children:[
    Positioned.fill(child:Image.asset(designs[_design],fit:BoxFit.cover,opacity:const AlwaysStoppedAnimation(.10))),
    Positioned.fill(child:Container(color:const Color(0xB901030A))),
    Positioned(top:6,left:12,right:12,height:92,child:Row(children:[Expanded(child:Image.asset('02_LifeOZ_Full_Logo.png',fit:BoxFit.contain,alignment:Alignment.centerLeft)),const SizedBox(width:54)])),
    Positioned(right:18,top:22,width:50,height:50,child:IconButton(onPressed:_controls,icon:const Icon(Icons.tune_rounded,color:Color(0xFFFFB75E),size:31))),
    Positioned(top:118,left:24,right:24,child:Center(child:Text('LIVING INTELLIGENCE',style:TextStyle(color:Colors.white.withOpacity(.72),letterSpacing:3,fontSize:11)))),
    Positioned(left:24,right:24,top:160,bottom:100,child:Column(children:[
      Expanded(child:GestureDetector(onTap:()=>_say('I am Yansi, your silent LifeOS intelligence.'),child:Image.asset('03_Yansi_Silent_Intelligence.png',fit:BoxFit.contain))),
      const SizedBox(height:8),
      Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[_CoreButton(color:const Color(0xFF4FEF83),glyph:Icons.eco_outlined,onTap:()=>_openCore(0)),_CoreButton(color:const Color(0xFFFFB83D),glyph:Icons.auto_graph_rounded,onTap:()=>_openCore(1)),_CoreButton(color:const Color(0xFF42D9FF),glyph:Icons.schedule_rounded,onTap:()=>_openCore(2)),_CoreButton(color:const Color(0xFFC86BFF),glyph:Icons.track_changes_rounded,onTap:()=>_openCore(3)),_CoreButton(color:const Color(0xFFFF5A61),glyph:Icons.favorite_outline_rounded,onTap:()=>_openCore(4))]),
    ])),
    Positioned(bottom:18,left:0,right:0,child:Center(child:Text(_name.isEmpty?'LIVING INTELLIGENCE':'LIVING INTELLIGENCE  •  ${_name.toUpperCase()}',style:const TextStyle(color:Colors.white70,letterSpacing:3,fontSize:11,fontWeight:FontWeight.w600)))),
  ])));}
}

class _CoreButton extends StatelessWidget{final Color color;final IconData glyph;final VoidCallback onTap;const _CoreButton({required this.color,required this.glyph,required this.onTap});@override Widget build(BuildContext context)=>GestureDetector(onTap:onTap,child:Container(width:50,height:50,decoration:BoxDecoration(shape:BoxShape.circle,color:const Color(0xFF030812).withOpacity(.82),border:Border.all(color:color,width:2),boxShadow:[BoxShadow(color:color.withOpacity(.35),blurRadius:18)]),child:Icon(glyph,color:color,size:25)));}
