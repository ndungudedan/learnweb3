import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _mood;
  final TextEditingController _controller = TextEditingController();

  //Used to make network calls by the Web3 dart library
   Client httpClient=Client();

   //Web3 class that sends the request to the Ethereum network
  late Web3Client web3Client;
  final metamaskAddress = 'Inpu your met';

  @override
  void initState() {
    web3Client = Web3Client(
        'https://ropsten.infura.io/v3/654ba9a3f7114a369db1f35dafa89e51',
        httpClient);
    geMood(metamaskAddress);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(child: Text(_mood ?? 'No Mood Yet')),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      fillColor: Colors.grey,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor,width: 2),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5)))),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      var res =await submit('setMood', [_controller.text]);
                      print(res);
                      geMood(metamaskAddress);
                    },
                    icon: const Icon(Icons.send))
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString('assets/abi.json');
    String contractAddress = '0x4BCD3c94C280BAC243D01E769e367121CA0aF0f6';
    final contract = DeployedContract(ContractAbi.fromJson(abi, 'MoodDiary'),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await web3Client.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credential = EthPrivateKey.fromHex(
        '64d7cee1bb17318621e79706341cc31017fffef0f0f7b7923ed8ce7d2cae1480');
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await web3Client.sendTransaction(
        credential,
        Transaction.callContract(
          contract: contract,
          function: ethFunction,
          parameters: args,
        ),
        chainId: 3);
    return result;
  }

  Future<void> geMood(var address) async {
    List<dynamic> res = await query('getMood', []);
    print(res);
    res.forEach((element) {
      _mood = element;
    });
    setState(() {});
  }
}
