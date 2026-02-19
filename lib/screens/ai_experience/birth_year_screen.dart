import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/experience_state.dart';
import '../../widgets/gradient_button.dart';

class BirthYearScreen extends StatefulWidget {
  const BirthYearScreen({super.key});

  @override
  State<BirthYearScreen> createState() => _BirthYearScreenState();
}

class _BirthYearScreenState extends State<BirthYearScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<ExperienceState>().birthYear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid {
    final year = int.tryParse(_controller.text);
    if (year == null) return false;
    final currentYear = DateTime.now().year;
    return year >= 1920 && year <= currentYear - 5;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExperienceState>();
    final l10n = state.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1D3E)),
          onPressed: () => state.setAiStep(2),
        ),
        title: Text(
          '3/4',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                l10n.tr('birthYearTitle'),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D3E),
                ),
              ),
              const SizedBox(height: 40),
              // Year picker area
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 48,
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1D3E),
                        letterSpacing: 4,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: InputDecoration(
                        hintText: l10n.tr('birthYearHint'),
                        hintStyle: TextStyle(
                          fontSize: 36,
                          color: Colors.grey.shade300,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        state.setBirthYear(value);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GradientButton(
                text: l10n.tr('next'),
                icon: Icons.arrow_forward_rounded,
                onPressed: _isValid
                    ? () {
                        state.setBirthYear(_controller.text);
                        state.setAiStep(4);
                      }
                    : () {},
                colors: _isValid
                    ? null
                    : [Colors.grey.shade300, Colors.grey.shade400],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
