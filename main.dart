import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const LifeOSApp());

class Tx {
  final String id, type, category, note;
  final double amount;
  final DateTime date;
  Tx({required this.id, required this.type, required this.amount,
      required this.category, required this.note, required this.date});

  Map<String,dynamic> toJson()=>{'id':id,'type':type,'amount':amount,
    'category':category,'note':note,'date':date.toIso8601String()};

  factory Tx.fromJson(Map<String,dynamic> j)=>Tx(
    id:j['id'], type:j['type'], amount:(j['amount'] as num).toDouble(),
    category:j['category']??'Other', note:j['note']??'',
    date:DateTime.parse(j['date']));
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});
  @override Widget build(BuildContext c)=>MaterialApp(
    debugShowCheckedModeBanner:false, title:'LifeOS',
    theme:ThemeData(useMaterial3:true,colorSchemeSeed:Colors.indigo),
    home:const Home());
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override State<Home> createState()=>_HomeState();
}

class _HomeState extends State<Home> {
  List<Tx> tx=[]; int tab=0;
  final List<Map<String,String>> goals=[];
  final List<String> tasks=[];

  @override void initState(){super.initState();load();}

  Future<void> load() async {
    final p=await SharedPreferences.getInstance();
    final s=p.getString('tx');
    if(s!=null)setState(()=>tx=(jsonDecode(s) as List)
      .map((x)=>Tx.fromJson(x)).toList());
  }
  Future<void> save() async {
    final p=await SharedPreferences.getInstance();
    await p.setString('tx',jsonEncode(tx.map((x)=>x.toJson()).toList()));
  }

  double get income=>tx.where((x)=>x.type=='income').fold(0,(a,x)=>a+x.amount);
  double get expense=>tx.where((x)=>x.type=='expense').fold(0,(a,x)=>a+x.amount);
  double get balance=>income-expense;

  String insight() {
    if(tx.isEmpty)return 'Add your income and expenses. I will learn your spending pattern and suggest ways to improve it.';
    if(income==0)return 'You have recorded ₹${expense.toStringAsFixed(0)} in expenses. Add income to calculate your savings rate.';
    final groups=<String,double>{};
    for(final x in tx.where((x)=>x.type=='expense'))groups[x.category]=(groups[x.category]??0)+x.amount;
    if(groups.isEmpty)return 'No expenses recorded yet. Your balance is ₹${balance.toStringAsFixed(0)}.';
    final top=groups.entries.reduce((a,b)=>a.value>=b.value?a:b);
    final rate=expense/income*100;
    if(rate>=80)return '⚠️ You have used ${rate.toStringAsFixed(0)}% of recorded income. ${top.key} is your largest expense at ₹${top.value.toStringAsFixed(0)}. Consider setting a limit for this category.';
    if(rate>=50)return '💡 You have spent ${rate.toStringAsFixed(0)}% of recorded income. Your largest category is ${top.key}. Your current balance is ₹${balance.toStringAsFixed(0)}.';
    return '✅ Your recorded spending is ${rate.toStringAsFixed(0)}% of income. Keep tracking consistently. Largest category: ${top.key}.';
  }

