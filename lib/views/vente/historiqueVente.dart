import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sales_provider.dart';

class Historiquevente extends ConsumerStatefulWidget {
  const Historiquevente({super.key});

  @override
  ConsumerState<Historiquevente> createState() => _HistoriqueventeState();
}

class _HistoriqueventeState extends ConsumerState<Historiquevente> {
  SearchController _searchController = SearchController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: Text('Historique de vente', style: TextStyle( fontWeight: FontWeight.bold),),
      ),
      body: Column(
        children: [
          Container(
            // child: SearchAnchor(
            //   searchController: _searchController,
            //     builder:(context, controller ){
            //      return SearchBar(
            //        controller: controller,
            //        hintText: 'Rechercher un historique',
            //        leading: const Icon(
            //          Icons.search,
            //          size: 20,
            //          color: Color(0xFF6F7B80),
            //        ),
            //        elevation: const WidgetStatePropertyAll(0),
            //        backgroundColor: const WidgetStatePropertyAll(
            //          Colors.white,
            //        ),
            //        padding: const WidgetStatePropertyAll(
            //          EdgeInsets.symmetric(horizontal: 16),
            //        ),
            //        onTap: () {
            //          controller.openView();
            //        },
            //        onChanged: (text) {
            //          // _onSearchChanged(text);
            //          controller.openView();
            //        },
            //
            //        trailing: [
            //          controller.text.isNotEmpty
            //              ? IconButton(
            //            icon: const Icon(
            //              Icons.clear,
            //              size: 20,
            //              color: Colors.grey,
            //            ),
            //            onPressed: () {
            //              controller.clear();
            //              // _onSearchChanged('');
            //            },
            //          )
            //              : IconButton(
            //            icon: Icon(Icons.qr_code_2),
            //            onPressed: () {
            //              // _scanBarcode();
            //            },
            //          ),
            //        ],
            //      );
            //
            // }, suggestionsBuilder:(context, controller) async {
            //   final query = controller.text;
            //   final repository = ref.read(salesRepositoryProvider);
            //   // final results = await repository.(
            //   //   searchQuery: query,
            //   // );
            //   return null;
            // }),
          )
        ],
      ),
    );
  }
}
