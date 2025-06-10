import 'package:flutter/material.dart';
import 'package:posyandu_cempaka2/models/kartu_keluarga.dart';
import 'package:posyandu_cempaka2/services/kartu_keluarga_service.dart';
import 'package:posyandu_cempaka2/views/home/add_form_stepper.dart';
import 'detailed_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<KartuKeluarga> dataKk = [];
  bool isLoading = false;

  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final kkList = await KartuKeluargaService.fetchKartuKeluarga();
      setState(() {
        dataKk = kkList;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

   _deleteData(kkId) async {
    try {
      await KartuKeluargaService.deleteKK(kkId);
      fetchData();
    } catch (e) {
      print('Cannot Delete: $e');
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menghapus data: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Card
              Card(
                color: Colors.white,
                elevation: 1.1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 40, color: Colors.purple),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Admin',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text('ID: 123456789'),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Action detail
                        },
                        child: const Text('Detail Profile'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Action filter
                    },
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 1,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                      ),
                      onChanged: (value) {
                        // Action search
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              isLoading
                  ? const CircularProgressIndicator()
                  : Expanded(
                    child: ListView.builder(
                      itemCount: dataKk.length,
                      itemBuilder: (context, index) {
                        final kk = dataKk[index];
                        final kepala =
                            kk.kepalaKeluarga?.nama ??
                            "Tidak ada Kepala Keluarga";
                        final jumlah = kk.anggota.length;

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailKKPage(kk: kk),
                              ),
                            ).then((value) {
                              fetchData();
                            });
                          },

                          child: Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${index + 1}.",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Row untuk No KK dan ikon
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Teks No KK
                                            Expanded(
                                              child: Text(
                                                "No KK: ${kk.nomorKK}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            // Ikon Edit dan Delete
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.green,
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => AddKKForm(existingKK: kk),
                                                  ),
                                                ).then((value) {
                                                  fetchData();
                                                });
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context, 
                                                  builder: (BuildContext context){
                                                    return AlertDialog(
                                                      title: const Text("Konfirmasi"),
                                                      content: const Text("Apakah anda yakin ingin menghapus data ini?"),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child : const Text("Batal"),
                                                          onPressed: (){
                                                            Navigator.of(context).pop();
                                                          },
                                                          ),
                                                          TextButton(
                                                            child: const Text("Hapus"),
                                                            onPressed: (){
                                                              _deleteData(kk.id);
                                                              Navigator.of(context).pop();
                                                            },
                                                          )
                                                      ],
                                                    );

                                                  }     );            
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text("Kepala Keluarga: $kepala"),
                                        Text("Jumlah anggota: $jumlah"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            ],
          ),
        );
      case 1:
        return const Center(child: Text("Halaman Bumil"));
      case 2:
        return const Center(child: Text("Halaman Balita"));
      default:
        return const Center(child: Text("Halaman Tidak Dikenal"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dasawisma',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        leadingWidth: 70,
        titleSpacing: 8,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 4, right: 0, bottom: 4),
          width: 70,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xfffffffff),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset('assets/LOGO ELSIMIL.png'),
        ),
        actions:
            _selectedIndex == 0
                ? [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddKKForm()),
                      ).then((value) {
                        fetchData();
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                ]
                : null,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pregnant_woman),
            label: 'Bumil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Balita',
          ),
        ],
      ),
    );
  }
}
