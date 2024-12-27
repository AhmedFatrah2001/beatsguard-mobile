import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:beatsguard/components/custom_app_bar.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "BeatsGuard"),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Lottie.network(
              'https://lottie.host/20c7c60d-145b-4e73-9a1e-4e339cbbc25c/0Va7mLVCPX.json',
              height: 300,
              width: 300,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome to BeatsGuard!",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "BeatsGuard is your companion for health and safety. Monitor vital metrics and stay connected.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "How it works:",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      // Wrap the buildInfoCardList in a SizedBox to give it a fixed height
                      SizedBox(
                        height: 400, // Set a fixed height for the swiper
                        child: buildInfoCardList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Chat with Our Health Assistant:",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(
                      Icons.chat_bubble_outline,
                      size: 50,
                      color: Colors.teal,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Get instant answers to your medical questions with our AI-powered chatbot. Available 24/7.",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCardList() {
    // Define the card data
    List<Map<String, String>> cardData = [
      {
        'title': "Pair Your Device",
        'description': "Connect your BeatsGuard Device via Bluetooth.",
        'lottieUrl':
            'https://lottie.host/d2b3998e-3c90-4ba4-a93a-82fdb2c697a9/dY4Qxwh0F5.json',
      },
      {
        'title': "Monitor Your Vitals",
        'description': "Track BPM, SpO2, and temperature in real-time.",
        'lottieUrl':
            'https://lottie.host/a910070d-c495-4271-b981-657091e71a5a/HMEr9JAgLh.json',
      },
      {
        'title': "Get Alerts",
        'description':
            "Receive notifications for abnormal readings and emergencies.",
        'lottieUrl':
            'https://lottie.host/dff89271-816c-4748-aa73-0a9dbaf7a981/a2BkffeSkU.json',
      },
    ];

    // Create a list of cards based on the data
    List<Widget> cards = cardData.map((data) {
      return Container(
        alignment: Alignment.center,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: const Color.fromARGB(255, 245, 248, 255),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.network(
                  data['lottieUrl']!,
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 10),
                Text(
                  data['title']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  data['description']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();

    // Return CardSwiper to display the cards in a swiper
    return CardSwiper(
      cardsCount: cards.length,
      cardBuilder: (context, index, percentThresholdX, percentThresholdY) =>
          cards[index],
    );
  }
}