  Future<void> addTx(String type) async {
    final amount=TextEditingController(),note=TextEditingController();
    var cat=type=='income'?'Salary':'Food';
    final cats=type=='income'?['Salary','Business','Bonus','Other']:
      ['Food','Fuel','Rent','EMI','Shopping','Bills','Medical','Travel','Other'];
    final ok=await showDialog<bool>(context:context,builder:(_)=>StatefulBuilder(
      builder:(c,setD)=>AlertDialog(title:Text(type=='income'?'Add Income':'Add Expense'),
      content:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:amount,keyboardType:TextInputType.number,
          decoration:const InputDecoration(labelText:'Amount',prefixText:'₹ ')),
        DropdownButtonFormField<String>(value:cat,items:cats.map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),
          onChanged:(x)=>setD(()=>cat=x!),decoration:const InputDecoration(labelText:'Category')),
        TextField(controller:note,decoration:const InputDecoration(labelText:'Note'))]),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancel')),
        FilledButton(onPressed:(){
          final a=double.tryParse(amount.text);
          if(a==null||a<=0)return;
          tx.insert(0,Tx(id:DateTime.now().microsecondsSinceEpoch.toString(),type:type,
            amount:a,category:cat,note:note.text,date:DateTime.now()));
          Navigator.pop(c,true);
        },child:const Text('Save'))])));
    if(ok==true){await save();setState((){});}
  }

  void chat() {
    final q=TextEditingController();
    showDialog(context:context,builder:(_)=>AlertDialog(
      title:const Row(children:[Icon(Icons.auto_awesome),SizedBox(width:8),Text('LifeOS AI')]),
      content:Column(mainAxisSize:MainAxisSize.min,children:[
        Text('I am your LifeOS AI prototype. I can analyze your recorded finances.'),
        const SizedBox(height:12), Text(insight()),
        const SizedBox(height:12), TextField(controller:q,
          decoration:const InputDecoration(labelText:'Ask something',hintText:'How can I save more?'))
      ]),
      actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Close')),
        FilledButton(onPressed:(){
          final answer=answerFor(q.text); Navigator.pop(context);
          showDialog(context:context,builder:(_)=>AlertDialog(title:const Text('LifeOS AI'),content:Text(answer),
            actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('OK'))]));
        },child:const Text('Ask'))]));
  }

  String answerFor(String q){
    final s=q.toLowerCase();
    if(s.contains('save')||s.contains('saving'))
      return income==0?'Add your monthly income first.':
        'Your current recorded balance is ₹${balance.toStringAsFixed(0)}. Start by controlling your largest expense category and set a weekly spending limit.';
    if(s.contains('expense')||s.contains('spend'))
      return insight();
    if(s.contains('balance')||s.contains('money'))
      return 'Your recorded balance is ₹${balance.toStringAsFixed(0)} (income ₹${income.toStringAsFixed(0)} minus expenses ₹${expense.toStringAsFixed(0)}).';
    return 'I can currently help with your income, expenses, balance and saving decisions. Connect the secure AI backend in the next build for full conversational intelligence.';
  }

  @override Widget build(BuildContext c){
    final pages=[dashboard(),transactions(),aiPage()];
    return Scaffold(appBar:AppBar(title:const Text('LifeOS')),
      body:pages[tab],
      floatingActionButton:tab==0?FloatingActionButton.extended(onPressed:()=>addTx('expense'),
        icon:const Icon(Icons.add),label:const Text('Expense')):null,
      bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),
        destinations:const[
          NavigationDestination(icon:Icon(Icons.dashboard_outlined),selectedIcon:Icon(Icons.dashboard),label:'Home'),
          NavigationDestination(icon:Icon(Icons.receipt_long_outlined),selectedIcon:Icon(Icons.receipt_long),label:'Money'),
          NavigationDestination(icon:Icon(Icons.auto_awesome_outlined),selectedIcon:Icon(Icons.auto_awesome),label:'AI')]));
  }

  Widget dashboard()=>ListView(padding:const EdgeInsets.all(16),children:[
    Text('Your LifeOS',style:Theme.of(context).textTheme.headlineMedium),
    const SizedBox(height:4),const Text('One place to understand and improve your life.'),
    const SizedBox(height:16),
    Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('Available balance'),Text('₹${balance.toStringAsFixed(0)}',style:Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height:12),Row(children:[Expanded(child:Text('Income\n₹${income.toStringAsFixed(0)}')),
        Expanded(child:Text('Expenses\n₹${expense.toStringAsFixed(0)}'))])]))),
    const SizedBox(height:12),Row(children:[
      Expanded(child:FilledButton.icon(onPressed:()=>addTx('income'),icon:const Icon(Icons.add),label:const Text('Income'))),
      const SizedBox(width:8),Expanded(child:OutlinedButton.icon(onPressed:()=>addTx('expense'),icon:const Icon(Icons.remove),label:const Text('Expense')))]),
    const SizedBox(height:16),
    Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.auto_awesome)),title:const Text('Today\'s AI insight'),
      subtitle:Text(insight()),trailing:IconButton(onPressed:chat,icon:const Icon(Icons.chat_bubble_outline)))),
    const SizedBox(height:16),Text('Recent',style:Theme.of(context).textTheme.titleLarge),
    ...tx.take(5).map(tile),
    if(tx.isEmpty)const Padding(padding:EdgeInsets.all(24),child:Center(child:Text('No transactions yet.')))
  ]);

  Widget transactions()=>ListView(padding:const EdgeInsets.all(16),children:[
    Text('Money',style:Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height:8),...tx.map(tile),
    if(tx.isEmpty)const Padding(padding:EdgeInsets.all(24),child:Center(child:Text('No transactions yet.')))]);

  Widget aiPage()=>ListView(padding:const EdgeInsets.all(16),children:[
    Text('LifeOS AI',style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:8),
    Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Icon(Icons.auto_awesome,size:40),const SizedBox(height:12),
      Text(insight(),style:Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height:16),FilledButton.icon(onPressed:chat,icon:const Icon(Icons.chat),label:const Text('Ask LifeOS AI'))]))]);

  Widget tile(Tx x)=>Dismissible(key:ValueKey(x.id),onDismissed:(_){tx.remove(x);save();setState((){});},
    child:ListTile(leading:CircleAvatar(child:Icon(x.type=='income'?Icons.add:Icons.remove)),
      title:Text(x.category),subtitle:Text(x.note.isEmpty?'${x.date.day}/${x.date.month}/${x.date.year}':x.note),
      trailing:Text('${x.type=='income'?'+':'-'}₹${x.amount.toStringAsFixed(0)}')));
}
