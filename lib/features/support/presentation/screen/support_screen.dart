import 'package:flutter/material.dart';
import 'package:medinear_app/features/support/presentation/provider/support_provider.dart';
import 'package:medinear_app/features/support/presentation/widgets/support_card.dart';
import 'package:provider/provider.dart';



class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<SupportProvider>(context, listen: false).init(context));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SupportProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Support"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Top Banner
            Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFE0F7FA), Color(0xFFE8F5E9)],
    ),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // 🔥 الصورة (كبرناها)
      Container(
        width: 120,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage("assets/images/image_support.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
      ),

      const SizedBox(width: 50),

      // 🔥 النص
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "How can we \n help you?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Feel free to contact us anytime",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

            const SizedBox(height: 5),

            Expanded(
              child: ListView.builder(
                itemCount: provider.items.length,
                itemBuilder: (context, index) {
                  return SupportCard(item: provider.items[index]);
                },
              ),
            ),

            // Extra static options
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text("Help & FAQs"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text("Feedback"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}