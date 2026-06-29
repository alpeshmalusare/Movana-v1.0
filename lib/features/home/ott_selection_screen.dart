import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/movana_theme.dart';

class OttPlatform {
  const OttPlatform(this.name, this.logoUrl, this.providerId);
  final String name;
  final String logoUrl;
  final int providerId;
}

const ottPlatforms = [
  OttPlatform('Netflix', 'https://image.tmdb.org/t/p/w300/pbpMk2JmcoNnQwx5JGpXngfoWtp.jpg', 8),
  OttPlatform('Prime Video', 'https://image.tmdb.org/t/p/w300/pvske1MyAoymrs5bguRfVqYiM9a.jpg', 119),
  OttPlatform('JioHotstar', 'https://image.tmdb.org/t/p/w300/kVqjgpcwvDJOhCupjcLzwwtOp52.jpg', 2336),
  OttPlatform('Sony LIV', 'https://image.tmdb.org/t/p/w300/3973zlBbBXdXxaWqRWzGG2GYxbT.jpg', 237),
  OttPlatform('ZEE5', 'https://image.tmdb.org/t/p/w300/gP67NRy1ShUJilrzMsbOmEmdmcv.jpg', 232),
  OttPlatform('Apple TV+', 'https://image.tmdb.org/t/p/w300/mcbz1LgtErU9p4UdbZ0rG6RTWHX.jpg', 350),
  OttPlatform('MX Player', 'https://image.tmdb.org/t/p/w300/ayHY6wKxvCKj2PU8eRPFxnPc6B0.jpg', 515),
  OttPlatform('Aha', 'https://image.tmdb.org/t/p/w300/8WerMI8XcZXqPpkHTZNtzMzousF.jpg', 532),
  OttPlatform('Sun NXT', 'https://image.tmdb.org/t/p/w300/6KEQzITx2RrCAQt5Nw9WrL1OI8z.jpg', 309),
];

class OttSelectionScreen extends StatelessWidget {
  const OttSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 42, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose your\nOTT Platform', key: ValueKey('ott-title'), style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, height: 1.05)),
              const SizedBox(height: 10),
              const Text('Select your preferred platform to browse content.', key: ValueKey('ott-subtitle'), style: TextStyle(color: MovanaColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 28),
              Expanded(
                child: GridView.builder(
                  key: const ValueKey('ott-platform-grid'),
                  itemCount: ottPlatforms.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 22, mainAxisSpacing: 22),
                  itemBuilder: (context, index) {
                    final platform = ottPlatforms[index];
                    return InkWell(
                      key: ValueKey('ott-platform-${platform.name}'),
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => context.push('/platform-home', extra: {'name': platform.name, 'providerId': '${platform.providerId}'}),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: MovanaColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: MovanaColors.divider), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.25), blurRadius: 22, offset: const Offset(0, 10))]),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Expanded(child: Center(child: Image.network(platform.logoUrl, key: ValueKey('ott-logo-${platform.name}'), fit: BoxFit.contain))),
                          const SizedBox(height: 10),
                          Text(platform.name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              const Center(child: Text('You can change this later.', style: TextStyle(color: MovanaColors.textSecondary))),
            ],
          ),
        ),
      ),
    );
  }
}