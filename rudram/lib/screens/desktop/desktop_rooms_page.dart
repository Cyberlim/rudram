import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../widgets/desktop/desktop_header.dart';
import '../../widgets/desktop/desktop_footer_section.dart';
import '../../providers/rooms_provider.dart';
import 'desktop_room_detail_page.dart';

class DesktopRoomsPage extends StatefulWidget {
  const DesktopRoomsPage({super.key});

  @override
  State<DesktopRoomsPage> createState() => _DesktopRoomsPageState();
}

class _DesktopRoomsPageState extends State<DesktopRoomsPage> {
  static const Color goldColor = Color(0xFFD4AF37);
  static const Color lightBg = Colors.white;
  static const Color panelBg = Color(0xFFF9F9F9);

  void _showCreateRoomDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          "CREATE NEW ROOM",
          style: GoogleFonts.outfit(
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "Room Name (e.g. Dream Wedding)",
            hintStyle: const TextStyle(color: Colors.black26),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: goldColor.withOpacity(0.3)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: goldColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CANCEL",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: goldColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<RoomsProvider>().addRoom(
                  nameController.text,
                  "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/bc/62/77/bc627798725bb482061030e2003c2602.jpg",
                );
                Navigator.pop(context);
              }
            },
            child: Text(
              "CREATE",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const DesktopHeader(isDark: false),
            _buildHero(),
            _buildRoomGrid(),
            const DesktopFooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      height: 450,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/ce/6b/3b/ce6b3bd1dedc99a22b6c4df7e000de09.jpg",
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.5),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "THE VIRTUAL SHOWROOM",
                style: GoogleFonts.outfit(
                  color: goldColor,
                  letterSpacing: 8,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Curate Your Luxury",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _showCreateRoomDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text("CREATE NEW ROOM"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  foregroundColor: Colors.black,
                  elevation: 10,
                  shadowColor: Colors.black45,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomGrid() {
    return Consumer<RoomsProvider>(
      builder: (context, provider, child) {
        final rooms = provider.rooms;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 100),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 40,
              mainAxisSpacing: 60,
              childAspectRatio: 0.85,
            ),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DesktopRoomDetailPage(room: room),
                    ),
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: panelBg,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(room.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 20,
                                right: 20,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "${room.products.length}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            room.name.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: Colors.black87,
                              fontSize: 18,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: goldColor,
                            size: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(width: 40, height: 2, color: goldColor),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
