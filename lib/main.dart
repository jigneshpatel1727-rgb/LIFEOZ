import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/currency_option.dart';
import 'models/user_profile.dart';
import 'screens/hyper_futuristic_home_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'services/profile_setup_service.dart';
import 'services/user_profile_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(LifeOS(prefs: prefs));
}

class LifeOS extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOS({super.key, required this.prefs});
  @override State<LifeOS> createState() => _LifeOSState();
}

class _LifeOSState extends State<LifeOS> {
  UserProfile? _profile;
  bool _loading = true;
  UserProfileService get _profiles => UserProfileService(widget.prefs);

  @override void initState(){super.initState();_loadProfile();}

  Future<void> _loadProfile() async {
    var profile=_profiles.load();
    if(profile==null){
      final name=widget.prefs.getString('user_name')?.trim()??'';
      if(name.isNotEmpty){
        final symbol=widget.prefs.getString('currency')??'₹';
        final currency=lifeOsCurrencies.firstWhere((item)=>item.symbol==symbol,orElse:()=>lifeOsCurrencies.first);
        profile=UserProfile(fullName:name,phoneNumber:widget.prefs.getString('phone_number')??'',email:widget.prefs.getString('email')??'',country:widget.prefs.getString('country')??'India',currencyCode:currency.code,currencySymbol:currency.symbol,currencyName:currency.name,language:widget.prefs.getString('language')??'English',themeIndex:widget.prefs.getInt('theme_index')??0);
        await _profiles.save(profile);
      }
    }
    if(!mounted)return;setState((){_profile=profile;_loading=false;});
  }
  Future<void> _profileSaved() async{final p=_profiles.load();if(mounted)setState(()=>_profile=p);}
  Future<void> _changeTheme(int index) async{final p=_profile;if(p==null)return;await _profiles.save(p.copyWith(themeIndex:index));if(mounted)setState(()=>_profile=_profiles.load());}

  @override Widget build(BuildContext context){
    if(_loading)return const MaterialApp(debugShowCheckedModeBanner:false,home:Scaffold(backgroundColor:Color(0xFF01050A),body:Center(child:CircularProgressIndicator())));
    final profile=_profile;
    if(profile==null)return MaterialApp(debugShowCheckedModeBanner:false,title:'LIFEOZ',theme:ThemeData.dark(useMaterial3:true),home:ProfileSetupScreen(service:ProfileSetupService(widget.prefs),onSaved:_profileSaved));
    return MaterialApp(debugShowCheckedModeBanner:false,title:'LIFEOZ',theme:ThemeData(brightness:Brightness.dark,useMaterial3:true,scaffoldBackgroundColor:const Color(0xFF01050A)),home:HyperFuturisticHomeScreen(prefs:widget.prefs,userName:profile.fullName,country:profile.country,currency:profile.currencySymbol,themeIndex:profile.themeIndex,onThemeChanged:_changeTheme));
  }
}
